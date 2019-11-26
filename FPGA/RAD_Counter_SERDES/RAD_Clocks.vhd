----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter_SERDES
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        RAD_Counter (Behavioral)
-- Filename:      RAD_Counter.vhd
-- Created:       18/8/2019
-- Author:        Allan Adams <awa@mit.edu>
-- Guru:          Mike Field <hamster@snap.net.nz>  <=  Many props and thanks!!!
----------------------------------------------------------------------------------
-- Description:   This project counts pulses from a fast source and estimates
--                the area under the curve.  The input signal is a random train
--                of 20+ns pulses (<50MHz).  We need to count these pulses and
--                also estimate what fraction of the time the signal is high.
--                We sample the signal via 4:1 ISERDES running at 250MHz, giving
--                a 1GHz bitstream-sample of the incoming signal.  We then count
--                ones in the stream to estimate time-high, and detect 16+ns long
--                pulses with a simple edge detector.  A running tally is kept of 
--                both counts.  Count-changes are output over a 16-bit bus 
--                (DATA_OUT) along with a pulse (PING_OUT) at a user-selectable 
--                rate (NS_SEL_IN), with a binary input (DTOG_IN) gating a mux
--                controlling which count appears on the bus.  The time-high 
--                count is prescaled by 4 bits to avoid overflowing the bus.
--
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity rad_clocks is
    generic (
        N_fast : integer -- frequency  in Hz of fast clock 
    );
    Port ( CLK_IN      : in STD_LOGIC;
           CLK_fast     : out STD_LOGIC;
           CLK_fastb    : out STD_LOGIC;
           CLK_fast_90  : out STD_LOGIC;
           CLK_fast_90b : out STD_LOGIC);
end rad_clocks;

architecture Behavioral of rad_clocks is
    signal clkfb : std_logic;
begin


MMCME2_BASE_inst : MMCME2_BASE
generic map (
  BANDWIDTH => "OPTIMIZED",     -- Jitter programming (OPTIMIZED, HIGH, LOW)
--  CLKFBOUT_MULT_F => 60.0,      -- Multiply value for all CLKOUT (2.000-64.000).
--  CLKFBOUT_MULT_F => 62.5,      -- Multiply value for all CLKOUT (2.000-64.000).
  CLKFBOUT_MULT_F => real(N_fast/4000000),      -- Multiply value for all CLKOUT (2.000-64.000).
  CLKFBOUT_PHASE => 0.0,        -- Phase offset in degrees of CLKFB (-360.000-360.000).
  CLKIN1_PERIOD => 83.333,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
  -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
  CLKOUT0_DIVIDE_F => 3.0,      -- Divide amount for CLKOUT0 (1.000-128.000).
  CLKOUT1_DIVIDE => 3,
  CLKOUT2_DIVIDE => 1,
  CLKOUT3_DIVIDE => 1,
  CLKOUT4_DIVIDE => 1,
  CLKOUT5_DIVIDE => 1,
  CLKOUT6_DIVIDE => 1,
  -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
  CLKOUT0_DUTY_CYCLE => 0.5,
  CLKOUT1_DUTY_CYCLE => 0.5,
  CLKOUT2_DUTY_CYCLE => 0.5,
  CLKOUT3_DUTY_CYCLE => 0.5,
  CLKOUT4_DUTY_CYCLE => 0.5,
  CLKOUT5_DUTY_CYCLE => 0.5,
  CLKOUT6_DUTY_CYCLE => 0.5,
  -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
  CLKOUT0_PHASE => 0.0,
  CLKOUT1_PHASE => 90.0,
  CLKOUT2_PHASE => 0.0,
  CLKOUT3_PHASE => 0.0,
  CLKOUT4_PHASE => 0.0,
  CLKOUT5_PHASE => 0.0,
  CLKOUT6_PHASE => 0.0,
  CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
  DIVCLK_DIVIDE => 1,        -- Master division value (1-106)
  REF_JITTER1 => 0.0,        -- Reference input jitter in UI (0.000-0.999).
  STARTUP_WAIT => FALSE      -- Delays DONE until MMCM is locked (FALSE, TRUE)
)
port map (
  -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
  CLKOUT0  => CLK_FAST,
  CLKOUT0B => CLK_FASTb,
  CLKOUT1  => CLK_FAST_90,
  CLKOUT1B => CLK_FAST_90b,
  CLKOUT2  => open,
  CLKOUT2B => open,
  CLKOUT3  => open,
  CLKOUT3B => open,
  CLKOUT4  => open,
  CLKOUT5  => open,
  CLKOUT6  => open,
  -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
  CLKFBOUT => clkfb,   -- 1-bit output: Feedback clock
  CLKFBOUTB => open, -- 1-bit output: Inverted CLKFBOUT
  -- Status Ports: 1-bit (each) output: MMCM status ports
  LOCKED => open,       -- 1-bit output: LOCK
  -- Clock Inputs: 1-bit (each) input: Clock input
  CLKIN1 => CLK_IN,       -- 1-bit input: Clock
  -- Control Ports: 1-bit (each) input: MMCM control ports
  PWRDWN => '0',       -- 1-bit input: Power-down
  RST => '0',             -- 1-bit input: Reset
  -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
  CLKFBIN => clkfb
);

end Behavioral;
