----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			8/7/2014
-- MODULE NAME:			DSP_Accumulate_Operation
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
ENTITY DSP_Accumulate_Operation IS
	PORT ( CLK   	: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST   	: IN  STD_LOGIC;
          CE    	: IN  STD_LOGIC;
			 START 	: IN  STD_LOGIC_VECTOR (0 DOWNTO 0);
			 -- DATA IN PORTS --------------------------------
			 SUM   	: IN  STD_LOGIC_VECTOR (42 DOWNTO 0);
			 H1    	: IN  STD_LOGIC_VECTOR (20 DOWNTO 0);
			 H2	 	: IN  STD_LOGIC_VECTOR ( 8 DOWNTO 0);
			 -- DATA OUT PORTS -------------------------------         
          RESULT	: OUT STD_LOGIC_VECTOR (16 DOWNTO 0);
			 CARRY 	: OUT STD_LOGIC);
END DSP_Accumulate_Operation;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF DSP_Accumulate_Operation IS



-- COMPONENT
----------------------------------------------------------------------------------
COMPONENT Acc IS
	PORT ( CLK 	 : IN STD_LOGIC;
			 CE 	 : IN STD_LOGIC;
			 SCLR  : IN STD_LOGIC;
			 SEL 	 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			 A 	 : IN STD_LOGIC_VECTOR(21 DOWNTO 0);
			 B 	 : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			 C 	 : IN STD_LOGIC_VECTOR(43 DOWNTO 0);
			 D 	 : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			 P 	 : OUT STD_LOGIC_VECTOR(47 DOWNTO 0));
END COMPONENT;



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL UNSIGNED_SUM		: STD_LOGIC_VECTOR(43 DOWNTO 0);
SIGNAL UNSIGNED_HIGH1	: STD_LOGIC_VECTOR(21 DOWNTO 0);
SIGNAL UNSIGNED_HIGH2	: STD_LOGIC_VECTOR( 9 DOWNTO 0);
SIGNAL UNSIGNED_RESULT	: STD_LOGIC_VECTOR(47 DOWNTO 0);
SIGNAL UNSIGNED_PRIME	: STD_LOGIC_VECTOR( 5 DOWNTO 0);



-- STRUCTURAL
----------------------------------------------------------------------------------
BEGIN

	-- UNSIGNED INPUTS ------------------------------------------------------------
	UNSIGNED_SUM	<= ('0' & SUM);
	UNSIGNED_HIGH1	<= ('0' & H1);
	UNSIGNED_HIGH2	<= ('0' & H2);
	UNSIGNED_PRIME	<= "010011";							-- BINARY REPRESENTATION OF 19

	-- INSTANCE -------------------------------------------------------------------	
	Acc_DSP : Acc
	PORT MAP (
		CLK	=> CLK,
		CE		=> CE,
		SCLR	=> RST,
		SEL	=> START,
		A		=> UNSIGNED_HIGH1,
		B		=> UNSIGNED_PRIME,
		C		=> UNSIGNED_SUM,
		D		=> UNSIGNED_HIGH2,
		P		=> UNSIGNED_RESULT
	);

	-- UNSIGNED OUTPUTS -----------------------------------------------------------	
	RESULT	<= UNSIGNED_RESULT(16 DOWNTO 0);
	CARRY		<= UNSIGNED_RESULT(0);
	
END Structural;

