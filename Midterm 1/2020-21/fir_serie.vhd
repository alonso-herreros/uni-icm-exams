-- Solution for mid-term VHDL Exam
-- FIR 7A
-- Celia Lopez  Ongil

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity FIR_Serie is 
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
  end FIR_Serie ; 

architecture Behavioural of FIR_Serie is 
  -- Data input buffer
  type data1 is array (0 to Order-1) of signed(N-1 downto 0);
  signal aX         : data1;  
  -- Coeff with 10 bits A2complement
  -- Original values
  -- a0= 0.04727 a1= 0.00000 a2= - 0.11600 a3= 0.56873
  -- a4= 0.56873 a5= - 0.11600 a6= 0.00000 a7= 0.04727
  -- K calculation: K <= log2(max(aj)/512 = 9 
  -- Every coefficient is multiplied by 2^9 (512) and only the whole number is taken
  constant cCoefs   : data1 := ( 
    to_signed(  24,N), 
	to_signed(   0,N), 
	to_signed( -59,N), 
	to_signed( 291,N), 
	to_signed( 291,N), 
	to_signed( -59,N), 
	to_signed(   0,N), 
	to_signed(  24,N));  
  -- Counter to execute the serial calculation of the filter equation  
  signal  Sel       : natural range 0 to Order; 
  -- Operands for the multiplication (coefficient and data) which change in every step
  signal  S1        : signed(N-1 downto 0); 
  signal  S2        : signed(N-1 downto 0); 
  -- Accumulator for partial and final result in the serial operation
  -- Only 21 bits are needed
  signal  Accum : signed(20 downto 0);
begin
  -------------------------------------------------------------------------------------------
  -- DataOut generation
  -- Taking positive coefficients multiply by 511 + negative coefficients multiplied 
  -- by -512, maximum possible input data
  -- the maximum result will be 382,346 which can be represented with 20 bits in CA2
  -- (19 downto 0).
  -- Valid data are from bit 20. Only 10 bits are taken, according to specifications --> 
  -- (19 downto 10)
  -- Bit 21 is discarded as the coefficients are not large enough to provoke 
  -- results reaching this bit
  process(Clk,Reset)
  begin
    if Reset='1' then 
      Data_out <= (others=>'0'); 
    elsif rising_edge(Clk) then 
      if Sel = Order then 
        Data_out <= Accum(19 downto 10); ---division 
      end if;
    end if;
  end process;
  -------------------------------------------------------------------------------------------
  -- Data In Buffer generation
  -- DataIn is loaded in the first element of the array
  -- The rest of data are shifted right
  process(Clk,Reset)
  begin
    if Reset='1' then 
      aX <= (others=> (others=>'0')); 
    elsif rising_edge(Clk) then 
      if Enable='1' then 
        aX(0) <= Data_in; 
        aX(1 to Order - 1) <= aX(0 to Order - 2);         
      end if; 
    end if; 
  end process; 
  -------------------------------------------------------------------------------------------
  -- Counter for executing every multiplication in the filter equation
  -- Enable activates the execution when is set to 1 and then to 0, afterwards. Then, 
  -- the FIR operation is executed once
  process(Clk,Reset)
  begin
    if Reset='1' then 
      Sel <= 0; 
    elsif rising_edge(Clk) then 
      if Enable='1' then 
        Sel <= 1; 
      elsif Sel/=0 then 
        if Sel = Order then 
          Sel <= 0; 
        else 
          Sel <= Sel + 1; 
        end if; 
      end if; 
    end if; 
  end process; 
  -------------------------------------------------------------------------------------------
  -- FIR serial operation
  process(Clk,Reset)
  begin
    if Reset='1' then 
      Accum <= (others=>'0'); 
    elsif rising_edge(Clk) then 
      if Enable='1' then 
        Accum <= (others=>'0');
      elsif Sel > 0 then 
        Accum <= Accum +(S1*S2); 
      end if; 
    end if; 
  end process; 
  -------------------------------------------------------------------------------------------
  -- Multiplexers for Multiplier Operands selection
  S1 <= cCoefs(Sel - 1) when Sel > 0 else (others => '0');
  S2 <=     aX(Sel - 1) when Sel > 0 else (others => '0');
end Behavioural; 
