----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			9/7/2014
-- MODULE NAME:			DSP_Multiply_Operation
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
ENTITY DSP_Multiply_Operation IS
	PORT ( CLK : IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST : IN  STD_LOGIC;
          CE  : IN  STD_LOGIC;
			 -- DATA IN PORTS --------------------------------
			 A   : IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
          B   : IN  STD_LOGIC_VECTOR (21 DOWNTO 0);
			 -- DATA OUT PORT --------------------------------
          P   : OUT STD_LOGIC_VECTOR (42 DOWNTO 0));
END DSP_Multiply_Operation;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF DSP_Multiply_Operation IS



-- COMPONENT
----------------------------------------------------------------------------------
COMPONENT MACC IS
	PORT ( CLK 	: IN  STD_LOGIC;
			 CE	: IN  STD_LOGIC;
			 SCLR : IN  STD_LOGIC;
			 A		: IN  STD_LOGIC_VECTOR(22 DOWNTO 0);
			 B 	: IN  STD_LOGIC_VECTOR(17 DOWNTO 0);
			 P 	: OUT STD_LOGIC_VECTOR(47 DOWNTO 0));
END COMPONENT;



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL UNSIGNED_A : STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL UNSIGNED_B : STD_LOGIC_VECTOR(22 DOWNTO 0);
SIGNAL UNSIGNED_P : STD_LOGIC_VECTOR(47 DOWNTO 0);



-- STRUCTURAL
----------------------------------------------------------------------------------
BEGIN

	-- UNSIGNED INPUTS ------------------------------------------------------------
	UNSIGNED_A <= ('0' & A);
	UNSIGNED_B <= ('0' & B);

	-- INSTANCE -------------------------------------------------------------------	
	Macc_DSP: MACC
	PORT MAP (
		CLK  	=> CLK,
		CE   	=> CE,
		SCLR 	=> RST,
		A 		=> UNSIGNED_B,
		B 		=> UNSIGNED_A,
		P 		=> UNSIGNED_P
	);

	-- UNSIGNED OUTPUT ------------------------------------------------------------
	P <= UNSIGNED_P(42 DOWNTO 0);
	
END Structural;

