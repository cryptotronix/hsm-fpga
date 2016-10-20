----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			9/7/2014
-- MODULE NAME:			LSR255
--
--	REVISION:				1.00 - File created
--								1.01 - BugFixes
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
ENTITY LSR255 IS
	PORT ( CLK 	: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 	: IN  STD_LOGIC;
          CE  	: IN  STD_LOGIC;        
			 LOAD : IN  STD_LOGIC;
			 -- DATA IN PORT ---------------------------------
			 K   	: IN  STD_LOGIC_VECTOR (254 DOWNTO 0);  
			 -- DATA OUT PORT --------------------------------
          MSB 	: OUT STD_LOGIC);
END LSR255;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF LSR255 IS



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL STATE : STD_LOGIC_VECTOR(254 DOWNTO 0);



-- BEHAVIORAL
----------------------------------------------------------------------------------
BEGIN

	-- LOAD/SHIFT REGISTER --------------------------------------------------------
	REGISTER_PROCESS : PROCESS(CLK)
	BEGIN	
		IF RISING_EDGE(CLK) THEN	
			IF (RST = '1') THEN
				STATE <= (OTHERS => '0');
			ELSIF (LOAD = '1') THEN
				STATE <=  K;
			ELSIF (CE = '1') THEN
				STATE <= STATE(253 DOWNTO 0) & '0';
			ELSE
				STATE	<= STATE;
			END IF;	
		END IF;		
	END PROCESS;
	
	-- OUTPUT  --------------------------------------------------------------------
	MSB <= STATE(254);

END Behavioral;

