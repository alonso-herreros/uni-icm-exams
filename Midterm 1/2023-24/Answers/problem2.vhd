entity problem2 is
  generic(W:integer:=128);
  port (
    Clk      : in std_logic;
    rst      : in std_logic;
    Data_in  : in unsigned(7 downto 0);
    R_ready  : out std_logic;
    Data_out : out unsigned(24 downto 0));
end problem2;

architecture Behavioral of problem2 is

  signal Data_last   : unsigned(7 downto 0);
  signal Inner_sum   : unsigned(16 downto 0);
  signal Squared_sum : unsigned(32 downto 0);
  signal Accumulator : unsigned(39 downto 0);
  signal Counter     : unsigned(6 downto 0);
  signal Counter_end : std_logic;

  constant L0        : unsigned(7 downto 0) := to_unsigned(166, 8);
  constant L1        : unsigned(7 downto 0) := to_unsigned(100, 8);

begin

  process (Clk, rst) begin
    if rst = '1' then
      Data_last <= (others => '0');
    elsif rising_edge(clk) then
      Data_last <= Data_in;
    end if;
  end process;

end Behavioral;
