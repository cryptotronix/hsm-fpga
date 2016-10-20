--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:34:48 07/08/2013
-- Design Name:   
-- Module Name:   C:/Users/Pascal/Subversions/Sasdrich/Curve25519_Implementation/Curve255Core/TB_Core.vhd
-- Project Name:  Curve255Core
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Curve25519Core
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------



-- IMPORTS
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
 
 
-- ENTITY
----------------------------------------------------------------------------------
ENTITY TB_Core IS
END TB_Core;
 
 
 
-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE behavior OF TB_Core IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Curve25519Core
    PORT( CMD 	  : IN  STD_LOGIC_VECTOR(7 downto 0);
			 P 	  : IN  STD_LOGIC_VECTOR(33 downto 0);
          K 	  : IN  STD_LOGIC_VECTOR(254 downto 0);
          CLK    : IN  STD_LOGIC;
          CE 	  : IN  STD_LOGIC;
          RESP   : OUT STD_LOGIC_VECTOR(7 downto 0);
          RESULT : OUT STD_LOGIC_VECTOR(33 downto 0));
    END COMPONENT;
    

   --Inputs
   signal CMD : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
   signal P   : STD_LOGIC_VECTOR(33 downto 0) := (others => '0');
   signal K   : STD_LOGIC_VECTOR(254 downto 0) := (others => '0');
   signal CLK : STD_LOGIC := '0';
   signal CE  : STD_LOGIC := '0';

 	--Outputs
   signal RESP   : STD_LOGIC_VECTOR(7 downto 0);
   signal RESULT : STD_LOGIC_VECTOR(33 downto 0);

   -- Clock period definitions
   CONSTANT CLK_PERIOD : TIME := 5 NS;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Curve25519Core
	PORT MAP (
		CMD 	 => CMD,
      P 		 => P,
      K 	 	 => K,
      CLK 	 => CLK,
      CE 	 => CE,
      RESP 	 => RESP,
      RESULT => RESULT
	);

   -- Clock process definitions
   CLK_PROCESS : PROCESS
	BEGIN
		CLK <= '1';
		WAIT FOR CLK_PERIOD/2;
		CLK <= '0';
		WAIT FOR CLK_PERIOD/2;
	END PROCESS;
 

   -- STIMULUS PROCESS -----------------------------------------------------------
   STIM_PROC : PROCESS
   BEGIN		
      -- HOLD RESET STATE --------------------------------------------------------
		CMD <= x"08"; WAIT FOR CLK_PERIOD*10; CMD <= x"00";
		
		WAIT UNTIL RESP = x"01";
		
		-- LOAD POINT INTO CURVE25519 CORE -----------------------------------------
		CMD <= x"02"; CE <= '1'; 
		WAIT UNTIL RESP = x"02"; 
		
				WAIT FOR CLK_PERIOD;
					  
				P <= "0000000000000000000000000000001001"; WAIT FOR CLK_PERIOD;
				FOR I IN 0 TO 6 LOOP
					P <= "0000000000000000000000000000000000"; WAIT FOR CLK_PERIOD;
				END LOOP;
		
		WAIT UNTIL RESP = x"04";
		CE <= '0'; CMD <= x"00";
		
		-- LOAD MULTIPLICAND K INTO CURVE25519 CORE --------------------------------
		CMD <= x"04"; CE <= '1';
		K <= ("101")&x"EAFF7F68F737E54A977234BBD5B828321375B310D1C26226E8381FD14FAAD88";
--		K <= ("000")&x"000000000000000000000000000000000000000000000000000000000000003";
		WAIT UNTIL RESP = x"04";
		CMD <= x"00"; CE <= '0';
		
		-- START COMPUTATION -------------------------------------------------------
		CMD <= x"01"; CE <= '1';
		WAIT UNTIL RESP = x"04";
		CMD <= x"00"; CE <= '0';
		
		-- GET RESULT --------------------------------------------------------------
--		CMD <= x"10"; CE <= '1';
--		WAIT UNTIL RESP = x"04";
--		CMD <= x"00"; CE <= '0';
		
      WAIT;
   END PROCESS;

END;
