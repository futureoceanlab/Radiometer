----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        rad_clock_IP (Behavioral)
-- Filename:      rad_clock_IP.vhd
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

library UNISIM;
use UNISIM.vcomponents.all;

entity rad_clock_IP is
  port (
    CLK_IN       : in  std_logic;       --  12 MHz
    CLK_OUT_FAST : out std_logic;       -- 450 MHz
    CLK_OUT_SLOW : out std_logic        --   4 MHz
    );
end rad_clock_IP;


architecture Behavioral of rad_clock_IP is

  component clk_12_250
    port (clk_12      : in  std_logic;
          clk_250     : out std_logic;
          mmcm_locked : out std_logic);
  end component;

  component clk_250_450
    port (clk_250    : in  std_logic;
          mmcm_reset : in  std_logic;
          clk_450    : out std_logic);
  end component;

  signal clk_250_wire : std_logic            := '0';
  signal enable_450   : std_logic            := '0';
  signal not_en_450   : std_logic            := '0';
  signal clk_4_raw    : std_logic            := '0';
  signal count_rise   : unsigned (1 downto 0) := (others => '0');
  signal count_fall   : unsigned (1 downto 0) := (others => '0');
  signal ping_rise    : std_logic := '0';
  signal ping_fall    : std_logic := '0';


begin

  make_clk_250 : clk_12_250
    port map (
      clk_12  => CLK_IN,
      clk_250 => clk_250_wire,
      mmcm_locked => enable_450
      );

  not_en_450 <= not enable_450;

  make_clk_450 : clk_250_450
    port map (
      clk_250    => clk_250_wire,
      mmcm_reset => not_en_450,
      clk_450    => CLK_OUT_FAST
      );

  BUFG_SLOW : BUFG
    port map (
      O => CLK_OUT_SLOW,   -- 1-bit output: Clock output
      I => clk_4_raw       -- 1-bit input: Clock input
      );

  clk_4_raw <= ping_rise or ping_fall;

  rising_process : process (CLK_IN)
  begin
    if (rising_edge(CLK_IN)) then
      if (count_rise = "10") then 
        count_rise <= "00";
        ping_rise <= '1';
      else 
        count_rise <= count_rise + 1;
        ping_rise <= '0';
      end if;
    end if;
  end process rising_process;

  falling_process : process (CLK_IN)
  begin
    if (falling_edge(CLK_IN)) then
      if (count_fall = "10") then 
        count_fall <= "00";
        ping_fall <= '1';
      else 
        count_fall <= count_fall + 1;
        ping_fall <= '0';
      end if;
    end if;
  end process;
  

end Behavioral;








