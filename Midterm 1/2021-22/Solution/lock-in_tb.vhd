library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 
use ieee.math_real.all;

entity LOCK_IN_TB is
end LOCK_IN_TB;

architecture TB of LOCK_IN_TB is 

  component LOCK_IN
  port (  
    Clk        : in  std_logic;
    Reset      : in  std_logic;
    ADC_ready  : in  std_logic;
    ADC_in     : in  unsigned(13 downto 0);
    Ref_in     : in  signed(13 downto 0); 
    Data_out   : out signed(23 downto 0) );
  end component;

  signal tb_Clk       : std_logic;
  signal tb_Reset     : std_logic;
  signal tb_ADC_ready : std_logic;
  signal tb_ADC_in    : unsigned(13 downto 0);
  signal tb_Ref_in    : signed(13 downto 0); 
  signal tb_Data_out  : signed(23 downto 0);

  constant semicycle: time := 5 us;
  constant cycle: time := 2*semicycle;

  constant Ts: time := 1 ms;
  constant freq: real := 100.0;
  constant fs: real := 1000.0;
  signal isin: integer := 0; 
  
begin

  tb_ADC_in <= to_unsigned(isin+8192,14);
  tb_Ref_in <= to_signed(isin,14); 

  process
    variable steps: real := 0.0;
    variable angle: real; 
  begin
    wait until tb_ADC_ready='1';
    angle := MATH_2_PI*steps*freq/fs  ;
    isin <= integer ( 4096.0*sin(angle) ); 
    steps := steps + 1.0; 
  end process; 

  process
  begin
    tb_ADC_ready <= '0'; wait for 2*cycle;
    tb_ADC_ready <= '1'; wait for cycle;
    tb_ADC_ready <= '0'; wait for Ts-3*cycle;
  end process; 

  tb_Reset <= '1', '0' after 2*cycle;
  process
  begin
    tb_Clk <= '0'; wait for semicycle;
    tb_Clk <= '1'; wait for semicycle;
  end process; 

  UUT: LOCK_IN
  port map(  
    Clk       => tb_Clk      ,
    Reset     => tb_Reset    ,
    ADC_ready => tb_ADC_ready,
    ADC_in    => tb_ADC_in   ,
    Ref_in    => tb_Ref_in   ,
    Data_out  => tb_Data_out 
  );

end TB;
