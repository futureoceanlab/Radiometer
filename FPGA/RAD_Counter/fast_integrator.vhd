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
    VIN  : in  STD_LOGIC; -- Logic Level in
    CLK  : in  STD_LOGIC; -- Clock (fast) in
    VOUT : out STD_LOGIC -- Logic Level Out
    );
end fast_integrator;


architecture Behavioral of fast_integrator is
begin
  VOUT <= VIN and CLK; 
end Behavioral;
