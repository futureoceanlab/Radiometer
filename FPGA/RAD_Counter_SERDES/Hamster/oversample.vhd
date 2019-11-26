library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity oversample is
    Port ( clk : in STD_LOGIC;
           sig_in : in STD_LOGIC;
           samples : out STD_LOGIC_VECTOR (3 downto 0));
end oversample;

architecture Behavioral of oversample is
    signal ddr_samples : std_logic_vector(1 downto 0) := (others => '0');
begin
    -- Ready for 4:! SERDES
    samples <= ddr_samples(1) & ddr_samples(1) & ddr_samples(0) & ddr_samples(0);
       
IDDR_inst : IDDR 
   generic map (
      DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE", "SAME_EDGE" 
      INIT_Q1 => '0', -- Initial value of Q1: '0' or '1'
      INIT_Q2 => '0', -- Initial value of Q2: '0' or '1'
      SRTYPE => "SYNC") -- Set/Reset type: "SYNC" or "ASYNC" 
   port map (
      Q1 => ddr_samples(0), -- 1-bit output for positive edge of clock 
      Q2 => ddr_samples(1), -- 1-bit output for negative edge of clock
      C => Clk,   -- 1-bit clock input
      CE => '1', -- 1-bit clock enable input
      D => sig_in,   -- 1-bit DDR data input
      R => '0',   -- 1-bit reset
      S => '0'    -- 1-bit set
      );

end Behavioral;
