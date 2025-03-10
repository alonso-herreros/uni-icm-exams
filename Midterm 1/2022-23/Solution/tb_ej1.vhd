library IEEE;
use IEEE.std_logic_1164.all;

entity TB is
end TB;

architecture Struct of TB is
  constant cDataWidth    : natural := 8;          -- bits for Data
  constant cTotalNumBit  : natural := 11;         -- word width = start(1) + data(8) + parity(1) + stop(1)
  constant cBaudRate     : natural := 57600;      -- bps
  constant cClkFrequency : natural := 100000000; -- Hz
  constant cClkPeriod    : time    := 10 ns;
  constant cClkHalfPer   : time    :=  5 ns;
  component RS232_Tx is 
  generic(
    gDataWidth      : natural := 8;          -- bits for Data
	gTotalNumBit    : natural := 11;         -- word width = start(1) + data(8) + parity(1) + stop(1)
	gBaudRate       : natural := 57600;      -- bps
	gClkFrequency   : natural := 100000000); -- Hz
  port(
    Clk             : in  std_logic;
    ResetN          : in  std_logic;
    RSDataToSend    : in  std_logic_vector(gDataWidth - 1 downto 0);
    EnableSend      : in  std_logic;
    TxD             : out std_logic;
    TxBusy          : out std_logic
  );
  end component;
  signal Clk             : std_logic := '0';
  signal ResetN          : std_logic;
  signal RSDataToSend    : std_logic_vector(cDataWidth - 1 downto 0);
  signal EnableSend      : std_logic;
  signal TxD             : std_logic;
  signal TxBusy          : std_logic;
begin

  C1: RS232_Tx
  generic map(
    gDataWidth    => cDataWidth,   
    gTotalNumBit  => cTotalNumBit, 
    gBaudRate     => cBaudRate,    
    gClkFrequency => cClkFrequency)
  port map(
    Clk             => Clk,
    ResetN          => ResetN,
    RSDataToSend    => RSDataToSend,
    EnableSend      => EnableSend,
    TxD             => TxD,
    TxBusy          => TxBusy);

  Clk <= NOT(Clk) after cClkHalfPer;
  process
  begin
    ResetN       <= '1';
	EnableSend   <= '0';
	RSDataToSend <= (others => '0');
	wait for 5*cClkPeriod;
	ResetN <= '0';
	wait for 15*cClkPeriod;
	ResetN <= '1';
	wait for 10*cClkPeriod;
	RSDataToSend <= x"AA";
	EnableSend   <= '1';
	wait for cClkPeriod;
	EnableSend   <= '0';
	wait for 20000*cClkPeriod;
	RSDataToSend <= x"55";
	EnableSend   <= '1';
	wait for cClkPeriod;
	EnableSend   <= '0';
	wait for 20000*cClkPeriod;
	RSDataToSend <= x"FF";
	EnableSend   <= '1';
	wait for cClkPeriod;
	EnableSend   <= '0';
	wait for 20000*cClkPeriod;	
    RSDataToSend <= x"00";
	EnableSend   <= '1';
	wait for cClkPeriod;
	EnableSend   <= '0';
	wait for 20000*cClkPeriod;
	assert false
	  report "End of Simulation"
	    severity Failure;
  end process;  
end Struct;	
	