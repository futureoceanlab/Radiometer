----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Module Name:    fast_freq_counter - Behavioral 
--
-- Description: A fast frequency counter, wiht USB output--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library unisim;
use unisim.vcomponents.all;

entity fast_freq_counter is
    Port ( clk32         : in  STD_LOGIC;
           test_signal_p : in  STD_LOGIC;
           test_signal_n : in  STD_LOGIC;
           tx            : out STD_LOGIC);
end fast_freq_counter;

architecture Behavioral of fast_freq_counter is
   component test_clock port (
      CLK_32in : in     std_logic;
      CLK_32   : out    std_logic;
      CLK_TEST : out    std_logic
   );
   end component;

   COMPONENT input_counter
   PORT(
      test_signal : IN std_logic;          
      gray_count : OUT std_logic_vector(4 downto 0)
      );
   END COMPONENT;

   COMPONENT sampler
   PORT(
      clk : IN std_logic;
      gray_count : IN std_logic_vector(4 downto 0);          
      jump : OUT std_logic_vector(4 downto 0)
      );
   END COMPONENT;

   COMPONENT accumulator
   PORT(
      clk       : IN  std_logic;
      jump      : IN  std_logic_vector(4 downto 0);          
      total     : OUT std_logic_vector(29 downto 0);
      new_total : OUT std_logic
      );
   END COMPONENT;

   COMPONENT binary_bcd
   PORT(
      clk         : IN std_logic;
      new_binary  : IN std_logic;
      binary      : IN std_logic_vector(29 downto 0);          
      d8          : OUT std_logic_vector(3 downto 0);
      d7          : OUT std_logic_vector(3 downto 0);
      d6          : OUT std_logic_vector(3 downto 0);
      d5          : OUT std_logic_vector(3 downto 0);
      d4          : OUT std_logic_vector(3 downto 0);
      d3          : OUT std_logic_vector(3 downto 0);
      d2          : OUT std_logic_vector(3 downto 0);
      d1          : OUT std_logic_vector(3 downto 0);
      d0          : OUT std_logic_vector(3 downto 0);
      new_decimal : OUT std_logic
      );
   END COMPONENT;

   COMPONENT output_uart
   PORT(
      clk : IN std_logic;
      d8 : IN std_logic_vector(3 downto 0);
      d7 : IN std_logic_vector(3 downto 0);
      d6 : IN std_logic_vector(3 downto 0);
      d5 : IN std_logic_vector(3 downto 0);
      d4 : IN std_logic_vector(3 downto 0);
      d3 : IN std_logic_vector(3 downto 0);
      d2 : IN std_logic_vector(3 downto 0);
      d1 : IN std_logic_vector(3 downto 0);
      d0 : IN std_logic_vector(3 downto 0);
      new_decimal : IN std_logic;          
      tx : OUT std_logic
      );
   END COMPONENT;

   signal test_signal                : std_logic;
   signal gray_count                 : std_logic_vector(4 downto 0);          
   signal jump                       : std_logic_vector(4 downto 0);
   signal total                      : std_logic_vector(29 downto 0);
   signal new_total,new_decimal      : std_logic;
   signal d8,d7,d6,d5,d4,d3,d2,d1,d0 : std_logic_vector(3 downto 0);

begin

  -- Input buffer
i_IBUFDS : IBUFDS
   generic map (
      DIFF_TERM => FALSE,
      IBUF_LOW_PWR => TRUE,
      IOSTANDARD => "DEFAULT")
   port map (
      O  => test_signal,
      I  => test_signal_p,
      IB => test_signal_n
   );
   
i_input_counter: input_counter PORT MAP(
      test_signal => test_signal,
      gray_count => gray_count
   );

i_sampler: sampler PORT MAP(
      clk => clk32,
      gray_count => gray_count,
      jump => jump
   );

i_accumulator: accumulator PORT MAP(
      clk       => clk32,
      jump      => jump,
      total     => total,
      new_total => new_total
   );

i_binary_bcd: binary_bcd PORT MAP(
      clk        => clk32,
      new_binary => new_total,
      binary     => total,
      d8         => d8,
      d7         => d7,
      d6         => d6,
      d5         => d5,
      d4         => d4,
      d3         => d3,
      d2         => d2,
      d1         => d1,
      d0         => d0,
      new_decimal => new_decimal
   );

i_output_uart : output_uart PORT MAP(
      clk        => clk32,
      d8         => d8,
      d7         => d7,
      d6         => d6,
      d5         => d5,
      d4         => d4,
      d3         => d3,
      d2         => d2,
      d1         => d1,
      d0         => d0,
      new_decimal => new_decimal,
      tx         => tx
   );

end Behavioral;