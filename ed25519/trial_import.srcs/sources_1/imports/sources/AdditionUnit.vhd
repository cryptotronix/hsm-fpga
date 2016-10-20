----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Hardware Security Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			8/7/2014
-- MODULE NAME:			AdditionUnit
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



-- ENTITY
----------------------------------------------------------------------------------
ENTITY AdditionUnit IS
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
			S	  		: OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
         R 			: OUT STD_LOGIC_VECTOR (33 DOWNTO 0));
END AdditionUnit;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF AdditionUnit IS



-- COMPONENT
----------------------------------------------------------------------------------
COMPONENT DSP_Addition_Operation IS
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
END COMPONENT;

COMPONENT DSP_Addition_Reduction IS
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
END COMPONENT;



-- CONSTANT
----------------------------------------------------------------------------------
CONSTANT P : STD_LOGIC_VECTOR (271 DOWNTO 0) := X"00007FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED";



-- STATES
----------------------------------------------------------------------------------
TYPE STATES IS (S_RESET, S_IDLE, S_RUN1, S_RUN2, S_RUN3, S_RUN4, S_RUN5, S_RUN6, S_RUN7, S_RUN8, S_DONE);
SIGNAL STATE, NEXT_STATE : STATES;



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL RESULT_OPERATION, RESULT_REDUCTION, PRIME	: STD_LOGIC_VECTOR (33 DOWNTO 0);
SIGNAL CARRY_OPERATION, CARRY_REDUCTION				: STD_LOGIC;

SIGNAL RESET_OPERATION, RESET_REDUCTION				: STD_LOGIC;
SIGNAL ENABLE_OPERATION, ENABLE_REDUCTION				: STD_LOGIC;



