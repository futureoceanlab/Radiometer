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

entity oversample is
    Port ( clk     : in STD_LOGIC;
           clkb    : in STD_LOGIC;
           clk_90  : in STD_LOGIC;
           clk_90b : in STD_LOGIC;
           sig_in  : in STD_LOGIC;
           sample  : out STD_LOGIC_VECTOR (3 downto 0) := "0000" ) ;
end oversample;


architecture Behavioral of oversample is

--------------------------------------------------------
-- DDR Version
-- Works as of 11pm Wednesday Oct 23

--    signal ddr_samples : std_logic_vector(1 downto 0) := (others => '0');
--begin
--    -- Ready for 4:1 SERDES
--    sample <= ddr_samples(1) & ddr_samples(1) & ddr_samples(0) & ddr_samples(0);
--       
--IDDR_inst : IDDR 
--   generic map (
--      DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE", "SAME_EDGE" 
--      INIT_Q1 => '0', -- Initial value of Q1: '0' or '1'
--      INIT_Q2 => '0', -- Initial value of Q2: '0' or '1'
--      SRTYPE => "SYNC") -- Set/Reset type: "SYNC" or "ASYNC" 
--   port map (
--      Q1 => ddr_samples(0), -- 1-bit output for positive edge of clock 
--      Q2 => ddr_samples(1), -- 1-bit output for negative edge of clock
--      C => Clk,   -- 1-bit clock input
--      CE => '1', -- 1-bit clock enable input
--      D => sig_in,   -- 1-bit DDR data input
--      R => '0',   -- 1-bit reset
--      S => '0'    -- 1-bit set
--      );

-- DDR Version
--------------------------------------------------------


--------------------------------------------------------
-- ISERDES Version

  begin

 ISERDESE2_inst : ISERDESE2
   generic map(
     DATA_RATE         => "DDR", -- DDR, SDR
     DATA_WIDTH        => 4,     -- Parallel data width (2-8,10,14)
     DYN_CLKDIV_INV_EN => "FALSE", -- Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
     DYN_CLK_INV_EN    => "FALSE", -- Enable DYNCLKINVSEL inversion (FALSE, TRUE)
     -- INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
     INIT_Q1           => '0',
     INIT_Q2           => '0',
     INIT_Q3           => '0',
     INIT_Q4           => '0',
     INTERFACE_TYPE    => "OVERSAMPLE", -- MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
     IOBDELAY          => "NONE", -- NONE, BOTH, IBUF, IFD
     NUM_CE            => 1,     -- Number of clock enables (1,2)
     OFB_USED          => "FALSE", -- Select OFB path (FALSE, TRUE)
     SERDES_MODE       => "MASTER", -- MASTER, SLAVE
     -- SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
     SRVAL_Q1          => '0',
     SRVAL_Q2          => '0',
     SRVAL_Q3          => '0',
     SRVAL_Q4          => '0'
   )
   port map(
     -- Q1 - Q8: 1-bit (each) output: Registered data outputs
     Q1           => sample(0),
     Q2           => sample(2),
     Q3           => sample(1),
     Q4           => sample(3),
     -- Clocks: 1-bit (each) input: ISERDESE2 clock input ports
     CLK          => clk,        -- 1-bit input: High-speed clock
     CLKB         => clkb,       -- 1-bit input: High-speed secondary clock
     CLKDIV       => '0',        -- 1-bit input: Divided clock
     OCLK         => clk_90,     -- 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
     BITSLIP      => '0',        -- 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
     -- Input Data: 1-bit (each) input: ISERDESE2 data input ports
     D            => sig_in,     -- 1-bit input: Data input
     DDLY         => '0',        -- 1-bit input: Serial data from IDELAYE2
     OFB          => '0',        -- 1-bit input: Data feedback from OSERDESE2
     OCLKB        => clk_90b,    -- 1-bit input: High speed negative edge output clock
     RST          => '0',        -- 1-bit input: Active high asynchronous reset
     -- CLKDIV when asserted (active High). Subsequently, the data seen on the
     -- Q1 to Q8 output ports will shift, as in a barrel-shifter operation, one
     -- position every time Bitslip is invoked (DDR operation is different from
     -- SDR).

     -- CE1, CE2: 1-bit (each) input: Data register clock enable inputs
     CE1          => '1',
     CE2          => '1',
     CLKDIVP      => '0',        -- 1-bit input: TBD
     -- Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
     DYNCLKDIVSEL => '0',        -- 1-bit input: Dynamic CLKDIV inversion
     DYNCLKSEL    => '0',        -- 1-bit input: Dynamic CLK/CLKB inversion
     -- SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
     SHIFTIN1     => '0',
     SHIFTIN2     => '0'
   );

-- ISERDES Version
--------------------------------------------------------

end Behavioral;


