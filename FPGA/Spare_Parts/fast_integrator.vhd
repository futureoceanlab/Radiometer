----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        fast_integrator (Behavioral)
-- Filename:      fast_integrator.vhd
-- Created:       10/13/2019 11:43:09 AM
-- Author:        Allan Adams (awa@mit.edu)
----------------------------------------------------------------------------------
-- Description:   Reimann-integrate area under signal curve
-- 
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fast_integrator is
  Port (
    CLK_FAST : in  STD_LOGIC; -- Logic Level in
    SIG_IN   : in  STD_LOGIC; -- Clock (fast) in
    SIG_FAST : out STD_LOGIC -- Logic Level Out
    );
end fast_integrator;


architecture Behavioral of fast_integrator is
begin
  process(CLK_FAST)
  begin
    if rising_edge(CLK_FAST) then
      SIG_FAST <= SIG_IN;
    end if;
    if falling_edge(CLK_FAST) then
      SIG_FAST <= '0';
    end if;
  end process;
end Behavioral;
