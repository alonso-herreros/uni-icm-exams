library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity fir_tb is 
end fir_tb ; 

architecture tb of fir_tb is 
  component FIR_Serie is 
  generic(
    N    : natural := 10;
	Order: natural := 8);
  port (
    Clk      : in  std_logic; 
	Reset    : in  std_logic; 
    Enable   : in  std_logic; 
    Data_in  : in  signed (N-1 downto 0); 
    Data_out : out signed (N-1 downto 0)
  );
  signal Clk, Reset : std_logic; 
  signal Enable     : std_logic; 
  signal X          : signed (9 downto 0); 
  signal Y_s,Y_p,Y_pp: signed (9 downto 0);
  constant N: integer := 10;    
  -- Temporization
  -- N Number of bits
  constant period100M: time := 10 ns; 
  constant period10M: time := 100 ns; 
  constant period75M: time := 14 ns; 
  -- Input Data Generation
  constant Ts: time := 100 us; -- 10kHz  
  constant sawtoothPeriod1500:  time := 666 us; -- 1500Hz
  constant sawtoothPeriod1250: time := 800 us; -- 1250Hz  
  constant sawtoothPeriod750: time := 1333 us; -- 750Hz     
  
begin
 -- Stimulus 
  process -- clk generation, replace by corresponding period
  begin
    Clk <= '0'; wait for period100M/2; 
    Clk <= '1'; wait for period100M/2;     
  end process; 
  -- Sampling generation
  process 
  begin
    Enable <= '0'; 
    wait for Ts-period100M; 
    Enable <= '1'; 
	wait for period100M;
  end process; 
  -- Initialization signal generation
  process
  begin
	Reset <= '1'; 
    wait for 10*period100M; 
	wait until clk='0';
    Reset <= '0';
	wait;
  end process;
  -- Sawtooth generation
  process 
  begin  
    for j in -1024 to 1023 loop 
        X <= to_signed(j,N);
        wait for sawtoothPeriod1500/2**N ; --- replace by corresponding period  		  
    end loop;  
  end process;     
  -- Circuit to test instatiation
  C1: FIR_Serie
  port map (
    Clk      => Clk,
    Reset    => Reset,
    Enable   => Enable,
    Data_in  => X,
    Data_out => Y_s); 
 end tb; 

