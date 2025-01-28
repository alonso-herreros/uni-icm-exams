library IEEE;
use IEEE.std_logic_1164.all;

entity CIRCUITO is 
  port (  
    Clk    : in  std_logic;
    Reset  : in  std_logic;
    Valid  : in  std_logic;
    IsOpen : out std_logic);
end CIRCUITO;

architecture BEHAVIORAL of CIRCUITO is
  type     tStates is (s0, ok1, ok2, err);
  signal   CurrentState : tStates;
  signal   NextState    : tStates;
  constant cTopTimer    : natural := 18;
  signal   Timer1       : natural range 0 to cTopTimer;
  signal   EnaT         : std_logic; 
begin

  P1: process(Clk, Reset)
  begin
    if Reset = '1' then
      CurrentState <= s0;
    elsif Clk'event and Clk = '1' then
      CurrentState <= NextState;
    end if;
  end process P1;
  
  P2: process(CurrentState, Timer1, Valid)
  begin
    EnaT <= '1';
    IsOpen <= '0';    
    case CurrentState is
      when s0 =>
        if Valid = '1' AND Timer1 = cTopTimer then
          NextState <= ok1;
        else
          NextState <= s0;
        end if;
      when ok1 =>
        if Valid = '0' then
          NextState <= s0;
        elsif Timer1 = cTopTimer then
          NextState <= ok2;
        else
          NextState <= ok1;
        end if;
      when ok2 =>
        IsOpen <= '1';      
        if Valid = '0' then
          NextState <= err;
        elsif Timer1 = cTopTimer then
          NextState <= s0;
        else
          NextState <= ok2;
        end if;
      when err =>
        EnaT <= '0';       
        if Valid = '1' then
          NextState <= s0;
        else
          NextState <= err;
        end if;
    end case;
  end process P2;

  P3: process(Clk, Reset)
  begin
    if Reset = '1' then
      Timer1 <= 0;
    elsif Clk'event and Clk = '1' then
      if EnaT = '1' then
        if Timer1 = cTopTimer then
          Timer1 <= 0; 
        else
          Timer1 <= Timer1 + 1; 
        end if;
      end if;
    end if;
  end process P3;
end BEHAVIORAL;
