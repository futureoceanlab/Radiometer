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
-- Created:       10/13/2019 11:43:09 AM
-- Author:        Allan Adams (awa@mit.edu)
----------------------------------------------------------------------------------
-- Description:   
--
-- Provenance:    Inspired by fast_freq_counter
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
    sysclk : in  std_logic;
    HIN    : in  std_logic;  -- Differential input -- will need to buffer
    DTOG   : in  std_logic                     := '0';  -- Select EDGES or CYCLES out via DATA
    Ns_SEL : in  std_logic_vector (2 downto 0) := "000";  -- External f_Sample
    --  out                                                  
    DATA   : out std_logic_vector (Nb-1 downto 0);      -- Accumulated Edges
    PING   : out std_logic                     := '0';  -- CALL BOYS IN FOR DINNER
    T_ON   : out std_logic :='1'
    );
end RAD_counter;


architecture Behavioral of RAD_counter is

  component rad_clock
    port (CLK      : in  std_logic;
          CLK_FAST : out std_logic;
          CLK_SLOW : out std_logic);
  end component;

  component fast_integrator
    port (VIN  : in  std_logic;
          CLK  : in  std_logic;
          VOUT : out std_logic);
  end component;

  component prescaler
    generic (N : positive);
    port (Test_Signal  : in  std_logic;
          Click_Out : out  std_logic);
  end component;

  component counter_gray4
    generic (N : positive);
    port (VIN  : in  std_logic;
          GRAY : out std_logic_vector (3 downto 0));
  end component;

  component sampler_gray4
    port (CLK    : in  std_logic;
          GRAY   : in  std_logic_vector (3 downto 0);
          SAMPLE : out std_logic_vector (3 downto 0));
  end component;

  component accumulator
    generic (Nb : positive;
             Ng : positive);
    port (CLK      : in  std_logic;
          S_EDGES  : in  std_logic_vector (Ng-1 downto 0);
          S_CYCLES : in  std_logic_vector (Ng-1 downto 0);
          NS_SEL   : in  std_logic_vector (2 downto 0);
          EDGES    : out std_logic_vector (Nb-1 downto 0);
          CYCLES   : out std_logic_vector (Nb-1 downto 0);
          PING     : out std_logic := '0');
  end component;

  component output_mux
    generic (Nb : positive);
    port (TOG    : in  std_logic := '0';
          DATA_A : in  std_logic_vector (Nb-1 downto 0);
          DATA_B : in  std_logic_vector (Nb-1 downto 0);
          DATA_O : out std_logic_vector (Nb-1 downto 0) );
  end component;

  signal cin         : std_logic;
  signal cin_ps      : std_logic;
  signal fc          : std_logic;
  signal fo          : std_logic;
  signal gray_edges  : std_logic_vector (3 downto 0);
  signal gray_cycles : std_logic_vector (3 downto 0);
  signal s_edges     : std_logic_vector (3 downto 0);
  signal s_cycles    : std_logic_vector (3 downto 0);
  signal edges       : std_logic_vector (Nb-1 downto 0);
  signal cycles      : std_logic_vector (Nb-1 downto 0);

begin


------------------------------


--  HamDiffInputBuffer : IBUFDS
--    generic map (DIFF_TERM    => false,
--                 IBUF_LOW_PWR => true,
--                 IOSTANDARD   => "DEFAULT")
--    port map (I  => HIN_P,
--              IB => HIN_N,
--              O  => hin);

  RadClock : rad_clock
    port map (CLK => sysclk,
              CLK_FAST => fc,
              CLK_SLOW => fo);

  HamInt : fast_integrator
    port map (VIN  => hin,
              CLK  => fc,
              VOUT => cin);

  Prescale : prescaler
    generic map (N => 3)
    port map (Test_Signal => cin,
              Click_Out => cin_ps);

  CountEdges : counter_gray4
    generic map (N => 4)
    port map (VIN  => hin,
              GRAY => gray_edges);

  CountCycles : counter_gray4
    generic map (N => 4)              
    port map (VIN  => cin_ps,
              GRAY => gray_cycles);

  SampleEdges : sampler_gray4
    port map (CLK    => fo,
              GRAY   => gray_edges,
              SAMPLE => s_edges);

  SampleCycles : sampler_gray4
    port map (CLK    => fo,
              GRAY   => gray_cycles,
              SAMPLE => s_cycles);

  Totals : accumulator
    generic map (Nb => Nb,
                 Ng => 4)
    port map (CLK      => fo,
              S_EDGES  => s_edges,
              S_CYCLES => s_cycles,
              Ns_SEL   => NS_SEL,
              EDGES    => edges,
              CYCLES   => cycles,
              PING     => PING);

  OutMux : output_mux
    generic map (Nb => Nb)
    port map (DATA_A => edges,
              DATA_B => cycles,
              TOG    => DTOG,
              DATA_O => DATA);


end Behavioral;
