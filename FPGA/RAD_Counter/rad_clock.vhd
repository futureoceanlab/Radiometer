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
-- Given limitations of the MMCMs when driven by the 12MHz clock on the Cmod A7, 
-- this requires two pipelined MMCMs, first lifting 12 --> 250, then 250 --> 450.
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
-- Everything gets a suitable BUF
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

entity rad_clock is
  port (
    CLK_IN       : in  std_logic;       --  12 MHz
    CLK_OUT_FAST : out std_logic        -- 450 MHz
    );
end rad_clock;


architecture Behavioral of rad_clock is

  signal clkfb1      : std_logic;
  signal clkfb2      : std_logic;
  signal clk_250_raw : std_logic;
  signal clk_250_buf : std_logic := '0';
  signal clk_450_raw : std_logic;
  signal locked_250  : std_logic := '0';
  signal enable_450  : std_logic := '0';

begin


  enable_450 <= not locked_250;

  -- M   62.500  -->  VCO = 750
  -- Dc  3  -->  fc = 250

  MMCME2_BASE_12_250 : MMCME2_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F    => 62.5,  -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE     => 0.0,  -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD      => 83.333,  -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT0_DIVIDE_F   => 3.000,  -- Divide amount for CLKOUT0 (1.000-128.000).
      CLKOUT1_DIVIDE     => 1,
      CLKOUT2_DIVIDE     => 1,
      CLKOUT3_DIVIDE     => 1,
      CLKOUT4_DIVIDE     => 1,
      CLKOUT5_DIVIDE     => 1,
      CLKOUT6_DIVIDE     => 1,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE      => 0.0,
      CLKOUT1_PHASE      => 0.0,
      CLKOUT2_PHASE      => 0.0,
      CLKOUT3_PHASE      => 0.0,
      CLKOUT4_PHASE      => 0.0,
      CLKOUT5_PHASE      => 0.0,
      CLKOUT6_PHASE      => 0.0,
      CLKOUT4_CASCADE    => false,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      DIVCLK_DIVIDE      => 1,          -- Master division value (1-106)
      REF_JITTER1        => 0.0,  -- Reference input jitter in UI (0.000-0.999).
      STARTUP_WAIT       => false  -- Delays DONE until MMCM is locked (FALSE, TRUE)
      )
    port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0   => clk_250_raw,
      CLKOUT0B  => open,
      CLKOUT1   => open,
      CLKOUT1B  => open,
      CLKOUT2   => open,
      CLKOUT2B  => open,
      CLKOUT3   => open,
      CLKOUT3B  => open,
      CLKOUT4   => open,
      CLKOUT5   => open,
      CLKOUT6   => open,
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT  => clkfb1,              -- 1-bit output: Feedback clock
      CLKFBOUTB => open,                -- 1-bit output: Inverted CLKFBOUT
      -- Status Ports: 1-bit (each) output: MMCM status ports
      LOCKED    => locked_250,          -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock input
      CLKIN1    => CLK_IN,              -- 1-bit input: Clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN    => '0',                 -- 1-bit input: Power-down
      RST       => '0',                 -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN   => clkfb1
      );

  BUFG_250 : BUFG
    port map (
--      CE => '1',
--      CLR => '0',
      O => clk_250_buf,                 -- 1-bit output: Clock output
      I => clk_250_raw                  -- 1-bit input: Clock input
      );

--clk_250_buf <= clk_250_raw;

  MMCME2_BASE_250_450 : MMCME2_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F    => 20.250,  -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE     => 0.0,  -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD      => 4.000,  -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT0_DIVIDE_F   => 2.25,  -- Divide amount for CLKOUT0 (1.000-128.000).
      CLKOUT1_DIVIDE     => 1,
      CLKOUT2_DIVIDE     => 1,
      CLKOUT3_DIVIDE     => 1,
      CLKOUT4_DIVIDE     => 1,
      CLKOUT5_DIVIDE     => 1,
      CLKOUT6_DIVIDE     => 1,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE      => 0.0,
      CLKOUT1_PHASE      => 0.0,
      CLKOUT2_PHASE      => 0.0,
      CLKOUT3_PHASE      => 0.0,
      CLKOUT4_PHASE      => 0.0,
      CLKOUT5_PHASE      => 0.0,
      CLKOUT6_PHASE      => 0.0,
      CLKOUT4_CASCADE    => false,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      DIVCLK_DIVIDE      => 5,          -- Master division value (1-106)
      REF_JITTER1        => 0.0,  -- Reference input jitter in UI (0.000-0.999).
      STARTUP_WAIT       => false  -- Delays DONE until MMCM is locked (FALSE, TRUE)
      )
    port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0   => clk_450_raw,
      CLKOUT0B  => open,
      CLKOUT1   => open,
      CLKOUT1B  => open,
      CLKOUT2   => open,
      CLKOUT2B  => open,
      CLKOUT3   => open,
      CLKOUT3B  => open,
      CLKOUT4   => open,
      CLKOUT5   => open,
      CLKOUT6   => open,
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT  => clkfb2,              -- 1-bit output: Feedback clock
      CLKFBOUTB => open,                -- 1-bit output: Inverted CLKFBOUT
      -- Status Ports: 1-bit (each) output: MMCM status ports
      LOCKED    => open,                -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock input
      CLKIN1    => clk_250_buf,         -- 1-bit input: Clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN    => '0',                 -- 1-bit input: Power-down
      RST       => enable_450,          -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN   => clkfb2
      );


--    BUFG_450 : BUFG
--    port map (
--      I => clk_450_raw,                     -- 1-bit input: Clock input
--      O => CLK_OUT_FAST                    -- 1-bit output: Clock output
--      );

CLK_OUT_FAST <= clk_450_raw;
  
end Behavioral;








