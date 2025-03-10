----------------------------------------------------------------------
-- DESIGN
----------------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
----------------------------------------------------------------------
entity ADDR_GEN_MEM is
  port (
    Clk          : in std_logic;
    Reset        : in std_logic;
    NewSampleIn  : in std_logic;
    MemAddrBus   : out unsigned(7 downto 0);
    SamplesCount : out unsigned(7 downto 0);
    EndOfMemory  : out std_logic);
end ADDR_GEN_MEM;
----------------------------------------------------------------------
architecture Behavioural of ADDR_GEN_MEM is
  -- Answer 1.2
  signal sMemAddressRow    : in unsigned(3 downto 0);
  signal sMemAddressColumn : in unsigned(3 downto 0);
  signal sSamplesCount     : in integer range(0 to 255);
begin
  SamplesCount <= to_unsigned(sSamplesCount/2,8);
  MemAddrBus   <= sMemAddressRow & sMemAddressColumn;
  EndOfMemory  <= '1' when (sMemAddressColumn AND sMemAddressRow)= “1111” else '0';

  -- Answer: 1.1
  P1: process (Reset, Clk)
  begin
    if Reset = '1' then
      sSamplesCount <= (others => '0');
    elsif Clk'event and Clk = '1' then
      if NewSampleIn = '1' then
        if sSamplesCount = 255 then
          sSamplescount <= 0;
        else
          sSamplesCount <= sSamplesCount + 1;
        end if;
      end if;
    end if;
  end process P1;

  -- Answer: 1.1
  P2: process(Reset, Clk)
  begin
    if Reset = '1' then
      sMemAddressRow    <= (others => '0');
      sMemAddressColumn <= (others => '0');
    elsif Clk'event and Clk = '1' then
      if NewSampleIn = '1' then
        if sMemAddressColumn = "1111" then
          sMemAddressColumn <= (others => '0');
          if sMemAddressRow = "1111" then
            sMemAddressRow <= (others => '0');
          else
            sMemAddressRow <= sMemAddressRow + 1;
          end if;
        else
          sMemAddressColumn <= sMemAddressColumn + 1;
        end if;
      end if;
    end if;
  end process P2;
end Behavioural;
----------------------------------------------------------------------
-- TEST BENCH
----------------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
--
entity Ej1_tb is
end Ej1_tb;
--
architecture Behavioural of ej1_tb is
  component ADDR_GEN_MEM is
    port (
      Clk          : in std_logic;
      Reset        : in std_logic;
      NewSampleIn  : in std_logic;
      MemAddrBus   : out unsigned(7 downto 0);
      SamplesCount : out unsigned(7 downto 0);
      EndOfMemory  : out std_logic
    );
  end component;
  signal Clk          : std_logic;
  signal Reset        : std_logic;
  signal NewSampleIn  : std_logic;
  signal MemAddrBus   : unsigned(7 downto 0);
  signal SamplesCount : unsigned(7 downto 0);
  signal EndOfMemory  : std_logic;
begin
  UUT: ADDR_GEN_MEM
  port map(
    Clk          => Clk,
    Reset        => Reset,
    NewSampleIn  => NewSampleIn,
    MemAddrBus   => MemAddrBus,
    SamplesCount => SamplesCount,
    EndOfMemory  => EndOfMemory);

  -- Answer: 1.4
  process begin -- Signal not initialized, can't use clk <= not clk;
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process;
  process begin
    NewSampleIn <= '1'
    wait for 20 ns; -- Duration: 1 clock cycle
    NewSampleIn <= '0'
    wait for 100 ns; -- Total period: 120 ns
  end process;

end Behavioural;
