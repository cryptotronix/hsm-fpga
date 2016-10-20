----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Hardware Security Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			8/7/2013
-- MODULE NAME:			TB_MultiplicationUnit
--
--	REVISION:				1.00 - File created
--								1.01 - BugFixes
--
-- DESCRIPTION:			Testbench for the modular multiplication unit. This unit
--								has been tested for 50,000 random test vectors.
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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

LIBRARY STD;
USE STD.TEXTIO.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY TB_MultiplicationUnit IS
END TB_MultiplicationUnit;



-- ARCHITECTURE
---------------------------------------------------------------------------------- 
ARCHITECTURE behavior OF TB_MultiplicationUnit IS 
 
	-- COMPONENT DECLARATION FOR THE UNIT UNDER TEST (UUT) -----------------------
	COMPONENT MultiplicationUnit IS
	PORT ( A 	: IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
          B 	: IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
          CLK 	: IN  STD_LOGIC;
          CE 	: IN  STD_LOGIC;
          RST 	: IN  STD_LOGIC;
			 SAVE : IN  STD_LOGIC;
          DONE : OUT STD_LOGIC;
          C 	: OUT STD_LOGIC_VECTOR (33 DOWNTO 0));
	END COMPONENT;
    
   -- INPUTS ---------------------------------------------------------------------
   SIGNAL A 	: STD_LOGIC_VECTOR (33 DOWNTO 0) := (OTHERS => '0');
   SIGNAL B 	: STD_LOGIC_VECTOR (33 DOWNTO 0) := (OTHERS => '0');
   SIGNAL CLK 	: STD_LOGIC := '0';
   SIGNAL CE 	: STD_LOGIC := '0';
   SIGNAL RST 	: STD_LOGIC := '0';
	SIGNAL SAVE : STD_LOGIC := '0';

 	-- OUTPUTS --------------------------------------------------------------------
   SIGNAL DONE : STD_LOGIC;
   SIGNAL C 	: STD_LOGIC_VECTOR (33 DOWNTO 0);

   -- CLOCK PERIOD DEFINITIONS ---------------------------------------------------
   CONSTANT CLK_period 	: TIME := 10 NS;

	-- FILE HANDLING --------------------------------------------------------------
	FILE TESTVECTORS : TEXT;
	
BEGIN

	-- UNIT UNDER TEST ------------------------------------------------------------
   UUT : MultiplicationUnit
	PORT MAP (
		CLK 	=> CLK,
		RST 	=> RST,
		CE 	=> CE,
		SAVE	=> SAVE,
		DONE 	=> DONE,
		A 		=> A,
		B 		=> B,
		C 		=> C
	);

   -- CLOCK PROCESS --------------------------------------------------------------
   CLK_PROCESS: PROCESS
   BEGIN
		CLK <= '1';	WAIT FOR CLK_PERIOD/2;
		CLK <= '0';	WAIT FOR CLK_PERIOD/2;
   END PROCESS;
 
   -- STIMULUS PROCESS -----------------------------------------------------------
   STIM_PROCESS: PROCESS
		VARIABLE TVLINE : LINE;	
		VARIABLE VAR_A : STD_LOGIC_VECTOR(271 DOWNTO 0);
		VARIABLE VAR_B : STD_LOGIC_VECTOR(271 DOWNTO 0);
		VARIABLE VAR_C : STD_LOGIC_VECTOR(271 DOWNTO 0);			
   BEGIN	
	
      -- Hold reset state for 100 ns.
		RST <= '1'; WAIT FOR 100 NS; RST <= '0';

      WAIT FOR CLK_PERIOD*10;

		FILE_OPEN(TESTVECTORS, "../testvectors/tv_multiplication.dat", READ_MODE);
	
		-- TEST MULTIPLICATION -----------------------------------------------------
--		WHILE NOT (ENDFILE(TESTVECTORS)) LOOP	
			CE <= '1';
				
				WAIT FOR CLK_PERIOD*2;
					
--				READLINE(TESTVECTORS, TVLINE); READ(TVLINE, VAR_A);
--				READLINE(TESTVECTORS, TVLINE); READ(TVLINE, VAR_B);
--				READLINE(TESTVECTORS, TVLINE); READ(TVLINE, VAR_C);
				
				VAR_A := X"0000551da51c1e50e2a971f144f8ac2852435834c967b09c12d71603061117cd45fe";
				VAR_B := X"0000764cb1c0e1782274447f96fc43f82da2abca0da90348006ef8da0d24321d628e";
				VAR_C := X"00000000c8b43de2ea7fd721f7c80f07add0ee6bf1fa0a318a8b666ea7c3988e951e";

				FOR I IN 0 TO 7 LOOP
					A <= VAR_A(I*34+33 DOWNTO I*34);
					B <= VAR_B(I*34+33 DOWNTO I*34);
					WAIT FOR CLK_PERIOD;
				END LOOP;			
				A <= (OTHERS => '0');
				B <= (OTHERS => '0');			
					
				WAIT FOR CLK_PERIOD*37;
				
				SAVE <= '1';
					WAIT FOR CLK_PERIOD; ASSERT (C = VAR_C( 33 DOWNTO   0)) REPORT "INCORRECT RESULT" SEVERITY ERROR;
					WAIT FOR CLK_PERIOD; ASSERT (C = VAR_C( 67 DOWNTO  34)) REPORT "INCORRECT RESULT" SEVERITY ERROR;
					WAIT FOR CLK_PERIOD; ASSERT (C = VAR_C(101 DOWNTO  68)) REPORT "INCORRECT RESULT" SEVERITY ERROR;
					WAIT FOR CLK_PERIOD; ASSERT (C = VAR_C(135 DOWNTO 102)) REPORT "INCORRECT RESULT" SEVERITY ERROR;
					WAIT FOR CLK_PERIOD; ASSERT (C = VAR_C(169 DOWNTO 136)) REPORT "INCORRECT RESULT" SEVERITY ERROR;
					WAIT FOR CLK_PERIOD; ASSERT (C = VAR_C(203 DOWNTO 170)) REPORT "INCORRECT RESULT" SEVERITY ERROR;
					WAIT FOR CLK_PERIOD; ASSERT (C = VAR_C(237 DOWNTO 204)) REPORT "INCORRECT RESULT" SEVERITY ERROR;
					WAIT FOR CLK_PERIOD; ASSERT (C = VAR_C(271 DOWNTO 238)) REPORT "INCORRECT RESULT" SEVERITY ERROR;
				SAVE <= '0';

				WAIT FOR CLK_PERIOD*2;
				
			CE <= '0';
--		END LOOP;
		
      WAIT;
   END PROCESS;
END;
