----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Nicolas Ruiz Requejo
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FDD1 is
    Port ( reset : in STD_LOGIC;
           clock : in STD_LOGIC;
           kk : in std_logic; 
           D : in STD_LOGIC;
           Q : out STD_LOGIC);
end FDD1;

architecture Behavioral of FDD1 is
    signal qs : std_logic;
begin

    process (reset, clock)
    begin
        if reset='1' then
            qs <= '0';
        elsif clock'event and clock = '1' then
            qs <= D;
        end if;
    end process;
    
    Q <= qs;

end Behavioral;
