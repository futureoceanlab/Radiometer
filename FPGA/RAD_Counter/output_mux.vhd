----------------------------------------------------------------------------------
--
-- Description: Accumulate 32,000,000 -bit values
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity output_mux is
  generic (
    Nb  : positive    -- Bits per output Variable
    );
  port (
    -- IN
    TOG     : in std_logic := '0'; -- 0 for DATA_A, 1 for DATA_B
    DATA_A  : in std_logic_vector (Nb-1 downto 0);
    DATA_B  : in std_logic_vector (Nb-1 downto 0);
    -- OUT
    DATA_O  : out std_logic_vector (Nb-1 downto 0)
    );

end output_mux;

architecture Behavioral of output_mux is
begin
  DATA_O <= DATA_A when (TOG = '0') else DATA_B;    
end Behavioral;

