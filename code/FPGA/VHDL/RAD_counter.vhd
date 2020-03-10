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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity RAD_counter is
  generic (
--    N_fast : integer := 240000000 -- frequency  in Hz of fast clock 
    N_fast : integer := 250000000 -- frequency  in Hz of fast clock 
    );
  port (
    -- in
    sysclk    : in  std_logic                      := '0';    -- Cmod A7 system clock -- 12MHz
    HAM_IN    : in  std_logic                      := '0';    -- Input Signal (<50MHz asynch)
    NS_SEL_IN : in  std_logic_vector (2 downto 0)  := "000";  -- External f_Sample choice
    DTOG_IN   : in  std_logic                      := '0';    -- HIGH: Pulses   LOW: Cycles
    RESET_IN  : in  std_logic                      := '0';    -- HIGH: Reset counters
    KILLT_IN  : in  std_logic                      := '0';    -- HIGH: turn Teensy off
    --  out                                                  
    DATA_OUT  : out std_logic_vector (15 downto 0) := (others => '0');      -- Accumulated Edges
    PING_OUT  : out std_logic                      := '0';    -- CALL BOYS IN FOR DINNER
    TPWR_OUT  : out std_logic                      := '1';
    --  LEDs to kill
    LEDL      : out std_logic_vector (1 downto 0)  := (others => '0');
    LEDH      : out std_logic_vector (2 downto 0)  := (others => '1') 
    );
end RAD_counter;

architecture Behavioral of RAD_counter is

  component rad_clocks
    generic (
          N_fast       : integer);
    port (CLK_IN       : in  std_logic;
          CLK_FAST     : out STD_LOGIC;
          CLK_FASTb    : out STD_LOGIC;
          CLK_FAST_90  : out STD_LOGIC;
          CLK_FAST_90b : out STD_LOGIC);
    end component;

  signal clk     : std_logic := '0';
  signal clkb    : std_logic := '0';
  signal clk_90  : std_logic := '0';
  signal clk_90b : std_logic := '0';
  
  component oversample 
    Port ( Clk      : in  STD_LOGIC;
           Clkb     : in  STD_LOGIC;
           Clk_90   : in  STD_LOGIC;
           Clk_90b  : in  STD_LOGIC;
           SIG_IN   : in  STD_LOGIC;
           sample   : out std_logic_vector(3 downto 0));
  end component;
  
  signal sample :  std_logic_vector(3 downto 0) := "0000";
  
  component count_ones_and_edges
    port (clk      : in  std_logic;
          sample   : in  std_logic_vector(3 downto 0);
          edges    : out std_logic;
          ones     : out std_logic_vector(2 downto 0));
  end component;
  
  signal edges    : std_logic := '0';
  signal ones     : std_logic_vector(2 downto 0) := "000";
  signal reset    : std_logic := '0';

  component total_counters
    port (
        clk         : in  std_logic;
        edges       : in  std_logic;
        ones        : in  std_logic_vector(2 downto 0);
        reset       : in  std_logic;
        total_edges : out std_logic_vector(23 downto 0);
        total_ones  : out std_logic_vector(23 downto 0));
  end component;

  signal total_edges : std_logic_vector(23 downto 0) := (others => '0');
  signal total_ones  : std_logic_vector(23 downto 0) := (others => '0');
  signal new_limit   : std_logic_vector(19 downto 0) := std_logic_vector(to_unsigned(N_fast/1000-1,20));
      -- 1ms in clk ticks, assuming N_fast ticks per seconds.

  component snapshot_deltas
    generic (
        N_fast      : integer);
    port (
        clk         : in  std_logic;
        new_limit   : in  std_logic_vector(19 downto 0);
        total_edges : in  std_logic_vector(23 downto 0);
        total_ones  : in  std_logic_vector(23 downto 0);
        reset       : in  std_logic;
        delta_edges : out std_logic_vector(23 downto 0);
        delta_ones  : out std_logic_vector(23 downto 0);
        new_deltas  : out std_logic);
  end component;

  signal delta_edges : std_logic_vector(23 downto 0) := (others => '0');
  signal delta_ones  : std_logic_vector(23 downto 0) := (others => '0');

