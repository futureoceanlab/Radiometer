----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        subsample (Behavioral)
-- Filename:      subsample.vhd
-- Created:       10/13/2019 11:43:09 AM
-- Author:        Allan Adams (awa@mit.edu)
----------------------------------------------------------------------------------
-- Description:   Reimann-integrate area under signal curve by subsampling the 
--                signal with a fast clock; we'll later count these fast edges 
--                to estimate the area under the curve
-- 
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--
library unisim;
use unisim.vcomponents.all;
--

entity subsample is
  Port (
    CLK_FAST : in  STD_LOGIC; -- Logic Level in
    SIG_IN   : in  STD_LOGIC; -- Clock (fast) in
    SIG_FAST : out STD_LOGIC -- Logic Level Out
    );
end subsample;

architecture Behavioral of subsample is

begin 

  Integrator_BUFG : BUFGCE
--  Integrator_BUFH : BUFHCE
  port map(
  O  => SIG_FAST,
  CE => SIG_IN,
  I  => CLK_FAST
  );


--  process(CLK_FAST)
--  begin
--    if rising_edge(CLK_FAST) then
--      SIG_FAST <= SIG_IN;
--    end if;
--    if falling_edge(CLK_FAST) then
--      SIG_FAST <= '0';
--    end if;
--  end process;

end Behavioral;
