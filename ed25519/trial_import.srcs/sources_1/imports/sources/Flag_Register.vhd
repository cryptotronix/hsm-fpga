----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Hardware Security Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			8/7/2014
-- MODULE NAME:			Flag_Register
--
--	REVISION:				1.00 - File created
--								1.01 - BugFixes
--
-- DESCRIPTION:			
--
-- LICENCE: 				Please look at licence.txt
-- USAGE INFORMATION:	Please look at readme.txt. If licence.txt or readme.txt
--								are missing or	if you have questions regarding the code
--								please contact Tim Güneysu (tim.gueneysu@rub.de) and
--								Pascal Sasdrich (pascal.sasdrich@rub.de)
--
-- THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
-- KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
-- PARTICULAR PURPOSE.
----------------------------------------------------------------------------------



-- IMPORTS
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY Flag_Register IS
	PORT ( CLK : 	IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
			 RST :   IN	 STD_LOGIC;
          SET : 	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
			 -- DATA OUT PORT --------------------------------
          FLAGS : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
END Flag_Register;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF Flag_Register IS



-- SIGNAL
----------------------------------------------------------------------------------
SIGNAL STATE : STD_LOGIC_VECTOR(7 DOWNTO 0);



-- BEHAVIORAL
----------------------------------------------------------------------------------
BEGIN
	
	-- BEHAVIORAL DESCRIPTION OF FLAG REGISTER (WITH PARALLEL SET) ----------------
	FLAG_REG : PROCESS(CLK)
	BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RST = '1') THEN
				STATE <= (OTHERS => '0');
			ELSE
				STATE <= (STATE OR SET);
			END IF;
		END IF;
	END PROCESS;

	-- OUTPUT ---------------------------------------------------------------------
	FLAGS <= STATE;

END Behavioral;

