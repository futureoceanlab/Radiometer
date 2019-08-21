----------------------------------------------------------------------------------
--
-- Description: Accumulate 32,000,000 -bit values
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity accumulator is
  generic (
    Nb  : positive := 16;    -- Bits per output Variable
    Ng  : positive := 4     -- Bits in Gray Code
    );
  port (
    -- IN
    CLK      : in  std_logic; -- Synchronizing clock for Sampler and Accumulator
    S_EDGES  : in  std_logic_vector (Ng-1 downto 0);  --  Edges in current sample
    S_CYCLES : in  std_logic_vector (Ng-1 downto 0);  --  Cycles/8 in current sample
    Ns_SEL   : in  std_logic_vector (2 downto 0) := "000"; -- Select Ping Rate
    -- OUT
    EDGES    : out std_logic_vector (Nb-1 downto 0);   -- Accumulated Edges
    CYCLES   : out std_logic_vector (Nb-1 downto 0);   -- Accumulated Cycles
    PING     : out std_logic := '0' -- CALL KIDS IN FOR DINNER
    );

end accumulator;


architecture Behavioral of accumulator is

  signal c     : unsigned(Nb-Ng-1 downto 0) := (others => '0');  -- Samples Accumulated: 4000 < 2^12
  signal c_edges  : unsigned(Nb-1 downto 0) := (others => '0');  -- Edges accumulator
  signal c_cycles : unsigned(Nb-1 downto 0) := (others => '0');  -- Cycles accumulator
  signal Ns       : positive                := 4000;  -- Samples per ping, <= 2^(Nb-Ng) = 4096
                                                      -- to avoid overflow of summand.
                                                      -- See below for allowed values.

begin

  Click_on_RE : process(CLK)
  begin
    if rising_edge(CLK) then

      if c = Ns - 1 then                -- have we accumulated Ns Samples?
        --  OUTPUT
        EDGES                <= std_logic_vector(c_edges);
        CYCLES               <= std_logic_vector(c_cycles);
        PING                 <= '1';
        -- Reset COUNTERS to new sample
        c_edges              <= (others => '0');
        c_cycles             <= (others => '0');
        c_edges(Ng-1 downto 0)  <= unsigned(S_EDGES);
        c_cycles(Ng-1 downto 0) <= unsigned(S_CYCLES);
        c                    <= (others => '0');
        -- Reset Ns to the requested value now that it's safe
        case Ns_SEL is
          when "000" => Ns <= 4000;  --  fs =  1 kHz
          when "001" => Ns <= 2000;  --  fs =  2 kHz
          when "010" => Ns <= 1000;  --  fs =  4 kHz
          when "011" => Ns <= 800;   --  fs =  5 kHz
          when "100" => Ns <= 500;   --  fs =  8 kHz
          when "101" => Ns <= 400;   --  fs = 10 kHz
          when "110" => Ns <= 250;   --  fs = 16 kHz
          when "111" => Ns <= 200;   --  fs = 20 kHz
          when others => report "unreachable" severity failure;
        end case;
      else                              -- nope - keep accumulating
        PING     <= '0';
        c_edges  <= c_edges + unsigned(S_EDGES);
        c_cycles <= c_cycles + unsigned(S_CYCLES);
        c        <= c + 1;

      end if;  -- if c = Ns - 1

    end if;  --   if rising_edge(CLK)

  end process Click_on_RE;

    
end Behavioral;