begin

------------------------------

i_rad_clocks : rad_clocks generic map (
          N_fast => N_fast
          ) port map (
          CLK_IN       => sysclk, 
          CLK_FAST     => clk,
          CLK_FASTb    => clkb,
          CLK_FAST_90  => clk_90,
          CLK_FAST_90b => clk_90b);

i_oversample : oversample Port map ( 
          clk      => clk,
          clkb     => clkb,
          clk_90   => clk_90,
          clk_90b  => clk_90b,
          sig_in   => HAM_IN,
          sample   => sample);

i_count_ones_and_edges: count_ones_and_edges port map (
          clk      => clk,
          sample   => sample,
          edges    => edges,
          ones     => ones);

i_total_counters: total_counters port map (
          clk      => clk,
          edges    => edges,
          ones     => ones,
          reset    => reset,
          total_edges => total_edges,
          total_ones => total_ones);
          
i_snapshot_deltas : snapshot_deltas generic map (
          N_fast => N_fast
          ) port map (
          clk         => clk,
          new_limit   => new_limit,
          total_edges => total_edges,
          total_ones  => total_ones,
          reset       => reset,
          delta_edges => delta_edges,
          delta_ones  => delta_ones,
          new_deltas  => PING_OUT);



LEDL <= (others => '0'); 
LEDH <= (others => '1');


clk_proc: process(clk)
        variable VAR_TPWR_COUNT : natural range 0 to 255 := 0;
    begin
        if rising_edge(clk) then
        
            if KILLT_IN = '1' then
              VAR_TPWR_COUNT := VAR_TPWR_COUNT + 1;
            end if;

            if KILLT_IN = '0' then
              VAR_TPWR_COUNT := 0;
            end if;

            if VAR_TPWR_COUNT = 250 then
              TPWR_OUT <= '0';
            end if;

--            if KILLT_IN = '1' then
--              TPWR_OUT <= '0';
--            end if;
            
--            case KILLT_IN is
--              when '1' => TPWR_OUT <= '0';
--              when others => TPWR_OUT <= '1';
--            end case;
        
            if DTOG_IN = '0' then
              DATA_OUT <= delta_edges(15 downto 0);
            else 
              DATA_OUT <= delta_ones(19 downto 4); --  20bit mod 4-bit (@ 1GHz, ==> 62.5  MHz So 16bit juuuuuust suffices at 1kHz
            end if;

            case RESET_IN is
              when '1' => reset <= '1';
              when others => reset <= '0';
            end case;
            
            case NS_SEL_IN is
              when "000"  => new_limit <= std_logic_vector(to_unsigned((N_fast / 1000) -1, 20));    --  fs =  1 kHz
              when "001"  => new_limit <= std_logic_vector(to_unsigned((N_fast / 2000) -1, 20));    --  fs =  2 kHz
              when "010"  => new_limit <= std_logic_vector(to_unsigned((N_fast / 4000) -1, 20));    --  fs =  4 kHz
              when "011"  => new_limit <= std_logic_vector(to_unsigned((N_fast / 8000) -1, 20));    --  fs =  8 kHz
              when "100"  => new_limit <= std_logic_vector(to_unsigned((N_fast /10000) -1, 20));    --  fs = 10 kHz
              when "101"  => new_limit <= std_logic_vector(to_unsigned((N_fast /16000) -1, 20));    --  fs = 16 kHz
--                      240MHz
--              when "110"  => new_limit <= std_logic_vector(to_unsigned(N_fast /24000 -1, 20));    --  fs = 24 kHz
--              when others => new_limit <= std_logic_vector(to_unsigned(N_fast /32000 -1, 20));    --  fs = 32 kHz--
--                      250MHz
              when "110"  => new_limit <= std_logic_vector(to_unsigned((N_fast /25000) -1, 20));    --  fs = 25 kHz
              when others => new_limit <= std_logic_vector(to_unsigned((N_fast /40000) -1, 20));    --  fs = 40 kHz
            end case;
        end if; -- rising_edge
    end process;
    
end Behavioral;
