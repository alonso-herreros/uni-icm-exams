library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Tb_Exp23 is
end Tb_Exp23;

architecture Behavioral of Tb_Exp23 is
  component EXP_23 is
  port (
    Clk     : in  std_logic;
    Reset   : in  std_logic;
    Enable  : in  std_logic;
    DataIn  : in  signed(7 downto 0);
    DataOut : out signed(9 downto 0));
  end component;
  signal Clk       : std_logic := '0';
  signal Reset     : std_logic;
  signal Enable    : std_logic;
  signal DataIn    : signed(7 downto 0);
  signal DataOut   : signed(9 downto 0);
  constant cPeriod : time := 10 us;
  constant cHalfP  : time :=  5 us;
begin
  C1: EXP_23
  port map(
    Clk     => Clk,
    Reset   => Reset,
    Enable  => Enable,
    DataIn  => DataIn,
    DataOut => DataOut);

  Clk <= NOT(Clk) after cHalfP;
  
  process
  begin
    Reset  <= '0';
	Enable <= '0';
	DataIn <= (others => '0');
	wait for 5*cPeriod;
	Reset  <= '1';
	wait for 15*cPeriod;
	Reset  <= '0';
	wait for 10*cPeriod;
	DataIn <= x"40"; -- Dato = 1 (rango máximo)
	Enable <= '1';
	wait for cPeriod;
	Enable <= '0';
	wait for 100*cPeriod;
	DataIn <= x"C0"; -- Dato = -1 (rango mínimo)
	Enable <= '1';
	wait for cPeriod;
	Enable <= '0';
	wait for 100*cPeriod;
	DataIn <= x"00";  -- Dato = 0
	Enable <= '1';
	wait for cPeriod;
	Enable <= '0';
	wait for 100*cPeriod;
	Enable <= '1';
	wait for cPeriod;
	Enable <= '0';
	wait for 100*cPeriod;
	assert false
	  report "End of Simulation"
	    severity Failure;	
  end process;
   
end Behavioral;
