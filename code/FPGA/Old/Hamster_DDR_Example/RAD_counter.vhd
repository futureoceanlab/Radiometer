library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity RAD_counter is
  generic (
    Nb : positive := 16
    );
  port (
    -- in
    sysclk    : in  std_logic;          -- Cmod A7 system clock -- 12MHz
    HAM_IN    : in  std_logic;          -- Input Signal
    DTOG_IN   : in  std_logic                     := '0';  -- Select EDGES or CYCLES out via DATA
    NS_SEL_IN : in  std_logic_vector (2 downto 0) := "000";  -- External f_Sample
    --  out                                                  
    DATA_OUT  : out std_logic_vector (Nb-1 downto 0);      -- Accumulated Edges
    PING_OUT  : out std_logic                     := '0';  -- CALL BOYS IN FOR DINNER
    TPWR_OUT  : out std_logic                     := '1'
    );
end RAD_counter;

architecture Behavioral of RAD_counter is

  component clk_12_to_240
    port (CLK_12   : in  std_logic;
          CLK_240  : out std_logic);
  end component;

  signal clk_fast : std_logic;
  
  Component oversample 
    Port ( Clk      : in  STD_LOGIC;
           SIG_IN   : in  STD_LOGIC;
           samples  : out std_logic_vector(3 downto 0));
  end component;
  
  signal samples :  std_logic_vector(3 downto 0);
  
  component count_ones_and_edges
    port (clk      : in  std_logic;
          samples  : in  std_logic_vector(3 downto 0);
          edges    : out std_logic_vector(2 downto 0);
          ones     : out std_logic_vector(2 downto 0));
  end component;
  
  signal edges    : std_logic_vector(2 downto 0);
  signal ones     : std_logic_vector(2 downto 0);

  component total_counters
    port (
        clk        : in  std_logic;
        edges       : in  std_logic_vector(2 downto 0);
        ones        : in  std_logic_vector(2 downto 0);
        total_edges : out std_logic_vector(23 downto 0);
        total_ones  : out std_logic_vector(23 downto 0));
  end component;

  signal total_edges : std_logic_vector(23 downto 0);
  signal total_ones  : std_logic_vector(23 downto 0);
  signal new_limit   : std_logic_vector(19 downto 0) := std_logic_vector(to_unsigned(240000000/10000-1,20));

  component snapshot_deltas
    port (
        clk         : in  std_logic;
        new_limit   : in  std_logic_vector(19 downto 0);
        total_edges : in  std_logic_vector(23 downto 0);
        total_ones  : in  std_logic_vector(23 downto 0);
        delta_edges : out std_logic_vector(23 downto 0);
        delta_ones  : out std_logic_vector(23 downto 0);
        new_deltas  : out std_logic);
  end component;

  signal delta_edges : std_logic_vector(23 downto 0);
  signal delta_ones  : std_logic_vector(23 downto 0);

begin

------------------------------

i_clk_12_to_240 : clk_12_to_240 port map (
        CLK_12   => sysclk, 
        CLK_240  => clk_fast);

i_oversample : oversample Port map ( 
           clk      => clk_fast,
           sig_in   => HAM_IN,
           samples  => samples);

i_count_ones_and_edges: count_ones_and_edges port map (
          clk     => clk_fast,
          samples  => samples,
          edges    => edges,
          ones     => ones);

i_total_counters: total_counters port map (
          clk      => clk_fast,
          edges    => edges,
          ones     => ones,
          total_edges => total_edges,
          total_ones => total_ones);
          
i_snapshot_deltas : snapshot_deltas port map (
                    clk         => clk_fast,
                    new_limit   => new_limit,
                    total_edges => total_edges,
                    total_ones  => total_ones,
                    delta_edges => delta_edges,
                    delta_ones  => delta_ones,
                    new_deltas  => PING_OUT);

    with DTOG_IN select DATA_OUT <= delta_edges(Nb-1 downto 0) when '0', delta_ones(Nb-1 downto 0) when others;

clk_proc: process(clk_fast)
    begin
        if rising_edge(clk_fast) then
            case NS_SEL_IN is
              when "000"  => new_limit <= std_logic_vector(to_unsigned(240000000/1000-1,  20));    --  fs =  1 kHz
              when "001"  => new_limit <= std_logic_vector(to_unsigned(240000000/2000-1,  20));    --  fs =  2 kHz
              when "010"  => new_limit <= std_logic_vector(to_unsigned(240000000/4000-1,  20));    --  fs =  4 kHz
              when "011"  => new_limit <= std_logic_vector(to_unsigned(240000000/5000-1,  20));    --  fs =  5 kHz
              when "100"  => new_limit <= std_logic_vector(to_unsigned(240000000/8000-1,  20));    --  fs =  8 kHz
              when "101"  => new_limit <= std_logic_vector(to_unsigned(240000000/10000-1, 20));    --  fs = 10 kHz
              when "110"  => new_limit <= std_logic_vector(to_unsigned(240000000/16000-1, 20));    --  fs = 16 kHz
              when others => new_limit <= std_logic_vector(to_unsigned(240000000/20000-1, 20));    --  fs = 20 kHz
            end case;
        end if;
    end process;
end Behavioral;