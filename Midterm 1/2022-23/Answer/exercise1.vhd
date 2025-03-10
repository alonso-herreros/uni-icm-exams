library IEEE;
use IEEE.std_logic_1164.all;
entity RS232_Tx is
  generic(
    gDataWidth    : natural := 8;  -- bits for Data
    gTotalNumBit  : natural := 11; -- WordWidth= Start(1)+Data(8)+Parity(1)+Stop(1)
    gBaudRate     : natural := 57600;      -- bps
    gClkFrequency : natural := 100000000); -- Hz
  port(
    Clk          : in std_logic;
    ResetN       : in std_logic;
    RSDataToSend : in std_logic_vector(gDataWidth - 1 downto 0);
    EnableSend   : in std_logic;
    TxD          : out std_logic;
    TxBusy       : out std_logic
  );
end RS232_Tx;

architecture Behavioural of RS232_Tx is
  constant StartBit        : std_logic := '0';
  constant StopBit         : std_logic := '1';
  ---------------------------------------------------------------------
  constant cBaudRateCycles : natural := gClkFrequency/gBaudRate;
  signal EnaBaudRate       : _________________;
  signal ClrBaudRate       : _________________;
  signal CountBaudRate     : _________________;
  signal EndBaudRate       : _________________;
  ---------------------------------------------------------------------
  signal EnaNumBitsTx      : std_logic;
  signal ClrNumBitsTx      : std_logic;
  signal CountNumBitsTx    : natural range 0 to gTotalNumBit-1;
  signal EndNumBitsTx      : std_logic;
  ---------------------------------------------------------------------
  type tStateTx is (Idle, Sending);
  signal CurrentState      : tStateTx;
  signal NextState         : TstateTx;
  signal RegDataTx         : std_logic_vector(gTotalNumBit-1 downto 0);
  signal ClrTx             : std_logic;
  signal ParityBit         : std_logic;
begin
  TxD    <= RegDataTx(0);
  TxBusy <= NOT(ClrTx);
  --------------------------------------------------------------------------------
  P1: process(  )
    variable aux_Parity: std_logic;
  begin
    aux_Parity:= '0';
    for I in RSDataToSend'range loop
      aux_Parity:= aux_Parity XOR RSDataToSend(I);
    end loop;
    ParityBit <= aux_Parity;
  end process P1;
  ---------------------------------------------------------------------------
  P2: process(  )
  begin
    if ResetN = '0' then
      RegDataTx <= (others => '1');
    elsif Clk'event and Clk = '1' then
      if ClrTx = '1' then
        RegDataTx <= (others => '1');
      elsif EnableSend = '1' then
        RegDataTx <= StopBit & ParityBit & RSDataToSend & StartBit;
      elsif EnaNumBitsTx = '1' then
        RegDataTx <= '1' & RegDataTx(gTotalNumBit-1 downto 1);
      end if;
    end if;
  end process P2;
  --------------------------------------------------------------------------------
  P3: process(  )
  begin
    if ResetN = '0' then
      CurrentState <= Idle;
    elsif Clk'event and Clk = '1' then
      CurrentState <= NextState;
    end if;
  end process P3;
  -------------------------------------------------------------------------------
  P4: process(  )
  begin
    ClrTx        <= '0';
    ClrBaudRate  <= '0';
    ClrNumBitsTx <= '0';
    EnaBaudRate  <= '0';
    case CurrentState is
      when Idle =>
        ClrBaudRate  <= '1';
        ClrNumBitsTx <= '1';
        ClrTx        <= '1';
        if EnableSend = '1' then
          NextState <= Sending;
          ClrTx     <= '0';
        else
          NextState <= Idle;
        end if;
      when Sending =>
        EnaBaudRate <= '1';
        if EndNumBitsTx = '1' then
          NextState <= Idle;
        else
          NextState <= Sending;
        end if;
      when others =>
        NextState <= Idle;
    end case;
  end process P4;
  ------------------------------------------------------------------------------
  P5: process(  )
  begin
    if ResetN = '0' then
      CountBaudRate <= 0;
    elsif Clk'event and Clk = '1' then
      if ClrBaudRate = '1' then
        CountBaudRate <= 0;
      elsif EnaBaudRate = '1' then
        if CountBaudRate = cBaudRateCycles - 1 then
          CountBaudRate <= 0;
        else
          CountBaudRate <= CountBaudRate + 1;
        end if;
      end if;
    end if;
  end process P5;
  EndBaudRate <= '1' when ((CountBaudRate = cBaudRateCycles – 1) AND
                           (EnaBaudRate = '1'))
                 else '0';
  --------------------------------------------------------------------------------
  P6: EnaNumBitsTx <= EndBaudRate;
  process(  )
  begin
    if ResetN = '0' then
      CountNumBitsTx <= 0;
    elsif Clk'event and Clk = '1' then
      if ClrNumBitsTx = '1' then
        CountNumBitsTx <= 0;
      elsif EnaNumBitsTx = '1' then
        if CountNumBitsTx = gTotalNumBit - 1 then
          CountNumBitsTx <= 0;
        else
          CountNumBitsTx <= CountNumBitsTx + 1;
        end if;
      end if;
    end if;
  end process P6;
  EndNumBitsTx <= '1' when ((CountNumBitsTx = gTotalNumBit – 1) AND
                            (EnaNumBitsTx = '1'))
                  else '0';
  end Behavioural;

