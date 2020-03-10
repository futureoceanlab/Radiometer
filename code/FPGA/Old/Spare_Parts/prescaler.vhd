----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        Prescaler (Behavioral)
-- Filename:      Prescaler.vhd
-- Created:       10/15/2019 10:37:09 PM
-- Author:        Allan Adams (awa@mit.edu)
----------------------------------------------------------------------------------
-- Description:   Prescale before sending to counter
-- 
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity prescaler is
  generic (
    Np : positive := 3                   -- Total prescaling bits.
    );
  port (
    Test_Signal : in  std_logic;        -- Data in
    Click_Out   : out std_logic := '0'  -- Gray code out
    );
end prescaler;


architecture Behavioral of prescaler is

  signal count : unsigned (Np-1 downto 0) := (others => '0');
  signal max_c : unsigned (Np-1 downto 0) := (others => '1');

begin
  process(Test_Signal)
  begin
    if rising_edge(Test_Signal) then
      if count = max_c then -- If counter maxed out, ping output
        Click_Out <= '1';
      end if; -- count =  "1...1"
      count <= count + 1;  -- advance the counter
    end if; -- rising_edge
    if falling_edge(Test_Signal) then
      Click_Out <= '0';
    end if; -- falling edge
  end process;
end Behavioral;
