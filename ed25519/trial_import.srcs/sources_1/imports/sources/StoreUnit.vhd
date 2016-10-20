----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			8/7/2014
-- MODULE NAME:			StoreUnit
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
ENTITY StoreUnit IS
	PORT ( CLK 		: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 		: IN  STD_LOGIC;
          LOAD		: IN  STD_LOGIC;
          CE  		: IN  STD_LOGIC;
			 -- DATA IN PORT ---------------------------------
			 RESULT 	: IN  STD_LOGIC_VECTOR (254 DOWNTO 0);
			 -- DATA OUT PORT --------------------------------
          C   		: OUT STD_LOGIC_VECTOR (33 DOWNTO 0));
END StoreUnit;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF StoreUnit IS



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL STATE : STD_LOGIC_VECTOR(254 DOWNTO 0) := (OTHERS => '0');



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
				STATE <= RESULT;
			ELSIF (CE = '1') THEN
				STATE <= (33 DOWNTO 0 => '0') & STATE(254 DOWNTO 34);
			ELSE
				STATE <= STATE;
			END IF;
		END IF;
	END PROCESS;

	-- OUTPUT ---------------------------------------------------------------------
	C <= STATE(33 DOWNTO 0);

END Behavioral;

