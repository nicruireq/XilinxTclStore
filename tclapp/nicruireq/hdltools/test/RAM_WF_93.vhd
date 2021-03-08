----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Nicolas Ruiz Requejo
-- Github: @nicruireq
--
-- Create Date: 21.06.2019 00:49:25
-- Design Name: 
-- Module Name: RAM_WF_93 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity RAM_WF_93 is
    generic ( datafile : string := "~/pruebas/mem.dat";
              address_width : integer := 4; 
              data_width : integer := 8);
    Port ( DataIn : in  std_logic_vector(data_width-1 downto 0);
           WE : in  std_logic;
           Address : in  std_logic_vector(address_width-1 downto 0);
           DataOut : out  std_logic_vector(data_width-1 downto 0);
           CLK : in  std_logic);
end RAM_WF_93;

architecture Behavioral of RAM_WF_93 is
    type ram_type is array(0 to (2**address_width)-1) 
            of std_logic_vector(data_width-1 downto 0);
            
    impure function load_ram_from_file(file_name : in string) return ram_type is
        file fdata : text open read_mode is file_name;
        variable mline : line;
        --variable vbuffer : std_logic_vector(data_width-1 downto 0);
        variable temp_mem : ram_type;
    begin
        --for i in 0 to (2**address_width)-1 loop
        for i in ram_type'range loop 
            readline(fdata, mline);
            --read(mline, temp_mem(i));     -- read binary format i.e: 4 bit length -> 0011
            hread(mline, temp_mem(i));      -- read hex format i.e: 8 bit lenght -> 2f
            --writeline(output, mline);   -- print on std output
            --temp_mem(i) := vbuffer;
         end loop;
                
         return temp_mem;
    end function;               
    
	signal RAM : ram_type := load_ram_from_file(datafile);
    
begin

	process(Clk)
	begin
		if rising_edge(Clk) then
			if WE = '1' then
				RAM(to_integer(unsigned(Address))) <= DataIn;
				DataOut <= DataIn;
			else
				DataOut <= RAM(to_integer(unsigned(Address)));
			end if;
		end if;
	end process;
      
end Behavioral;
