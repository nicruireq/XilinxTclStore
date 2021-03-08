--------------------------------------------------------------------------------
-- Company: 
-- Engineer:		Nicolas Ruiz Requejo
--
-- Create Date:   09:13:47 11/17/2017
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

 
ENTITY BlinkLED_tb IS
END BlinkLED_tb;
 
ARCHITECTURE behavior OF BlinkLED_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BlinkLED
    PORT(
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         LED : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';

 	--Outputs
   signal LED : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BlinkLED PORT MAP (
          CLK => CLK,
          RESET => RESET,
          LED => LED
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      --wait for CLK_period*10;

      -- insert stimulus here 
		RESET <= '1';
		wait for 50 ns;
		RESET <= '0';
		wait for 50 ns;
		
      wait;
   end process;

END;
