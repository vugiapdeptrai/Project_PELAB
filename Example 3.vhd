-- Đề bài: Với tín hiệu đầu vào x(std_logic_vector) từ 4 switch trên FPGA, thiết kế mạch cộng/trừ gồm
-- 1. 2 Button thực hiện chức năng cộng và trừ 1 bit
-- 2. 4 led hiển thị số 4 bit với (1: sáng, 0: tối)
-- 3. 1 led RGB hiển thị trạng thái mạch

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity program is
    port(
        clk : in std_logic;
        x : in std_logic_vector (3 downto 0);
        y : out std_logic_vector (3 downto 0);
        plus : in std_logic;
        minor : in std_logic;
        reset : in std_logic;
        rgb_led : out std_logic_vector (2 downto 0)
    );
end program;

architecture math of program is
    signal input : integer := 0;
    signal overflow : std_logic_vector(2 downto 0) := "000";
    signal plus_late : std_logic := '0';
    signal minor_late : std_logic := '0';
    signal plus_stable : std_logic := '0';
    signal minor_stable : std_logic := '0';
    signal count_att : unsigned (20 downto 0) := (others => '0');
    
    constant led_normal : std_logic_vector (2 downto 0) := "010"; --Green
    constant led_error : std_logic_vector (2 downto 0) := "100"; --Red
    constant led_reset : std_logic_vector (2 downto 0) := "101"; --Purple
    constant led_overflow : std_logic_vector (2 downto 0) := "111"; --White
    constant led_underflow : std_logic_vector (2 downto 0) := "011"; -- Sky blue
    constant led_processing : std_logic_vector (2 downto 0) := "110"; -- Yellow
    
begin
    
    y <= std_logic_vector(TO_UNSIGNED(input,4));
    rgb_led <= overflow;
        
    noise_filt : process (clk)
        constant limit : integer := 500000; --f = 10MHz, T = 10ns, to late 5 ms => 5ms/10ns = 500000 (pluse)
    begin
        if rising_edge(clk) then
            if (plus /= plus_stable) or (minor /= minor_stable) then
                if (count_att < limit) then
                    count_att <= count_att + 1;
                else 
                    plus_stable <= plus;
                    minor_stable <= minor;
                    count_att <= (others => '0');
                end if;
            else 
                count_att <= (others => '0');
            end if;
        end if;        
    end process;
        
    count: process (clk, reset) 
    begin
        if (reset = '1') then
                input <= TO_INTEGER(unsigned(x));
                overflow <= led_reset; -- Purple: Reset all of value
        elsif rising_edge(clk) then
            plus_late <= plus_stable;
            minor_late <= minor_stable;
            if (plus_stable = '1' and plus_late = '0' and minor_stable = '0') then
                if (input = 15) then
                    overflow <= led_overflow; -- White: Overflow
                    input <= 0;
                else 
                    overflow <= led_processing;
                    input <= input + 1;
                end if;
            elsif (minor_stable = '1' and minor_late = '0' and plus_stable = '0') then
                if (input = 0) then
                    overflow <= led_underflow; -- Sky blue: Underflow
                    input <= 15;
                else 
                    overflow <= led_processing;
                    input <= input - 1;
                end if;
            elsif (minor_stable = '1' and plus_stable = '1') then 
                input <= TO_INTEGER(unsigned(x));
                overflow <= led_error; --Red: Error
            else
                overflow <= led_normal; --Green: Normal/ No affect
            end if;
        end if;
    end process count;

end architecture math;    