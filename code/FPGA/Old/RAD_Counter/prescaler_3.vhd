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
-- Created:       18/8/2019
-- Author:        Allan Adams <awa@mit.edu>
----------------------------------------------------------------------------------
-- Description:   3-bit Prescaler
-- 
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
--
library unisim;
use unisim.vcomponents.all;
--

entity prescaler_3 is
  port (
    Test_Signal : in  std_logic;        -- Data in
    Click_Out   : out std_logic := '0'  -- Gray code out
    );
end prescaler_3;


architecture Behavioral of prescaler_3 is

  signal count : unsigned (2 downto 0) := (others => '0');
  signal out_enable : std_logic := '0';

begin

  rising_process_3 : process(Test_Signal)
  begin
    if rising_edge(Test_Signal) then
      if count = "111" then             -- If counter maxed out, ping output
        out_enable <= '1';
--        out_enable <= '1' after 400ps;
      else
        out_enable <= '0';
      end if;  -- count =  "1...1"
      count <= count + 1;               -- advance the counter
    end if;  -- rising_edge
  end process;


  Prescalar_BUFG : BUFGCE
--  Prescalar_BUFG : BUFMRCE
  port map(
    O  => Click_Out,
    CE => out_enable,
    I  => Test_Signal
    );


end Behavioral;
