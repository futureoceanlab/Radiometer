library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity oversample is
    Port ( clk : in STD_LOGIC;
           sig_in : in STD_LOGIC;
           samples : out STD_LOGIC_VECTOR (3 downto 0) := "0000");
end oversample;


architecture Behavioral of oversample is

 -- Works as of 11pm Wednesday Oct 23

    signal ddr_samples : std_logic_vector(1 downto 0) := (others => '0');
begin
    -- Ready for 4:1 SERDES
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

--------------------------------------------------------
--
--component RAD_ISERDES
--  generic (
--    SYS_W       : integer := 1;
--    DEV_W       : integer := 4);
--  port  (
--    data_in_from_pins       : in    std_logic_vector(SYS_W-1 downto 0);
--    data_in_to_device       : out   std_logic_vector(DEV_W-1 downto 0);
--    bitslip                 : in    std_logic_vector(SYS_W-1 downto 0);
--    clk_in                  : in    std_logic;                    -- Fast clock from PLL/MMCM 
--    clk_div_in              : in    std_logic;                    -- Slow clock from PLL/MMCM
--    io_reset                : in    std_logic);                   -- Reset signal for IO circuit
--  end component;
--  
--  signal sig_in_vector : std_logic_vector(0 downto 0) := "0";
--  
--  begin
--
--  sig_in_vector(0) <= SIG_IN;
--
--  RAD_ISERDES_in : RAD_ISERDES port map (
--     data_in_from_pins  => sig_in_vector,
--     data_in_to_device  => SAMPLES,
--     bitslip            => (others => '0'),                           
--     clk_in             => CLK,                            
--     clk_div_in         =>     ,
--     io_reset           => '0'
--  );
--
--------------------------------------------------------

end Behavioral;


