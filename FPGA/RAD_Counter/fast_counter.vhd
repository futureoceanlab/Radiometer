----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        fast_counter (Behavioral)
-- Filename:      fast_counter.vhd
-- Created:       19/10/2019
-- Author:        Allan Adams <awa@mit.edu>
----------------------------------------------------------------------------------
-- Based on fast_freq_counter by Mike Field <hamster@snap.net.nz>
----------------------------------------------------------------------------------
-- Description:   Wrap Count_gray and Sample_gray inside a single unit
-- 
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- library UNISIM;
-- use UNISIM.VComponents.all;


entity fast_counter is
  port (
    SIGNAL_IN  : in  std_logic;
    CLK_IN     : in  std_logic;
    SAMPLE_OUT : out std_logic_vector (3 downto 0)
    );
end fast_counter;


architecture Behavioral of fast_counter is

  attribute ASYNC_REG : string;
  signal gray_wire : std_logic_vector (3 downto 0) := (others => '0');
  attribute ASYNC_REG of gray_wire : signal is "true";

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

begin

  CountGray : counter_gray4
    generic map (N => 4)
    port map (VIN  => SIGNAL_IN,
              GRAY => gray_wire);

  SampleGray : sampler_gray4
    port map (CLK    => CLK_IN,
              GRAY   => gray_wire,
              SAMPLE => SAMPLE_OUT);

end Behavioral;

