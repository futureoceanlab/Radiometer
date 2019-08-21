----------------------------------------------------------------------------------
--
-- Description: Count rising edges, and output as a Gray count.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fast_integrator is
  Port (
    VIN  : in  STD_LOGIC; -- Logic Level in
    CLK  : in  STD_LOGIC; -- Clock (fast) in
    VOUT : out STD_LOGIC -- Logic Level Out
    );
end fast_integrator;


architecture Behavioral of fast_integrator is
begin
  VOUT <= VIN and CLK; 
end Behavioral;
