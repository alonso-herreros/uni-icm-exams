----------------------------------------------------------------------
-- TEST BENCH
----------------------------------------------------------------------
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity Ej1_tb is
end Ej1_tb;

architecture Behavioural of ej1_tb is
    component ADDR_GEN_MEM is
        port (
            Clk : in std_logic;
            Reset : in std_logic;
            NewSampleIn : in std_logic;
            MemAddrBus : out unsigned(7 downto 0);
            SamplesCount : out unsigned(7 downto 0);
            EndOfMemory : out std_logic
        );
    end component;

    signal Clk:          std_logic := 0;
    signal Reset:        std_logic := 0;
    signal NewSampleIn:  std_logic;
    signal MemAddrBus:   unsigned(7 downto 0);
    signal SamplesCount: unsigned(7 downto 0);
    signal EndOfMemory:  std_logic;

begin

    UUT: ADDR_GEN_MEM
        port map(
            Clk => Clk,
            Reset => Reset,
            NewSampleIn => NewSampleIn,
            MemAddrBus => MemAddrBus,
            SamplesCount => SamplesCount,
            EndOfMemory => EndOfMemory
        );

    Clk   <= not Clk after 10 ns; -- Teacher-approved

    -- Teacher's solution
    process begin
        NewSampleIn <= '1';
        wait for 20 ns;
        NewSampleIn <= '0';
        wait for 120 ns;
    end process;

end Behavioural;
