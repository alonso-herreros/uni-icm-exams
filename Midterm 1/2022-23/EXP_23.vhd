-- MidTerm VHDL exam
-- 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity EXP_23 is
  port (
    Clk     : in  std_logic;
    Reset   : in  std_logic;
    Enable  : in  std_logic;
    DataIn  : in  signed(7 downto 0);
    DataOut : out signed (9 downto 0));
end EXP_23;

architecture Behavioral of EXP_23 is
  -- Input data will range from -128 to 127 in CA2 representation
  -- (which matches with the range from -1 to 1)
  -- 2 bits por whole part and 6 bits for decimal part are required
  signal RegDataIn  : signed( 7 downto 0);
  -- Powers of DataIn will be truncated to 8 bits.
  -- As DataIn has 2 bits of whole part, the truncation should be done
  -- from bit 13 in X^2 and from bit 19 in X^3
  signal sDataTo2   : signed(15 downto 0);
  signal sDataTo3   : signed(23 downto 0);
  type tCoef is array (1 to 3) of signed(7 downto 0);
  -- Coef1: 1; 
  -- Coef2: 0.5;
  -- Coef3: 0.1666666;
  -- Nb bits: 8 ==> K < log2(127/1) = 7 
  -- K must be 6. Comma is between bit 7 and 6. 
  -- (2 bits for whole part, 6 bits for decimal part)
  -- Coef1_n :  64
  -- Coef2_n :  32
  -- Coef3_n :  10
  constant cCoef : tCoef :=
    (to_signed(64,8),
     to_signed(32,8),
     to_signed(10,8));
  -- 
  subtype stMult is signed(15 downto 0);
  type tMult is array (0 to 3) of stMult;
  signal sMult        : tMult;
  subtype stAddL1 is signed(16 downto 0);
  type tAddL1 is array (0 to 1) of stAddL1;
  signal sAddL1_Array : tAddL1;
  subtype stResult is signed (17 downto 0);
  signal  Result : stResult;
  -- Result should have 18 bits, but we only need 15
  -- if input data is coded = -128 , result will be -13,568
  -- which require 15 bits (CA2)
  -- Therefore, output data (10 bits) will take bits
  -- from 14 to 5
  -- DataOut will be converted to real value by 
  -- dividing the integer value (8bits) by 128 (2^7)
  -- because whole part needs 3 bits (CA2) (-4,3)
  -- although output values will be always positive
  -- and in ]0.36784;2.71828] range (input data between [-1,1]
begin
  process(Clk, Reset)
  begin
    if Reset = '1' then
      RegDataIn <= (others => '0');
    elsif Clk'event and Clk = '1' then
      if Enable = '1' then
        RegDataIn <= DataIn;
      end if;
    end if;
  end process; 
  sMult(0) <= to_signed((1*(2**12)),16);                                            -- 1
  sMult(1) <= to_signed(to_integer(cCoef(1))*to_integer(RegDataIn),16);             -- X
  sDataTo2 <= RegDataIn*RegDataIn;
  sMult(2) <= to_signed(to_integer(cCoef(2))*to_integer(sDataTo2(13 downto 6)),16); -- (X^2)/2!
  sDataTo3 <= RegDataIn*sDataTo2;
  sMult(3) <= to_signed(to_integer(cCoef(3))*to_integer(sDataTo3(19 downto 12)),16); -- (X^3)/3!
  process(sMult)
  begin
    for I in 0 to 1 loop
      sAddL1_Array(I) <= resize(sMult(2*I),17) + resize(sMult(2*I+1),17);
    end loop;
  end process;
  Result          <=  resize(sAddL1_Array(0),18) + resize(sAddL1_Array(1),18);
  process(Clk, Reset)
  begin
    if Reset = '1' then
      DataOut <= (others => '0');
    elsif Clk'event and Clk = '1' then
      if Enable = '1' then
        DataOut <= Result(14 downto 5);
      end if;
    end if;
  end process;  
end Behavioral;
