library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity RAD_counter is
  port (
    -- in
    sysclk    : in  std_logic;          -- Cmod A7 system clock -- 12MHz
    HAM_IN    : in  std_logic;          -- Input Signal (<50MHz asynch)
    DTOG_IN   : in  std_logic                      := '0';  -- Select EDGES or CYCLES out via DATA
    NS_SEL_IN : in  std_logic_vector (2 downto 0)  := "000";  -- External f_Sample
    --  out                                                  
    DATA_OUT  : out std_logic_vector (15 downto 0) := (others => '0');      -- Accumulated Edges
    PING_OUT  : out std_logic                      := '0';  -- CALL BOYS IN FOR DINNER
    TPWR_OUT  : out std_logic                      := '1'
    );
end RAD_counter;

architecture Behavioral of RAD_counter is

  component clk_12_to_240
    port (CLK_12     : in  std_logic;
          clk_240     : out STD_LOGIC;
          clk_240b    : out STD_LOGIC;
          clk_240_90  : out STD_LOGIC;
          clk_240_90b : out STD_LOGIC);
    end component;

  signal clk_fast     : std_logic := '0';
  signal clk_fastb    : std_logic := '0';
  signal clk_fast_90  : std_logic := '0';
  signal clk_fast_90b : std_logic := '0';
  
  component oversample 
    Port ( Clk      : in  STD_LOGIC;
           Clkb     : in  STD_LOGIC;
           Clk_90   : in  STD_LOGIC;
           Clk_90b  : in  STD_LOGIC;
           SIG_IN   : in  STD_LOGIC;
           sample  : out std_logic_vector(3 downto 0));
  end component;
  
  signal sample :  std_logic_vector(3 downto 0) := "0000";
  
  component count_ones_and_edges
    port (clk      : in  std_logic;
          sample   : in  std_logic_vector(3 downto 0);
          edges    : out std_logic;
          ones     : out unsigned(2 downto 0));
  end component;
  
  signal edges    : std_logic := '0';
  signal ones     : unsigned(2 downto 0) := "000";

  component total_counters
    port (
        clk         : in  std_logic;
        edges       : in  std_logic;
        ones        : in  unsigned(2 downto 0);
        total_edges : out std_logic_vector(21 downto 0);
        total_ones  : out std_logic_vector(21 downto 0));
  end component;

  signal total_edges : std_logic_vector(21 downto 0) := (others => '0');
  signal total_ones  : std_logic_vector(21 downto 0) := (others => '0');
  signal new_limit   : std_logic_vector(17 downto 0) := std_logic_vector(to_unsigned(240000-1,18)); -- 1ms at 240MHz => 1kHz

  component snapshot_deltas
    port (
        clk         : in  std_logic;
        new_limit   : in  std_logic_vector(17 downto 0);
        total_edges : in  std_logic_vector(21 downto 0);
        total_ones  : in  std_logic_vector(21 downto 0);
        delta_edges : out std_logic_vector(21 downto 0);
        delta_ones  : out std_logic_vector(21 downto 0);
        new_deltas  : out std_logic);
  end component;

  signal delta_edges : std_logic_vector(21 downto 0) := (others => '0');
  signal delta_ones  : std_logic_vector(21 downto 0) := (others => '0');

begin

------------------------------

i_clk_12_to_240 : clk_12_to_240 port map (
        CLK_12      => sysclk, 
        CLK_240     => clk_fast,
        CLK_240b    => clk_fastb,
        CLK_240_90  => clk_fast_90,
        CLK_240_90b => clk_fast_90b);

i_oversample : oversample Port map ( 
           clk      => clk_fast,
           clkb     => clk_fastb,
           clk_90   => clk_fast_90,
           clk_90b  => clk_fast_90b,
           sig_in   => HAM_IN,
           sample  => sample);

i_count_ones_and_edges: count_ones_and_edges port map (
          clk      => clk_fast,
          sample   => sample,
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

-- Don't do this:
-- with DTOG_IN select DATA_OUT <= delta_edges(15 downto 0) when '0', delta_ones(19 downto 4) when others;
-- Leads to asynchronous outputs flips w/o gating, not a good idea

clk_proc: process(clk_fast)
    begin
        if rising_edge(clk_fast) then
        
            if DTOG_IN = '0' then
              DATA_OUT <= delta_edges(15 downto 0);
            else 
              DATA_OUT <= delta_ones(19 downto 4);
            end if;
            
            case NS_SEL_IN is
              when "000"  => new_limit <= std_logic_vector(to_unsigned(240000-1, 18));    --  fs =  1 kHz
              when "001"  => new_limit <= std_logic_vector(to_unsigned(120000-1, 18));    --  fs =  2 kHz
              when "010"  => new_limit <= std_logic_vector(to_unsigned( 60000-1, 18));    --  fs =  4 kHz
              when "011"  => new_limit <= std_logic_vector(to_unsigned( 30000-1, 18));    --  fs =  8 kHz
              when "100"  => new_limit <= std_logic_vector(to_unsigned( 24000-1, 18));    --  fs = 10 kHz
              when "101"  => new_limit <= std_logic_vector(to_unsigned( 15000-1, 18));    --  fs = 16 kHz
              when "110"  => new_limit <= std_logic_vector(to_unsigned( 10000-1, 18));    --  fs = 24 kHz
              when others => new_limit <= std_logic_vector(to_unsigned(  7500-1, 18));    --  fs = 32 kHz
            end case;
            

        end if;
    end process;
end Behavioral;