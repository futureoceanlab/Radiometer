----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        clockify (Behavioral)
-- Filename:      clockify.vhd
-- Created:       10/13/2019 11:43:09 AM
-- Author:        Allan Adams (awa@mit.edu)
----------------------------------------------------------------------------------
-- Description:   Make a clocked version of the input signal with two registers
--                and a BUFGCE
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

entity clockify is
  port (
    CLK_FAST : in  std_logic;           -- Logic Level in
    SIG_IN   : in  std_logic;           -- Clock (fast) in
    CLK_SIG  : out std_logic            -- Logic Level Out
    );
end clockify;

architecture Behavioral of clockify is

  signal old_sig    : std_logic := '0';
  signal new_sig    : std_logic := '0';
  signal sig_enable : std_logic := '0';

begin

  SigBuf_BUFG : BUFGCE
--  SigBuf_BUFH : BUFHCE
    port map(
      O  => CLK_SIG,
      CE => sig_enable,
      I  => CLK_FAST
      );

  process(CLK_FAST)
  begin
    if rising_edge(CLK_FAST) then
      old_sig    <= new_sig;
      new_sig    <= SIG_IN;
      sig_enable <= new_sig and (not old_sig);
    end if;
  end process;

end Behavioral;
