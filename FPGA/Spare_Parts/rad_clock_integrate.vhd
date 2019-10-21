----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        rad_clock (Behavioral)
-- Filename:      rad_clock.vhd
-- Created:       10/13/2019 11:43:09 AM
-- Author:        Allan Adams (awa@mit.edu)
----------------------------------------------------------------------------------
-- Description:   Use DCMs to generate a 450 MHz clock from the CMOD7 12 MHz clock
-- Given limitations of the MMCMs when driven by the 12MHz clock  on  the  Cmod A7, 
-- this requires two pipelines MMCMs, first lifting 12 --> 250, then 250 --> 450.
-- Cumulative jitter grows a little unsightly (of order 500ps on a 2.2ps signal!), 
-- but since we're using a 3-bit prescalar down the road whose input is sensitive 
-- to 20ps rises and falls, this imprecision is still well in the noise. Phew.
--
-- For posterity, or more precisely my future self (to whom is he born if not me?),
-- here are the two MMCM parameters required: 
--
--   M  = 62.500, D = 1.0  -->  VCO =  750 MHz
--   D0 =  3.000           -->  f1  =  250 MHZ
--
--   M  = 20.250, D = 5.0  -->  VCO = 1012.5 MHz
--   D0 =  2.250           -->  f2  =  450 MHZm
--
-- A mod-3 counter on the 12MHz clock then generate the required 4 MHz clock
--
-- Everything gets a suitable BUFG, FWIW
-- 
----------------------------------------------------------------------------------
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity rad_clock_integrate is
  port (
    CLK_IN       : in  std_logic; --  12 MHz
    HAM_IN       : in  std_logic; --  Data
    HAM_OUT      : out std_logic; --  Data
    CLK_OUT_SLOW : out std_logic  --  4 MHz
    );
end rad_clock_integrate;


architecture Behavioral of rad_clock_integrate is

  component CLK_12_250
    port ( clk_12    : in     std_logic;
           clk_250   : out    std_logic );
  end component;

  component clk_250_450
    port ( clk_250   : in     std_logic;
           clk_450   : out    std_logic  ); 
  end component;

  signal clk_250_wire : std_logic := '0';
  signal clk_450_wire : std_logic := '0';
  signal CLK_4_raw    : std_logic := '0';
  signal counter      : unsigned(1 downto 0) := (others => '0');

begin

  make_clk_250 : CLK_12_250
    port map ( 
      clk_12  => CLK_IN,
      clk_250 => clk_250_wire
     );
   
  make_clk_450 : clk_250_450
    port map ( 
      clk_250 => clk_250_wire,
      clk_450 => clk_450_wire
     );

  BUFG_SLOW : BUFG
    port map (
      O => CLK_OUT_SLOW,                    -- 1-bit output: Clock output
      I => CLK_4_RAW                  -- 1-bit input: Clock input
     );

  counter_process : process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if (counter = "10") then
        counter     <= "00";
        CLK_4_RAW <= not CLK_4_RAW;
      else
        counter <= counter + 1;
      end if;  -- counter = "10"
    end if;  -- rising_edge(CLK)
    if falling_edge(CLK_IN) then
      if (counter = "10") then
        counter     <= "00";
        CLK_4_RAW <= not CLK_4_RAW;
      else
        counter <= counter + 1;
      end if;  -- counter = "10"
    end if;  -- rising_edge(CLK)
  end process counter_process;

  ham_process : process(clk_450_wire)
  begin
    if rising_edge(clk_450_wire) then
      HAM_OUT <= HAM_IN;
    end if;
    if falling_edge(clk_450_wire) then
      HAM_OUT <= '0';
    end if;
  end process ham_process;

end Behavioral;
