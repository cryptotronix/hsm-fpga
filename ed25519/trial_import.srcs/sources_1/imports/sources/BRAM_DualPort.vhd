----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Hardware Security Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			8/7/2014
-- MODULE NAME:			BRAM_DualPort
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
USE IEEE.NUMERIC_STD.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY BRAM_DualPort IS
	PORT ( CLK 	 : IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          ADDR1 : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
          ADDR2 : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);          
          WE1 	 : IN  STD_LOGIC;
          WE2 	 : IN  STD_LOGIC;
			 RE	 : IN  STD_LOGIC;
			 -- DATA IN PORTS --------------------------------
			 IN1 	 : IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
          IN2 	 : IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
			 -- DATA OUT PORTS -------------------------------
          OUT1  : OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
          OUT2  : OUT STD_LOGIC_VECTOR (33 DOWNTO 0));
END BRAM_DualPort;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF BRAM_DualPort IS



-- COMPONENT
----------------------------------------------------------------------------------
COMPONENT DPBRAM
	PORT ( CLKA	 : IN  STD_LOGIC;
			 WEA 	 : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
			 ADDRA : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
			 DINA  : IN  STD_LOGIC_VECTOR(33 DOWNTO 0);
			 DOUTA : OUT STD_LOGIC_VECTOR(33 DOWNTO 0);
			 CLKB  : IN  STD_LOGIC;
			 WEB 	 : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
			 ADDRB : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
			 DINB  : IN  STD_LOGIC_VECTOR(33 DOWNTO 0);
			 DOUTB : OUT STD_LOGIC_VECTOR(33 DOWNTO 0));
END COMPONENT;



-- SIGNAL
----------------------------------------------------------------------------------
SIGNAL ADDRESS_A, ADDRESS_B 	: STD_LOGIC_VECTOR (6 DOWNTO 0);
SIGNAL LSBS 						: UNSIGNED(2 DOWNTO 0);



-- STRUCTURAL
----------------------------------------------------------------------------------
BEGIN


	-- ADDRESS GENERATION ---------------------------------------------------------
	COUNTER : PROCESS(CLK)
	BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RE = '1' OR WE1 = '1' OR WE2 = '1') THEN
				LSBS <= LSBS + 1;
			ELSE
				LSBS <= "000";
			END IF;
		END IF;
	END PROCESS;

	ADDRESS_A <= ADDR1 & STD_LOGIC_VECTOR(LSBS);
	ADDRESS_B <= ADDR2 & STD_LOGIC_VECTOR(LSBS);

	-- INSTANCES ------------------------------------------------------------------
	BlockRAM : DPBRAM
	PORT MAP (
		CLKA 		=> CLK,
		WEA(0)	=> WE1,
		ADDRA		=> ADDRESS_A,
		DINA		=> IN1,
		DOUTA		=> OUT1,
		CLKB 		=> CLK,
		WEB(0) 	=> WE2,
		ADDRB		=> ADDRESS_B,
		DINB		=> IN2,
		DOUTB		=> OUT2
	);

END Structural;

