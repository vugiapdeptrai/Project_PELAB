library IEEE;
use IEEE.std_logic_1164.all;

entity tb_ex_3 is
end entity;

architecture test_bench of tb_ex_3 is 

    signal clk: std_logic;
    signal x : std_logic_vector (3 downto 0); 
    signal y : std_logic_vector (3 downto 0);
    signal plus : std_logic;
    signal minor : std_logic;
    signal reset : std_logic;
    signal rgb_led : std_logic_vector (2 downto 0);
    
    component program
        port(
            clk : in std_logic;
            x : in std_logic_vector (3 downto 0); 
            y : out std_logic_vector (3 downto 0);
            plus : in std_logic;
            minor : in std_logic;
            reset : in std_logic;
            rgb_led : out std_logic_vector (2 downto 0)
        );
    end component;
        
begin
    link: program port map(
        clk => clk,
        x => x,
        y => y,
        plus => plus,
        minor => minor,
        reset => reset,
        rgb_led => rgb_led
    );
    
    clk_process: process
    begin
        for i in 0 to 59 loop
            clk <= '0';
            wait for 25ns;
            clk <= '1';
            wait for 25ns;
        end loop;
        wait;
    end process;
    
    plus_process: process 
    begin
        for i in 0 to 29 loop
            plus <= '1';
            wait for 50ns;
            plus <= '0';
            wait for 50ns;
        end loop;
        wait;
    end process;
    
    minor_process: process
    begin
        for i in 0 to 5 loop
            minor <= '0';
            wait for 450ns;
            minor <= '1';
            wait for 50ns;
        end loop;
        wait;
    end process;
    
    reset_process: process
    begin
        reset <= '0';
        wait for 1000 ns;
        reset <= '1'; 
        wait for 30ns;
        reset <= '0';
        wait for 470ns;
        wait;
    end process;
    
end architecture;
