----------------------------------------------------------------------------------
--     MIT Future Ocean Lab
----------------------------------------------------------------------------------
-- Project:       FOL Radiometer
-- Version:       Beebe
-- Design:        RAD_Counter
-- Substrate:     CMod A7 
----------------------------------------------------------------------------------
-- Module:        RAD_Testbench (Behavioral)
-- Filename:      RAD_Testbench.vhd
-- Created:       18/8/2019
-- Author:        Allan Adams <awa@mit.edu>
----------------------------------------------------------------------------------
-- Description:   
-- 
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library ieee;
use ieee.math_real.all;

entity Rad_Testbench is
end Rad_Testbench;

architecture Behavioral of Rad_Testbench is
  component RAD_counter
    generic (
        Nb : positive
    );
    port (
      -- in
      sysclk    : in  std_logic;
      HAM_IN    : in  std_logic;  -- Differential input -- will need to buffer
      DTOG_IN   : in  std_logic;        -- Select EDGES or CYCLES out via DATA
      Ns_SEL_IN : in  std_logic_vector (2 downto 0);     -- External f_Sample
      --  out                                                  
      DATA_OUT  : out std_logic_vector (Nb-1 downto 0);  -- Accumulated Edges
      PING_OUT  : out std_logic;        -- CALL BOYS IN FOR DINNER
      TPWR_OUT  : out std_logic
      );
  end component;

  signal sysclk_tb : std_logic                     := '0';
  signal HIN_tb    : std_logic                     := '1';
  signal DTOG_tb   : std_logic                     := '0';
  signal Ns_SEL_tb : std_logic_vector (2 downto 0) := "000";
  signal DATA_tb   : std_logic_vector (19 downto 0);
  signal PING_tb   : std_logic;
  signal T_ON_tb   : std_logic;
  signal GATE_tb   : std_logic                     := '0';
  signal rand_delay_tb : integer := 20;
  signal time_high_tb : integer :=0;

begin

  UUT : RAD_counter 
    generic map ( Nb => DATA_tb'length)
    port map (
    sysclk    => sysclk_tb,
    HAM_IN    => HIN_tb,
    DTOG_IN   => DTOG_tb,
    PING_OUT  => PING_tb,
    TPWR_OUT  => T_ON_tb,
    Ns_SEL_IN => Ns_SEL_tb,
    DATA_OUT  => DATA_tb
    );
    
    
    
    process
        variable seed1, seed2: positive;               -- seed values for random generator
        variable rand: real;   -- random real-number value in range 0 to 1.0  
        variable range_of_rand : real := 79.0;    -- the range of random values created will be 0 to +79.
    begin
        uniform(seed1, seed2, rand);   -- generate random number
        rand_delay_tb <= integer(20.0 + (80.0/(1.0+(rand*range_of_rand))));  -- rescale to 0..1000, convert integer part 
        wait for 20 ns;
    end process;


  sysclk_tb <= not sysclk_tb after 41.667 ns;
--  GATE_tb <= not GATE_tb after 110ns;
--  HIN_tb <= not (HIN_tb and GATE_tb) after 20ns;
--
--  HIN_tb    <= not HIN_tb    after 20ns;
--
  HIN_tb <= not HIN_tb after rand_delay_tb * 1 ns;

  DTOG_tb   <= PING_tb;  -- read different registers when asserted or not.
  Ns_Sel_tb <= "001"         after 4000000ns;  -- 4ms

end Behavioral;
