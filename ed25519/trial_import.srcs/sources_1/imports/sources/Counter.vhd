----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			9/7/2014
-- MODULE NAME:			Counter
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
USE IEEE.NUMERIC_STD.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY Counter IS
	GENERIC (WIDTH : POSITIVE := 4);
	PORT ( 	CLK :   IN  STD_LOGIC;
				CE :    IN  STD_LOGIC;
				RST :   IN  STD_LOGIC;
				Q : 	  OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0));
END Counter;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF Counter IS



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL COUNT : UNSIGNED (WIDTH-1 DOWNTO 0);



-- BEHAVIORAL
----------------------------------------------------------------------------------
BEGIN

	PROCESS (CLK, CE, RST)
	BEGIN
		IF RISING_EDGE(CLK) THEN
			IF RST = '1' THEN
				COUNT <= (OTHERS => '0');
			ELSIF CE = '1' THEN
				COUNT <= COUNT + 1;
			END IF;
		END IF;
	END PROCESS;

	Q <= STD_LOGIC_VECTOR(COUNT);

END Behavioral;

