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
    Nb : positive := 16;                -- Bits per Sample
    Ng : positive := 4                  -- Bits per Gray Coded nibble
    );
  port (
    -- IN
    CLK        : in  std_logic                        := '0';  -- Synchronizing clock for Sampler and Accumulator
    NEW_EDGES  : in  std_logic_vector (Ng-1 downto 0) := (others => '0');  -- Edges in current nibble
    NEW_CYCLES : in  std_logic_vector (Ng-1 downto 0) := (others => '0');  -- Cycles%8 in current nibble
    NS_SEL     : in  std_logic_vector (2 downto 0)    := "000";  -- Select Ping Rate
    -- OUT
    EDGES      : out std_logic_vector (Nb-1 downto 0) := (others => '0');  -- Accumulated Edges
    CYCLES     : out std_logic_vector (Nb-1 downto 0) := (others => '0');  -- Accumulated Cycles
    PING       : out std_logic                        := '0'  -- CALL KIDS IN FOR DINNER
    );

end accumulator;


architecture Behavioral of accumulator is

  signal nibbles_sofar  : unsigned(Nb-1 downto 0) := (others => '0');  -- Nibbles accumulated
  signal edges_sofar    : unsigned(Nb-1 downto 0) := (others => '0');  -- Edges accumulated
  signal cycles_sofar   : unsigned(Nb-1 downto 0) := (others => '0');  -- Cycles accumulated
  signal num_nibbles    : positive                := 12000;            -- Nibbles per sample
  
begin

  Click_on_RE : process(CLK)
  begin
    if rising_edge(CLK) then
      if nibbles_sofar = num_nibbles - 1 then                -- have we accumulated Nn Nibbles?
        --  OUTPUT
        EDGES                   <= std_logic_vector(edges_sofar);
        CYCLES                  <= std_logic_vector(cycles_sofar);
        PING                    <= '1';
        -- Reset COUNTERS for new sample
        edges_sofar                 <= (others => '0');
        cycles_sofar                <= (others => '0');
        edges_sofar(Ng-1 downto 0)  <= unsigned(NEW_EDGES);
        cycles_sofar(Ng-1 downto 0) <= unsigned(NEW_CYCLES);
        nibbles_sofar               <= (others => '0');
        -- Reset num_nibbles to the requested value now that it's safe
        case Ns_SEL is
          when "000"  => num_nibbles <= 12000;    --  fs =  1 kHz
          when "001"  => num_nibbles <=  6000;    --  fs =  2 kHz
          when "010"  => num_nibbles <=  3000;    --  fs =  4 kHz
          when "011"  => num_nibbles <=  1500;    --  fs =  8 kHz
          when "100"  => num_nibbles <=  1200;    --  fs = 10 kHz
          when "101"  => num_nibbles <=   750;    --  fs = 16 kHz
          when "110"  => num_nibbles <=   600;    --  fs = 20 kHz
          when "111"  => num_nibbles <=   500;    --  fs = 24 kHz
          when others => report "unreachable" severity failure;
        end case;
      else                              -- nope - keep accumulating
        PING           <= '0';
        edges_sofar    <= edges_sofar   + unsigned(NEW_EDGES);
        cycles_sofar   <= cycles_sofar  + unsigned(NEW_CYCLES);
        nibbles_sofar  <= nibbles_sofar + 1;

      end if;  -- if nibbles_sofar = num_nibbles - 1

    end if;  --   if rising_edge(CLK)

  end process Click_on_RE;


end Behavioral;
