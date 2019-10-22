----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        RAD_Counter (Behavioral)
-- Filename:      RAD_Counter.vhd
-- Created:       18/8/2019
-- Author:        Allan Adams <awa@mit.edu>
----------------------------------------------------------------------------------
-- Based on fast_freq_counter by Mike Field <hamster@snap.net.nz>
----------------------------------------------------------------------------------
-- Description:   This project counts pulses from a fast source and estimates
--                the area under the curve.  The input signal is a random train
--                of 20+ns pulses (<50MHz).  We need to count these pulses and
--                also estimate what fraction of the time the signal is high.
--                To count pulses we use Mike Field's fast_freq_counter, which
--                uses a Gray-coded counter to handle the fast input, then
--                synchronizes this count to a binary counter using a short
--                clocked FIFO pipeline.  To measure the area under the curve
--                we create a 450MHz clock via 2 MMCMs (12->250, 250->450),
--                convolve the input source with the fast clock, decimate the
--                convovled signal with  a 3-bit prescaler (450MHz-->56MHz) and
--                again use a fast_freq_counter to count the edges. Both counts
--                are accumulated into 16-bit running totals per user-specified
--                sample period (controlled by NS_SEL_IN) and output via a
--                2-element mux controlled by DTOG_IN.
--
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library unisim;
use unisim.vcomponents.all;

entity RAD_counter is
  generic (
    Nb : positive := 16
    );
  port (
    -- in
    sysclk    : in  std_logic;          -- Cmod A7 system clock -- 12MHz
    HAM_IN    : in  std_logic;          -- Input Signal
    DTOG_IN   : in  std_logic                     := '0';  -- Select EDGES or CYCLES out via DATA
    NS_SEL_IN : in  std_logic_vector (2 downto 0) := "000";  -- External Number of 16-bit samples per sec
    --  out                                                  
    DATA_OUT  : out std_logic_vector (Nb-1 downto 0);      -- Accumulated Edges
    PING_OUT  : out std_logic                     := '0';  -- CALL BOYS IN FOR DINNER
    TPWR_OUT  : out std_logic                     := '1'
    );
end RAD_counter;


architecture Behavioral of RAD_counter is

  component rad_clock
    port (CLK_IN       : in  std_logic;
          CLK_OUT_FAST : out std_logic);
  end component;

  component subsample
    Port ( Clk_FAST : in  STD_LOGIC; -- Logic Level in
           SIG_IN   : in  STD_LOGIC; -- Clock (fast) in
           SIG_FAST : out STD_LOGIC); -- Logic Level Out
  end component;

  component prescaler_3
    port (Test_Signal : in  std_logic;
          Click_Out   : out std_logic);
  end component;

  component clockify
    port (
      CLK_FAST : in  std_logic;           -- Logic Level in
      SIG_IN   : in  std_logic;           -- Clock (fast) in
      CLK_SIG  : out std_logic);
  end component;

  component fast_counter
    port (SIGNAL_IN  : in  std_logic;
          CLK_IN     : in  std_logic;
          SAMPLE_OUT : out std_logic_vector (3 downto 0));
  end component;

  component accumulator
    generic (Nb : positive;
             Ng : positive);
    port (CLK        : in  std_logic;
          NEW_EDGES  : in  std_logic_vector (Ng-1 downto 0);
          NEW_CYCLES : in  std_logic_vector (Ng-1 downto 0);
          NS_SEL     : in  std_logic_vector (2 downto 0);
          EDGES      : out std_logic_vector (Nb-1 downto 0);
          CYCLES     : out std_logic_vector (Nb-1 downto 0);
          PING       : out std_logic);
  end component;

  component output_mux
    generic (Nb : positive);
    port (CLK    : in  std_logic;      -- 0 for DATA_A, 1 for DATA_B
          TOG    : in  std_logic;
          DATA_A : in  std_logic_vector (Nb-1 downto 0);
          DATA_B : in  std_logic_vector (Nb-1 downto 0);
          DATA_O : out std_logic_vector (Nb-1 downto 0));
  end component;

  signal clk_sample  : std_logic;
  signal clk_cycles  : std_logic;
  signal cycles_mod8 : std_logic;
  signal clk_ham     : std_logic;
  signal clk_fast    : std_logic;
  signal bin_edges   : std_logic_vector (3 downto 0);
  signal bin_cycles  : std_logic_vector (3 downto 0);
  signal edge_count  : std_logic_vector (Nb-1 downto 0);
  signal cycle_count : std_logic_vector (Nb-1 downto 0);

begin

------------------------------

  RadClock : rad_clock
    port map (CLK_IN       => clk_sample,
              CLK_OUT_FAST => clk_fast);

  ClockifyHam : clockify
    port map (CLK_FAST   => clk_fast, 
              SIG_IN     => HAM_IN,
              CLK_SIG    => clk_ham);

  Subsample_HAM : subsample
    port map (CLK_FAST => clk_fast,
              SIG_IN   => HAM_IN,
              SIG_FAST => clk_cycles);

  PrescaleCycles : prescaler_3
    port map (Test_Signal => clk_cycles,
              Click_Out   => cycles_mod8);

  CountCycles : fast_counter
    port map (SIGNAL_IN  => cycles_mod8,
              CLK_IN     => clk_sample,
              SAMPLE_OUT => bin_cycles);

  CountEdges : fast_counter
    port map (SIGNAL_IN  => clk_ham,
              CLK_IN     => clk_sample,
              SAMPLE_OUT => bin_edges);

  Totals : accumulator
    generic map (Nb => Nb,
                 Ng => 4)
    port map (CLK        => clk_sample,
              NEW_EDGES  => bin_edges,
              NEW_CYCLES => bin_cycles,
              NS_SEL     => NS_SEL_IN,
              EDGES      => edge_count,
              CYCLES     => cycle_count,
              PING       => PING_OUT);

  OutMux : output_mux
    generic map (Nb => Nb)
    port map (CLK    => clk_sample,
              DATA_A => edge_count,
              DATA_B => cycle_count,
              TOG    => DTOG_IN,
              DATA_O => DATA_OUT);

end Behavioral;
