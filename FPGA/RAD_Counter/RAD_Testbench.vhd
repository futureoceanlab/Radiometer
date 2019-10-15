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
-- Created:       10/13/2019 11:43:09 AM
-- Author:        Allan Adams (awa@mit.edu)
----------------------------------------------------------------------------------
-- Description:   
-- 
-- Dependencies: 
-- 
-- Issues:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity Rad_Testbench is
  generic (
  Nb : positive := 16
  );
--  Port ( );
end Rad_Testbench;

architecture Behavioral of Rad_Testbench is
    component RAD_counter
          port (
            -- in
            sysclk   : in  std_logic;
            HIN    : in  std_logic;  -- Differential input -- will need to buffer
            DTOG   : in  std_logic;  -- Select EDGES or CYCLES out via DATA
            Ns_SEL : in  std_logic_vector (2 downto 0);  -- External f_Sample
            --  out                                                  
            DATA   : out std_logic_vector (Nb-1 downto 0);      -- Accumulated Edges
            PING   : out std_logic;  -- CALL BOYS IN FOR DINNER
            T_ON   : out std_logic
            );    
    end component;

     signal sysclk_tb : std_logic :='0';
     signal HIN_tb  : std_logic :='1'; 
     signal DTOG_tb : std_logic :='0'; 
     signal Ns_SEL_tb :  std_logic_vector (2 downto 0) := "000";
     signal DATA_tb : std_logic_vector (15 downto 0);
     signal PING_tb : std_logic;
     signal T_ON_tb : std_logic;
     signal GATE_tb : std_logic :='0';

begin

    UUT: RAD_counter port map (
        sysclk   =>  sysclk_tb,
        HIN    =>  HIN_tb,
        DTOG   =>  DTOG_tb, 
        PING   =>  PING_tb,
        T_ON   =>  T_ON_tb,
        Ns_SEL =>  Ns_SEL_tb,
        DATA   =>  DATA_tb
    );
    
    
    sysclk_tb <= not sysclk_tb after 41.667 ns;
    GATE_tb <= not GATE_tb after 110ns;
    HIN_tb <= not (HIN_tb and GATE_tb) after 20ns;
    DTOG_tb <= not DTOG_tb after 500000ns; -- 0.5ms
    Ns_Sel_tb <= "001" after 8000000ns; -- 8ms
    
end Behavioral;
