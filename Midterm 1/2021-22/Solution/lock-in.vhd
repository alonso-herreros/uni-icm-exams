library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package constants is
  constant nBits: integer := 6; 
  constant factor: integer := 2**(nBits-1);
  type constantT is array (0 to 7)  of signed(5 downto 0);
  constant aC : constantT := (
    to_signed( integer(real(factor)*0.0646), 6),
    to_signed( integer(real(factor)*0.1118), 6),
    to_signed( integer(real(factor)*0.1508), 6),
    to_signed( integer(real(factor)*0.1728), 6), 
    to_signed( integer(real(factor)*0.1728), 6),
    to_signed( integer(real(factor)*0.1508), 6),
    to_signed( integer(real(factor)*0.1118), 6),
    to_signed( integer(real(factor)*0.0646), 6) );
end package;  

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.constants.all; 

entity LOCK_IN is 
  port (  
    Clk        : in  std_logic;
    Reset      : in  std_logic;
    ADC_ready  : in  std_logic;
    ADC_in     : in  unsigned(13 downto 0);
    Ref_in     : in  signed(13 downto 0); 
    Data_out   : out signed(23 downto 0) );
end LOCK_IN;

architecture BEHAVIORAL of LOCK_IN is

  signal ADC_in_sg: signed(13 downto 0); 

  type datainT is array (natural range <>)  of signed(27 downto 0); 
  signal sX: datainT(0 to 7);

  type internalT is array (natural range <>)  of signed(23 downto 0); 
  signal temp: internalT(0 to 7);

  signal LoadOut: std_logic; 
  
begin

  -- Choose one:
  ADC_in_sg <= signed((not ADC_in(13)) & ADC_in(12 downto 0));
  ADC_in_sg <= signed(ADC_in) - 2**13;
  ADC_in_sg <= to_signed(to_integer(ADC_in) - 2**13,14);    

  process(Clk,Reset)
  begin
    if Reset='1' then
      sX <= (others => to_signed(0,14));
      LoadOut <= '0';
      Data_Out <= (others=>'0');      
    elsif rising_edge(Clk) then
      if ADC_ready='1' then
        LoadOut <= '1';       
        sX(0) <= ADC_in_sg*Ref_in;
        for i in 1 to 7 loop
          sX(i) <= sX(i-1);
        end loop; 
      else
        LoadOut <= '0';       
      end if;
      if LoadOut = '1' then
        Data_Out <= temp(7);
      end if; 
    end if;
  end process;

  process(temp,sX)
  begin
    temp(0) <= resize(aC(0)*sX(0)*Ref_in,24); 
    for i in 1 to 7 loop 
      temp(i) <= temp(i-1) + aC(i)*sX(i);
    end loop; 
  end process; 
  

end BEHAVIORAL;

