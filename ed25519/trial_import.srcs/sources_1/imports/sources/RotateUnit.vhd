----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			8/7/2014
-- MODULE NAME:			RotateUnit
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
ENTITY RotateUnit IS
	PORT ( CLK 	: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 	: IN  STD_LOGIC;
          LOAD	: IN  STD_LOGIC;
          CE  	: IN  STD_LOGIC;
			 -- DATA IN PORTS --------------------------------
			 A   	: IN  STD_LOGIC_VECTOR (254 DOWNTO 0);
          B   	: IN  STD_LOGIC_VECTOR (254 DOWNTO 0);
			 -- DATA OUT PORTS -------------------------------
          ROTA : OUT STD_LOGIC_VECTOR (254 DOWNTO 0);
          ROTB : OUT STD_LOGIC_VECTOR (254 DOWNTO 0));
END RotateUnit;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF RotateUnit IS



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL STATE_A, STATE_B : STD_LOGIC_VECTOR(254 DOWNTO 0) := (OTHERS => '0');



-- BEHAVIORAL
----------------------------------------------------------------------------------
BEGIN

	-- (17 BIT CHUNK) ROTATION OF OPERAND A ---------------------------------------
	ROTATE_A : PROCESS(CLK)
	BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RST =  '1') THEN
				STATE_A <= (OTHERS => '0');
			ELSIF (LOAD = '1') THEN
				STATE_A <= A;
			ELSIF (CE = '1') THEN
				STATE_A <= STATE_A(237 DOWNTO 0) & STATE_A(254 DOWNTO 238);
			ELSE
				STATE_A <= STATE_A;
			END IF;
		END IF;
	END PROCESS;

	-- (17 BIT CHUNK) ROTATION OF OPERAND B ---------------------------------------
	ROTATE_B : PROCESS(CLK)
	BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RST = '1') THEN
				STATE_B <= (OTHERS => '0');
			ELSIF (LOAD = '1') THEN
				STATE_B <= B;
			ELSIF (CE = '1') THEN
				STATE_B <= STATE_B(16 DOWNTO 0) & STATE_B(254 DOWNTO 17);
			ELSE 
				STATE_B <= STATE_B;
			END IF;
		END IF;
	END PROCESS;
	
	-- OUTPUT ROTATED OPERANDS ----------------------------------------------------
	ROTA <= STATE_A;
	ROTB <= STATE_B;

END Behavioral;

