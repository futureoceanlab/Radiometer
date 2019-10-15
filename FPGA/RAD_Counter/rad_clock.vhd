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

entity rad_clock is
  port (
    CLK      : in  std_logic; --  12 MHz
    CLK_FAST : out std_logic; -- 450 MHz
    CLK_SLOW : out std_logic  --   4 MHz
    );
end rad_clock;


architecture Behavioral of rad_clock is

  signal in_CLK_250   : std_logic;
  signal bf_CLK_250   : std_logic;
  signal in_CLK_450   : std_logic;
  signal in_CLK_4     : std_logic := '0';
  signal clkfb1       : std_logic;
  signal clkfb2       : std_logic;
  signal counter      : unsigned(1 downto 0) := (others => '0');

begin

  -- M   62.500  -->  VCO = 750
  -- Dc  3  -->  fc = 250

  MMCM250 : MMCME2_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F    => 62.500,  -- Multiply value for all CLKOUT (2.000-300.000). SHOULD BE 90!!!!!!!!
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
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN => '0',                    -- 1-bit input: Power-down
      RST    => '0',                    -- 1-bit input: Reset
      -- Status Ports: 1-bit (each) output: MMCM status ports
      LOCKED => open,                   -- 1-bit output: LOCK

      -- Clock Inputs: 1-bit (each) input: Clock input
      CLKIN1 => CLK,                 -- 1-bit input: Clock

      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0   => in_CLK_250,         -- 1-bit output: CLKOUT0
      CLKOUT0B  => open,                -- 1-bit output: Inverted CLKOUT0
      CLKOUT1   => open,                -- 1-bit output: CLKOUT1
      CLKOUT1B  => open,                -- 1-bit output: Inverted CLKOUT1
      CLKOUT2   => open,                -- 1-bit output: CLKOUT2
      CLKOUT2B  => open,                -- 1-bit output: Inverted CLKOUT2
      CLKOUT3   => open,                -- 1-bit output: CLKOUT3
      CLKOUT3B  => open,                -- 1-bit output: Inverted CLKOUT3
      CLKOUT4   => open,                -- 1-bit output: CLKOUT4
      CLKOUT5   => open,                -- 1-bit output: CLKOUT5
      CLKOUT6   => open,                -- 1-bit output: CLKOUT6
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT  => clkfb1,               -- 1-bit output: Feedback clock
      CLKFBOUTB => open,                -- 1-bit output: Inverted CLKFBOUT
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN   => clkfb1                -- 1-bit input: Feedback clock
      );

  BUFG_250 : BUFG
    port map (
      O => bf_CLK_250,                    -- 1-bit output: Clock output
      I => in_CLK_250                  -- 1-bit input: Clock input
      );




  MMCM450 : MMCME2_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F    => 20.250,  -- Multiply value for all CLKOUT (2.000-300.000). SHOULD BE 90!!!!!!!!
      CLKFBOUT_PHASE     => 0.0,  -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD      => 4.000,  -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT0_DIVIDE_F   => 2.250,  -- Divide amount for CLKOUT0 (1.000-128.000).
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
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN => '0',                    -- 1-bit input: Power-down
      RST    => '0',                    -- 1-bit input: Reset
      -- Status Ports: 1-bit (each) output: MMCM status ports
      LOCKED => open,                   -- 1-bit output: LOCK

      -- Clock Inputs: 1-bit (each) input: Clock input
      CLKIN1 => bf_CLK_250,                 -- 1-bit input: Clock

      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0   => in_CLK_450,         -- 1-bit output: CLKOUT0
      CLKOUT0B  => open,                -- 1-bit output: Inverted CLKOUT0
      CLKOUT1   => open,                -- 1-bit output: CLKOUT1
      CLKOUT1B  => open,                -- 1-bit output: Inverted CLKOUT1
      CLKOUT2   => open,                -- 1-bit output: CLKOUT2
      CLKOUT2B  => open,                -- 1-bit output: Inverted CLKOUT2
      CLKOUT3   => open,                -- 1-bit output: CLKOUT3
      CLKOUT3B  => open,                -- 1-bit output: Inverted CLKOUT3
      CLKOUT4   => open,                -- 1-bit output: CLKOUT4
      CLKOUT5   => open,                -- 1-bit output: CLKOUT5
      CLKOUT6   => open,                -- 1-bit output: CLKOUT6
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT  => clkfb2,               -- 1-bit output: Feedback clock
      CLKFBOUTB => open,                -- 1-bit output: Inverted CLKFBOUT
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN   => clkfb2                -- 1-bit input: Feedback clock
      );

  BUFG_450 : BUFG
    port map (
      O => CLK_FAST,                    -- 1-bit output: Clock output
      I => in_CLK_450                     -- 1-bit input: Clock input
      );

  BUFG_SLOW : BUFG
    port map (
      O => CLK_SLOW,                    -- 1-bit output: Clock output
      I => in_CLK_4                  -- 1-bit input: Clock input
      );

  counter_process : process(CLK)
  begin
    if rising_edge(CLK) then
      if counter = "10" then
        counter     <= "00";
        in_CLK_4 <= not in_CLK_4;
      else
        counter <= counter + 1;
      end if;  -- counter = "10"
    end if;  -- rising_edge(CLK)
    if falling_edge(CLK) then
      if counter = "10" then
        counter     <= "00";
        in_CLK_4 <= not in_CLK_4;
      else
        counter <= counter + 1;
      end if;  -- counter = "10"
    end if;  -- rising_edge(CLK)
  end process counter_process;


end Behavioral;
