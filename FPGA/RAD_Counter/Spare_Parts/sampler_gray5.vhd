----------------------------------------------------------------------------------
--
-- Description: Sample the graycode count and convert back to binary
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;


entity sampler_gray5 is
  Port (
    CLK    : in  STD_LOGIC;
    GRAY   : in  STD_LOGIC_VECTOR (4 downto 0);
    SAMPLE : out STD_LOGIC_VECTOR (4 downto 0)
    );
end sampler_gray5;


architecture Behavioral of sampler_gray5 is
  signal samples : std_logic_vector(19 downto 0) := (others => '0');
    --  FIFO stack of four 5-bit gray samples. This allows registers from the 
    --  fast Gray counter to settle down before tying them to the clock.
  signal sample4    : std_logic_vector(4 downto 0); -- 4th in stack (bin)
  signal sample3  : std_logic_vector(4 downto 0); --  3rd in stack (bin)
  
  COMPONENT gray_to_bin_5  -- External component translating gray5 to bin5 
    PORT(
      gray   : in std_logic_vector(4 downto 0);          
      binary : out std_logic_vector(4 downto 0)
      );
  END COMPONENT;

begin

  gray_to_bin_last : gray_to_bin_5 port map(
    gray   => samples(19 downto 15),
    binary => sample4
    );

  gray_to_bin_recent : gray_to_bin_5 port map(
    gray   => samples(14 downto 10),
    binary => sample3
    );

  process(CLK)
  begin
    if rising_edge(CLK) then
      SAMPLE  <= std_logic_vector(unsigned(sample3) - unsigned(sample4));
      samples <= samples(14 downto 0) & GRAY;
    end if;
  end process;

end Behavioral;

