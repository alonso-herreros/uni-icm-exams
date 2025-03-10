library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity problem2 is
  generic(W:integer:=128);
  port (
    Clk      : in std_logic;
    rst      : in std_logic;
    Data_in  : in unsigned(7 downto 0);
    R_ready  : out std_logic;
    Data_out : out unsigned(23 downto 0));
end problem2;

architecture Behavioral of problem2 is

  signal cnt_0       : unsigned(7 downto 0);
  signal cnt_1       : unsigned(7 downto 0);
  signal Inner_sum   : unsigned(16 downto 0);
  signal Squared_sum : unsigned(32 downto 0);
  signal Accumulator : unsigned(39 downto 0);
  signal Counter     : unsigned(6 downto 0);
  signal Counter_end : std_logic;

  constant L0        : unsigned(7 downto 0) := to_unsigned(166, 8);
  constant L1        : unsigned(7 downto 0) := to_unsigned(100, 8);

begin

  P_Capture: process (Clk, rst) begin
    if rst = '1' then
      cnt_0 <= (others => '0');
      cnt_1 <= (others => '0');
    elsif rising_edge(clk) then
      cnt_1 <= cnt_0;
      cnt_0 <= Data_in;
    end if;
  end process;

  -- Ops1
  Inner_sum <= L0 * cnt_0 + L1 * cnt_1;
  Squared_sum <= Inner_sum * Inner_sum;

  P_Accumulator: process (Clk, rst) begin
    if rst = '1' then
      Accumulator <= (others => '0');
    elsif rising_edge(clk) then
      Accumulator <= Accumulator + Squared_sum;
    end if;
  end process;

  P_OutBuffer: process (Clk, rst) begin
    if rst = '1' then
      Data_out <= (others => '0');
    elsif rising_edge(clk) and Counter_end = '1' then
      Data_out <= Accumulator(39 downto 16); -- Shift right by 16 bits
    end if;
  end process;

  P_Counter: process (Clk, rst) begin
    if rst = '1' then
      Counter <= (others => '0');
    elsif rising_edge(clk) and Counter_end /= '1' then
      Counter <= Counter + 1;
    end if;
  end process;

  Counter_end <= '1' when Counter = to_unsigned(127,7) else '0';

end Behavioral;
