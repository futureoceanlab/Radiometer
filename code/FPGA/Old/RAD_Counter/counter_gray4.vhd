----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        counter_gray4 (Behavioral)
-- Filename:      counter_gray4.vhd
-- Created:       18/8/2019
-- Author:        Allan Adams <awa@mit.edu>
----------------------------------------------------------------------------------
-- Based on fast_freq_counter by Mike Field <hamster@snap.net.nz>
----------------------------------------------------------------------------------
-- Description:   Count rising edges and output via Gray code.
-- 
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity counter_gray4 is
  generic (
    N : positive := 4
   -- Total Counter bits. 4 bits get output as gray codes, with N-4
   -- rolling over as prescaling bits.
    );
  port (
    VIN  : in  std_logic;               -- Data in
    GRAY : out std_logic_vector (3 downto 0) := (others => '0')  -- Gray code out
    );
end counter_gray4;


architecture Behavioral of counter_gray4 is
  signal count : unsigned (N-1 downto 0) := (others => '0');
begin
  process(VIN)
  begin
    if rising_edge(VIN) then
      -- convert the binary counter into the gray encoded output
      case count(N-1 downto N-4) is
        when "0000" => GRAY <= "0000";
        when "0001" => GRAY <= "0001";
        when "0010" => GRAY <= "0011";
        when "0011" => GRAY <= "0010";
        when "0100" => GRAY <= "0110";
        when "0101" => GRAY <= "0111";
        when "0110" => GRAY <= "0101";
        when "0111" => GRAY <= "0100";
        when "1000" => GRAY <= "1100";
        when "1001" => GRAY <= "1101";
        when "1010" => GRAY <= "1111";
        when "1011" => GRAY <= "1110";
        when "1100" => GRAY <= "1010";
        when "1101" => GRAY <= "1011";
        when "1110" => GRAY <= "1001";
        when "1111" => GRAY <= "1000";
        when others => report "unreachable" severity failure;
      end case;
      -- advance the counter
      count <= count + 1;
    end if;
  end process;  -- VIN
end Behavioral;
