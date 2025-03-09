entity problem2 is
  generic(W:integer:=128);
  port (
    Clk      : in std_logic;
    rst      : in std_logic;
    Data_in  : in unsigned(7 downto 0);
    R_ready  : out std_logic;
    Data_out : out unsigned(X downto 0));
end problem2;

