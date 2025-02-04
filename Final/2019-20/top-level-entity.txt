library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity wind_detector is
    port (
        Wind:   in std_logic;
        Reset:  in std_logic;
        Clk:    in std_logic;
        NoWind: out std_logic;
        Leds:   out std_logic_vector(5 downto 0);
    );
end wind_detector;

architecture final2019 of wind_detector is
    signal Pulse:     std_logic;
    signal Ena:       std_logic;
    signal EoC:       std_logic;
    signal Clear:     std_logic;
    signal Capture:   std_logic;
    signal Calculate: std_logic;
    signal Count:     unsigned(7 downto 0);
    signal Register0: unsigned(7 downto 0);
    signal Register1: unsigned(7 downto 0);
    signal Register2: unsigned(7 downto 0);
    signal Register3: unsigned(7 downto 0);
    signal Average:   unsigned(7 downto 0);

    -- State Machine
    component state_machine is
        port (
            clk, reset:                     in std_logic;
            EoC:                            in std_logic;
            Ena, Clear, Capture, Calculate: out std_logic;
        );
    end component;

    -- Edge Detector
    component edge_det is
        port (
            clk, reset: in std_logic;
            Wind:       in std_logic;
            Pulse:      out std_logic;
        );
    end component;

    -- Counter (generic)
    component n_count is
        generic ( n: INTEGER := 8 );
        port (
            Clk, Reset: in std_logic;
            Clear:      in std_logic;
            Enable:     in std_logic;
            Count:      out unsigned(n-1 downto 0);
            EoC:        out std_logic;
        );
    end component;

    -- Registers
    component registers is
        port (
            clk, reset: in std_logic;
            capture:    in std_logic;
            count:      in unsigned(7 downto 0);
            register0:  out unsigned(7 downto 0);
            register1:  out unsigned(7 downto 0);
            register2:  out unsigned(7 downto 0);
            register3:  out unsigned(7 downto 0);
        );
    end component;

    -- Average Calculator
    component Average_calculator is
        port (
            R0, R1, R2, R3: in unsigned(7 downto 0);
            Calculate:      in std_logic;
            Average:        out unsigned(7 downto 0);
        );
    end component;

    -- Decoder
    component Decoder is
        port (
            Average: in unsigned(7 downto 0);
            Leds:    out std_logic_vector(5 downto 0);
        );
    end component;

begin

    Counter: n_count
        generic map ( n => 8 )
        port map (
            Clk    => Clk;
            Reset  => Reset;
            Clear  => Clear;
            Enable => Pulse;
            Count  => Count;
            EoC    => open;
        );

    Timer: n_count
        generic map ( n => 25 ) -- Clock freq: 20 MHz
        port map (
            Clk    => Clk;
            Reset  => Reset;
            Clear  => open;
            Enable => Ena;
            Count  => open;
            EoC    => EoC;
        );

    state_machine: state_machine
        port map (
            clk       => Clk;
            reset     => Reset;
            EoC       => EoC;
            Ena       => Enable;
            Clear     => Clear;
            Capture   => Capture;
            Calculate => Calculate;
        );

    edge_detector: edge_det
        port map (
            clk   => Clk;
            reset => Reset;
            Wind  => Wind;
            Pulse => Pulse;
        );

    registers: registers
        port map (
            clk       => Clk;
            reset     => Reset;
            capture   => Capture;
            count     => Count;
            register0 => Register0;
            register1 => Register1;
            register2 => Register2;
            register3 => Register3;
        );

    average_calculator: average_calculator
        port map (
            R0        => Register0;
            R1        => Register1;
            R2        => Register2;
            R3        => Register3;
            Calculate => Calculate;
            Average   => Average;
        );

    decoder: decoder
        port map (
            Average => Average;
            Leds    => Leds;
        );

end final2019;
