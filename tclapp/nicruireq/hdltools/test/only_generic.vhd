--
--  mock for testing
--
--

entity mock is
    generic ( datafile : string := "~/pruebas/mem.dat";
              address_width : integer := 4; 
              data_width : integer := 8);
end mock;

architecture Behavioral of mock is
    signal qs : std_logic;
begin

    

end Behavioral;
