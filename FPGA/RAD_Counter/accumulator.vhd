----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        accumulator (Behavioral)
-- Filename:      accumulator.vhd
-- Created:       18/8/2019
-- Author:        Allan Adams <awa@mit.edu>
----------------------------------------------------------------------------------
-- Based on fast_freq_counter by Mike Field <hamster@snap.net.nz>
----------------------------------------------------------------------------------
-- Description:   Accumulate counts for cycles and edges.
-- 
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity accumulator is
  generic (
    Nb : positive := 16;                -- Bits per output Variable
    Ng : positive := 4                  -- Bits in Gray Code
    );
  port (
    -- IN
    CLK        : in  std_logic                        := '0';  -- Synchronizing clock for Sampler and Accumulator
    NEW_EDGES  : in  std_logic_vector (Ng-1 downto 0) := (others => '0');  -- Edges in current sample
    NEW_CYCLES : in  std_logic_vector (Ng-1 downto 0) := (others => '0');  -- Cycles/8 in current sample
    NS_SEL     : in  std_logic_vector (2 downto 0)    := "000";  -- Select Ping Rate
    -- OUT
    EDGES      : out std_logic_vector (Nb-1 downto 0) := (others => '0');  -- Accumulated Edges
    CYCLES     : out std_logic_vector (Nb-1 downto 0) := (others => '0');  -- Accumulated Cycles
    PING       : out std_logic                        := '0'  -- CALL KIDS IN FOR DINNER
    );

end accumulator;


architecture Behavioral of accumulator is

  signal samples_sofar        : unsigned(Nb-Ng-1 downto 0) := (others => '0');  -- Samples Accumulated: 4000 < 2^12
  signal edges_sofar  : unsigned(Nb-1 downto 0)    := (others => '0');  -- Edges accumulator
  signal cycles_sofar : unsigned(Nb-1 downto 0)    := (others => '0');  -- Cycles accumulator
  signal num_samples       : positive                   := 4000;  -- Samples per ping, <= 2^(Nb-Ng) = 4096
  -- to avoid overflow of summand.
  -- See below for allowed values.

begin

  Click_on_RE : process(CLK)
  begin
    if rising_edge(CLK) then

      if samples_sofar = num_samples - 1 then                -- have we accumulated Ns Samples?
        --  OUTPUT
        EDGES                   <= std_logic_vector(edges_sofar);
        CYCLES                  <= std_logic_vector(cycles_sofar);
        PING                    <= '1';
        -- Reset COUNTERS to new sample
        edges_sofar                 <= (others => '0');
        cycles_sofar                <= (others => '0');
        edges_sofar(Ng-1 downto 0)  <= unsigned(NEW_EDGES);
        cycles_sofar(Ng-1 downto 0) <= unsigned(NEW_CYCLES);
        samples_sofar               <= (others => '0');
        -- Reset num_samples to the requested value now that it's safe
        case Ns_SEL is
          when "000"  => num_samples <= 4000;    --  fs =  1 kHz
          when "001"  => num_samples <= 2000;    --  fs =  2 kHz
          when "010"  => num_samples <= 1000;    --  fs =  4 kHz
          when "011"  => num_samples <= 800;     --  fs =  5 kHz
          when "100"  => num_samples <= 500;     --  fs =  8 kHz
          when "101"  => num_samples <= 400;     --  fs = 10 kHz
          when "110"  => num_samples <= 250;     --  fs = 16 kHz
          when "111"  => num_samples <= 200;     --  fs = 20 kHz
          when others => report "unreachable" severity failure;
        end case;
      else                              -- nope - keep accumulating
        PING           <= '0';
        edges_sofar    <= edges_sofar   + unsigned(NEW_EDGES);
        cycles_sofar   <= cycles_sofar  + unsigned(NEW_CYCLES);
        samples_sofar  <= samples_sofar + 1;

      end if;  -- if samples_sofar = num_samples - 1

    end if;  --   if rising_edge(CLK)

  end process Click_on_RE;


end Behavioral;

