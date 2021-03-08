----------------------------------------------------------------------------------
--
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity NOR_GATE is
    Port ( A_i : in STD_LOGIC_VECTOR (1 downto 0);
           B_i : in STD_LOGIC_VECTOR (1 downto 0);
           Z_o : out STD_LOGIC_VECTOR (1 downto 0));
end NOR_GATE;

architecture Behavioral of NOR_GATE is
begin
    Z_o <= A_i nor B_i;
end Behavioral;