-- STRUCTURAL
----------------------------------------------------------------------------------
BEGIN						
	
	-- INSTANCES ------------------------------------------------------------------
	Operation : DSP_Addition_Operation
	PORT MAP (
		CLK					=> CLK,
		RST					=> RESET_OPERATION,
		CE						=> ENABLE_OPERATION,
		SUB					=> SUB,
		OP_A					=> A,
		OP_B					=> B,
		CARRY_IN				=> CARRY_OPERATION,
		RESULT				=> RESULT_OPERATION,
		CARRY_OUT			=> CARRY_OPERATION
	);
		
	Reduction : DSP_Addition_Reduction
	PORT MAP (
		CLK					=> CLK,
		RST					=> RESET_REDUCTION,
		CE						=> ENABLE_REDUCTION,
		SUB					=> SUB,
		INTERMEDIATE		=> RESULT_OPERATION,
		PRIME					=> PRIME,
		CARRY_IN				=> CARRY_REDUCTION,
		RESULT				=> RESULT_REDUCTION,
		CARRY_OUT			=> CARRY_REDUCTION 
	);



	-- 3-PROCESS FINITE STATE MACHINE ---------------------------------------------

		-- 1) STATE REGISTER PROCESS -----------------------------------------------
		STATE_REGISTER : PROCESS(CLK, RESET)
		BEGIN
			IF RISING_EDGE(CLK) THEN
				IF RESET = '1' THEN
					STATE <= S_RESET;
				ELSE
					STATE <= NEXT_STATE;
				END IF;
			END IF;
		END PROCESS;
			
		-- 2) STATE TRANSITION PROCESS ---------------------------------------------
		STATE_TRANSITION : PROCESS(STATE, ENABLE)
		BEGIN
			-- DEFAULT ASSIGNMENTS --------------------------------------------------
			NEXT_STATE <= STATE;
			-------------------------------------------------------------------------		
			CASE STATE IS
				WHEN S_RESET	=> NEXT_STATE <= S_IDLE;
				WHEN S_IDLE		=> IF(ENABLE = '1') THEN NEXT_STATE <= S_RUN1; END IF;
				WHEN S_RUN1		=> NEXT_STATE <= S_RUN2;
				WHEN S_RUN2		=> NEXT_STATE <= S_RUN3;
				WHEN S_RUN3		=> NEXT_STATE <= S_RUN4;
				WHEN S_RUN4		=> NEXT_STATE <= S_RUN5;
				WHEN S_RUN5		=> NEXT_STATE <= S_RUN6;
				WHEN S_RUN6		=> NEXT_STATE <= S_RUN7;
				WHEN S_RUN7		=> NEXT_STATE <= S_RUN8;
				WHEN S_RUN8		=> NEXT_STATE <= S_DONE;
				WHEN S_DONE		=> NEXT_STATE <= S_RESET;
			END CASE;			
		END PROCESS;

		-- 3) OUTPUT PROCESS -------------------------------------------------------
		OUTPUT : PROCESS(STATE)
		BEGIN
		
			-- DEFAULT ASSIGNMENTS --------------------------------------------------
			DONE					<= '0';
			
			RESET_OPERATION	<= '0';
			RESET_REDUCTION	<= '0';
			
			ENABLE_OPERATION	<= '0';
			ENABLE_REDUCTION	<= '0';
			
			PRIME					<= (OTHERS => '0');
			-------------------------------------------------------------------------
			
			CASE STATE IS
				----------------------------------------------------------------------
				WHEN S_RESET	=> RESET_OPERATION	<= '1';
										RESET_REDUCTION	<= '1';										
				----------------------------------------------------------------------
				WHEN S_IDLE		=> NULL;
				----------------------------------------------------------------------
				WHEN S_RUN1		=> ENABLE_OPERATION 	<= '1'; 	
										ENABLE_REDUCTION 	<= '1';
										PRIME 				<= P( 33 DOWNTO   0);	
				----------------------------------------------------------------------
				WHEN S_RUN2		=> ENABLE_OPERATION 	<= '1'; 	
										ENABLE_REDUCTION 	<= '1';
										PRIME 				<= P( 67 DOWNTO  34);	
				----------------------------------------------------------------------
				WHEN S_RUN3		=> ENABLE_OPERATION 	<= '1'; 	
										ENABLE_REDUCTION 	<= '1';
										PRIME 				<= P(101 DOWNTO  68);			
				----------------------------------------------------------------------
				WHEN S_RUN4		=> ENABLE_OPERATION 	<= '1'; 	
										ENABLE_REDUCTION 	<= '1';
										PRIME 				<= P(135 DOWNTO 102);					
				----------------------------------------------------------------------
				WHEN S_RUN5		=> ENABLE_OPERATION 	<= '1'; 	
										ENABLE_REDUCTION 	<= '1';
										PRIME 				<= P(169 DOWNTO 136);					
				----------------------------------------------------------------------
				WHEN S_RUN6		=> ENABLE_OPERATION 	<= '1'; 	
										ENABLE_REDUCTION 	<= '1';
										PRIME 				<= P(203 DOWNTO 170);					
				----------------------------------------------------------------------
				WHEN S_RUN7		=> ENABLE_OPERATION 	<= '1'; 	
										ENABLE_REDUCTION 	<= '1';
										PRIME 				<= P(237 DOWNTO 204);					
				----------------------------------------------------------------------
				WHEN S_RUN8		=> ENABLE_OPERATION 	<= '1'; 	
										ENABLE_REDUCTION 	<= '1';
										PRIME 				<= P(271 DOWNTO 238);			
				----------------------------------------------------------------------
				WHEN S_DONE		=> DONE		<= '1';
				----------------------------------------------------------------------
			END CASE;
		END PROCESS;

	-- OUTPUT ---------------------------------------------------------------------
	S <= RESULT_OPERATION;
	R <= RESULT_REDUCTION;	
	
	FLAG <= RESULT_OPERATION(17) WHEN STATE = S_DONE ELSE '0';
	
END Structural;

