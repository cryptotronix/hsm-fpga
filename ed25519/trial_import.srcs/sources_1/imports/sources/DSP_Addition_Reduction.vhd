----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			10/1/2013
-- MODULE NAME:			DSP_Addition_Reduction
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
ENTITY DSP_Addition_Reduction IS
	PORT ( CLK 				: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST				: IN  STD_LOGIC;
          CE				: IN  STD_LOGIC;
          SUB 				: IN  STD_LOGIC;
			 -- DATA IN PORTS --------------------------------
			 INTERMEDIATE	: IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
			 PRIME			: IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
			 CARRY_IN		: IN  STD_LOGIC;
			 -- DATA OUT PORTS -------------------------------
          RESULT			: OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
          CARRY_OUT 		: OUT STD_LOGIC);		
END DSP_Addition_Reduction;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF DSP_Addition_Reduction IS



-- COMPONENT
----------------------------------------------------------------------------------
COMPONENT Reduce IS
	PORT ( CLK 		 : IN  STD_LOGIC;
			 CE 		 : IN  STD_LOGIC;
			 SCLR 	 : IN  STD_LOGIC;
			 SEL 		 : IN  STD_LOGIC_VECTOR (0 DOWNTO 0);
			 CARRYIN  : IN  STD_LOGIC;
			 C 		 : IN  STD_LOGIC_VECTOR (34 DOWNTO 0);
			 CONCAT	 : IN  STD_LOGIC_VECTOR (34 DOWNTO 0);
			 P 	 	 : OUT STD_LOGIC_VECTOR (35 DOWNTO 0));
END COMPONENT;



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL UNSIGNED_INTERMEDIATE, UNSIGNED_PRIME			: STD_LOGIC_VECTOR(34 DOWNTO 0);
SIGNAL UNSIGNED_RESULT										: STD_LOGIC_VECTOR(35 DOWNTO 0);


-- STRUCTURAL
----------------------------------------------------------------------------------
BEGIN

	-- UNSIGNED INPUTS ------------------------------------------------------------
	UNSIGNED_INTERMEDIATE 	<= ('0' & INTERMEDIATE);
	UNSIGNED_PRIME 			<= ('0' & PRIME);

	-- INSTANCES ------------------------------------------------------------------
	DSP : Reduce
	PORT MAP (
		CLK 	   => CLK,
		CE 	   => CE,
		SCLR 	   => RST,
		SEL(0)   => SUB,
		CARRYIN  => CARRY_IN,
		C 		   => UNSIGNED_INTERMEDIATE,
		CONCAT   => UNSIGNED_PRIME,
		P 		   => UNSIGNED_RESULT
	);
	
	-- UNSIGNED OUTPUTS -----------------------------------------------------------
	RESULT				 		<= UNSIGNED_RESULT(33 DOWNTO 0);
	CARRY_OUT 					<= UNSIGNED_RESULT(34);
	
END Structural;

