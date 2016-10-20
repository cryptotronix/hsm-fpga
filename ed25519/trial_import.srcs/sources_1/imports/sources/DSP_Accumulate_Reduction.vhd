----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			8/7/2014
-- MODULE NAME:			DSP_Accumulate_Reduction
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
ENTITY DSP_Accumulate_Reduction IS
	PORT ( CLK 	 		: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 			: IN  STD_LOGIC;
          CE  	 		: IN  STD_LOGIC;
			 -- DATA IN PORTS --------------------------------
			 CHUNK		: IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
			 PRIME 		: IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
			 CARRY_IN  	: IN  STD_LOGIC;
			 -- DATA OUT PORTS ------------------------------- 
          RESULT		: OUT STD_LOGIC_VECTOR (16 DOWNTO 0);
			 CARRY_OUT 	: OUT STD_LOGIC);
END DSP_Accumulate_Reduction;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF DSP_Accumulate_Reduction IS



-- COMPONENT
----------------------------------------------------------------------------------
COMPONENT Fin IS
	PORT ( CLK 		 : IN  STD_LOGIC;
			 CE 		 : IN  STD_LOGIC;
			 SCLR 	 : IN  STD_LOGIC;
			 CARRYIN  : IN  STD_LOGIC;
			 A 		 : IN  STD_LOGIC_VECTOR(17 DOWNTO 0);
			 C 		 : IN  STD_LOGIC_VECTOR(17 DOWNTO 0);
			 P 		 : OUT STD_LOGIC_VECTOR(18 DOWNTO 0));
END COMPONENT;



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL UNSIGNED_CHUNK, UNSIGNED_PRIME 	: STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL UNSIGNED_RESULT						: STD_LOGIC_VECTOR(18 DOWNTO 0);



-- STRUCTURAL
----------------------------------------------------------------------------------
BEGIN

	-- UNSIGNED INPUTS ------------------------------------------------------------
	UNSIGNED_CHUNK <= ('0' & CHUNK);
	UNSIGNED_PRIME <= ('0' & PRIME);
	
	-- INSTANCE -------------------------------------------------------------------	
	Fin_DSP : Fin
	PORT MAP (
		CLK		=> CLK,
		CE			=> CE,
		SCLR		=> RST,
		CARRYIN 	=> CARRY_IN,
		A			=> UNSIGNED_PRIME,
		C			=> UNSIGNED_CHUNK,
		P			=> UNSIGNED_RESULT
	);


	-- UNSIGNED OUTPUTS -----------------------------------------------------------
	RESULT		<= UNSIGNED_RESULT(16 DOWNTO 0);
	CARRY_OUT 	<= UNSIGNED_RESULT(17);
	
END Structural;



