----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			10/1/2013
-- MODULE NAME:			DSP_Addition_Operation
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
ENTITY DSP_Addition_Operation IS
	PORT ( CLK 			: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 	 		: IN  STD_LOGIC;
          CE  	 		: IN  STD_LOGIC;
          SUB 	 		: IN  STD_LOGIC;
			 -- DATA IN PORTS --------------------------------
			 OP_A  		: IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
          OP_B  		: IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
			 CARRY_IN	: IN  STD_LOGIC;
			 -- DATA OUT PORTS -------------------------------
          RESULT		: OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
			 CARRY_OUT	: OUT STD_LOGIC);
END DSP_Addition_Operation;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF DSP_Addition_Operation IS



-- COMPONENT
----------------------------------------------------------------------------------
COMPONENT AddSub IS
	PORT ( CLK 	   : IN  STD_LOGIC;
			 CE 	   : IN  STD_LOGIC;
			 SCLR    : IN  STD_LOGIC;
			 SEL 	   : IN  STD_LOGIC_VECTOR (0 DOWNTO 0);
			 CARRYIN : IN  STD_LOGIC;
			 C 	   : IN  STD_LOGIC_VECTOR (34 DOWNTO 0);
			 CONCAT  : IN  STD_LOGIC_VECTOR (34 DOWNTO 0);
			 P 	   : OUT STD_LOGIC_VECTOR (35 DOWNTO 0));
END COMPONENT;



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL UNSIGNED_A, UNSIGNED_B 							: STD_LOGIC_VECTOR(34 DOWNTO 0);
SIGNAL UNSIGNED_RESULT										: STD_LOGIC_VECTOR(35 DOWNTO 0);



-- STRUCTURAL
----------------------------------------------------------------------------------
BEGIN

	-- UNSIGNED INPUTS ------------------------------------------------------------
	UNSIGNED_A 	<= ('0' & OP_A);
	UNSIGNED_B 	<= ('0' & OP_B);

	-- INSTANCES ------------------------------------------------------------------
	DSP : AddSub
	PORT MAP (
		CLK 	  => CLK,
		CE 	  => CE,
		SCLR 	  => RST,
		SEL(0)  => SUB,
		CARRYIN => CARRY_IN,
		C 		  => UNSIGNED_A,
		CONCAT  => UNSIGNED_B,
		P 		  => UNSIGNED_RESULT
	);
	
	-- UNSIGNED OUTPUTS -----------------------------------------------------------
	RESULT		<= UNSIGNED_RESULT(33 DOWNTO 0);
	CARRY_OUT	<= UNSIGNED_RESULT(34);

END Structural;

