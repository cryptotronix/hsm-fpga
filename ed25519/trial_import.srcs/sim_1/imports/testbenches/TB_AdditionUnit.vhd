----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Hardware Security Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			8/7/2013
-- MODULE NAME:			TB_AdditionUnit
--
--	REVISION:				1.00 - File created
--								1.01 - BugFixes
--
-- DESCRIPTION:			Testbench for the modular addition unit. This unit has
--								been tested for 50,000 random test vectors.
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
ENTITY TB_AdditionUnit IS
END TB_AdditionUnit;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE behavior OF TB_AdditionUnit IS 

   -- COMPONENT DECLARATION FOR THE UNIT UNDER TEST (UUT) ------------------------
   COMPONENT AdditionUnit IS
	PORT (CLK		: IN  STD_LOGIC;
			-- CONTROL PORTS --------------------------------
			RESET		: IN  STD_LOGIC;
			ENABLE	: IN  STD_LOGIC;
			SUB		: IN  STD_LOGIC;
			DONE		: OUT STD_LOGIC;
			FLAG		: OUT STD_LOGIC;
			-- DATA IN PORTS --------------------------------
			A 			: IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
         B 			: IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
			-- DATA OUT PORTS -------------------------------
			S	   	: OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
         R 			: OUT STD_LOGIC_VECTOR (33 DOWNTO 0));
	END COMPONENT;
    
   -- INPUTS ---------------------------------------------------------------------
   SIGNAL CLK 		: STD_LOGIC := '0';
   SIGNAL RESET 	: STD_LOGIC := '0';
   SIGNAL ENABLE	: STD_LOGIC := '0';
   SIGNAL SUB 		: STD_LOGIC := '0';
   SIGNAL A 		: STD_LOGIC_VECTOR (33 DOWNTO 0) := (OTHERS => '0');
   SIGNAL B 		: STD_LOGIC_VECTOR (33 DOWNTO 0) := (OTHERS => '0');

 	-- OUTPUTS --------------------------------------------------------------------
   SIGNAL DONE 	: STD_LOGIC;
	SIGNAL FLAG 	: STD_LOGIC;
   SIGNAL S 		: STD_LOGIC_VECTOR (33 DOWNTO 0);
   SIGNAL R 		: STD_LOGIC_VECTOR (33 DOWNTO 0);

   -- CLOCK PERIOD DEFINITIONS ---------------------------------------------------
   CONSTANT CLK_period 	: TIME := 10 NS;

	-- FILE HANDLING --------------------------------------------------------------
	FILE TESTVECTORS : TEXT;


-- TEST BENCH
----------------------------------------------------------------------------------
BEGIN

	-- UNIT UNDER TEST ------------------------------------------------------------
   UUT : AdditionUnit
	PORT MAP (
		CLK 		=> CLK,
		RESET		=> RESET,
		ENABLE 	=> ENABLE,
		SUB 		=> SUB,
		DONE 		=> DONE,
		FLAG 		=> FLAG,
		A 			=> A,
		B 			=> B,
		S			=> S,
		R 			=> R
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
		VARIABLE TEST_S, TEST_R : BOOLEAN;
		VARIABLE VAR_A : STD_LOGIC_VECTOR(271 DOWNTO 0);
		VARIABLE VAR_B : STD_LOGIC_VECTOR(271 DOWNTO 0);
		VARIABLE VAR_C : STD_LOGIC_VECTOR(271 DOWNTO 0);			
   BEGIN	
	
      -- Hold reset state for 100 ns.
		RESET <= '1'; WAIT FOR 100 NS; RESET <= '0';

      WAIT FOR CLK_PERIOD*10;

		FILE_OPEN(TESTVECTORS, "../testvectors/tv_addition.dat", READ_MODE);
		
		-- TEST ADDITION -----------------------------------------------------------
		SUB <= '0';		
		
		WHILE NOT (ENDFILE(TESTVECTORS)) LOOP	
			ENABLE <= '1';
				WAIT FOR CLK_PERIOD;	
				
				READLINE(TESTVECTORS, TVLINE); READ(TVLINE, VAR_A);
				READLINE(TESTVECTORS, TVLINE); READ(TVLINE, VAR_B);
				READLINE(TESTVECTORS, TVLINE); READ(TVLINE, VAR_C);
				
				TEST_S := TRUE; TEST_R := TRUE;
				
				A <= VAR_A( 33 DOWNTO   0); B <= VAR_B( 33 DOWNTO   0); WAIT FOR CLK_PERIOD;		
				
				A <= VAR_A( 67 DOWNTO  34); B <= VAR_B( 67 DOWNTO  34); WAIT FOR CLK_PERIOD;
				TEST_S := TEST_S AND (S = VAR_C(33 DOWNTO 0));
				TEST_R := TEST_R AND (R = VAR_C(33 DOWNTO 0));				
				
				A <= VAR_A(101 DOWNTO  68); B <= VAR_B(101 DOWNTO  68); WAIT FOR CLK_PERIOD;
				TEST_S := TEST_S AND (S = VAR_C(67 DOWNTO 34));
				TEST_R := TEST_R AND (R = VAR_C(67 DOWNTO 34));		
				
				A <= VAR_A(135 DOWNTO 102); B <= VAR_B(135 DOWNTO 102); WAIT FOR CLK_PERIOD;
				TEST_S := TEST_S AND (S = VAR_C(101 DOWNTO 68));
				TEST_R := TEST_R AND (R = VAR_C(101 DOWNTO 68));
				
				A <= VAR_A(169 DOWNTO 136); B <= VAR_B(169 DOWNTO 136); WAIT FOR CLK_PERIOD;
				TEST_S := TEST_S AND (S = VAR_C(135 DOWNTO 102));
				TEST_R := TEST_R AND (R = VAR_C(135 DOWNTO 102));
				
				A <= VAR_A(203 DOWNTO 170); B <= VAR_B(203 DOWNTO 170); WAIT FOR CLK_PERIOD;
				TEST_S := TEST_S AND (S = VAR_C(169 DOWNTO 136));
				TEST_R := TEST_R AND (R = VAR_C(169 DOWNTO 136));
				
				A <= VAR_A(237 DOWNTO 204); B <= VAR_B(237 DOWNTO 204); WAIT FOR CLK_PERIOD;
				TEST_S := TEST_S AND (S = VAR_C(203 DOWNTO 170));
				TEST_R := TEST_R AND (R = VAR_C(203 DOWNTO 170));
				
				A <= VAR_A(271 DOWNTO 238); B <= VAR_B(271 DOWNTO 238); WAIT FOR CLK_PERIOD;
				TEST_S := TEST_S AND (S = VAR_C(237 DOWNTO 204));
				TEST_R := TEST_R AND (R = VAR_C(237 DOWNTO 204));
				
				A <= (OTHERS => '0'); 		 B <= (OTHERS => '0'); 		  WAIT FOR CLK_PERIOD;	
				TEST_S := TEST_S AND (S = VAR_C(271 DOWNTO 238));
				TEST_R := TEST_R AND (R = VAR_C(271 DOWNTO 238));	
				
				ASSERT (TEST_S OR TEST_R) REPORT "RESULT INCORRECT" SEVERITY ERROR;
				
				RESET <= '1'; WAIT FOR CLK_PERIOD; RESET <= '0';				
				
			ENABLE <= '0';
		END LOOP;
		
		FILE_CLOSE(TESTVECTORS);
		
		WAIT;
   END PROCESS;

END;
