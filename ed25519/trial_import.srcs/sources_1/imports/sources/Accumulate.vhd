----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			8/7/2014
-- MODULE NAME:			AccumulationUnit
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
ENTITY Accumulate IS
	PORT ( CLK 	: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 	: IN  STD_LOGIC;
          CE 	: IN  STD_LOGIC;
			 DONE : OUT STD_LOGIC;
			 -- DATA IN PORTS --------------------------------
			 SUMS : IN  STD_LOGIC_VECTOR (644 DOWNTO 0);
			 -- DATA OUT PORTS -------------------------------         
          RES 	: OUT STD_LOGIC_VECTOR (254 DOWNTO 0));
END Accumulate;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF Accumulate IS



-- COMPONENT
----------------------------------------------------------------------------------
COMPONENT DSP_Accumulate_Operation IS
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
END COMPONENT;

COMPONENT DSP_Accumulate_Reduction IS
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
END COMPONENT;

COMPONENT CarryEstimator IS
    PORT ( A : IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
           B : IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
           C : IN  STD_LOGIC_VECTOR ( 8 DOWNTO 0);
           F : OUT STD_LOGIC);
END COMPONENT;



-- STATES
----------------------------------------------------------------------------------
TYPE STATES IS (S_RESET, S_IDLE, S_RUN1, S_RUN2, S_RUN3, S_RUN4, S_RUN5, S_RUN6, S_RUN7, S_RUN8,
					 S_RUN9, S_RUN10, S_RUN11, S_RUN12, S_RUN13, S_RUN14, S_RUN15, S_RUN16, S_DONE);
SIGNAL STATE, NEXT_STATE : STATES;



-- CONSTANT
----------------------------------------------------------------------------------
CONSTANT ONE_P : STD_LOGIC_VECTOR (271 DOWNTO 0) := X"00007FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED";
CONSTANT TWO_P : STD_LOGIC_VECTOR (271 DOWNTO 0) := X"0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDA";



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL RESET_OPERATION, RESET_REDUCTION 				: STD_LOGIC;
SIGNAL CARRY_OPERATION, CARRY_REDUCTION 				: STD_LOGIC;
SIGNAL ENABLE_OPERATION, ENABLE_REDUCTION 			: STD_LOGIC;
SIGNAL FLAG														: STD_LOGIC;

SIGNAL SUM														: STD_LOGIC_VECTOR (42 DOWNTO 0);
SIGNAL HIGH1													: STD_LOGIC_VECTOR (20 DOWNTO 0);
SIGNAL HIGH2													: STD_LOGIC_VECTOR ( 8 DOWNTO 0);
SIGNAL START 													: STD_LOGIC_VECTOR ( 0 DOWNTO 0);

SIGNAL RESULT_OPERATION, RESULT_REDUCTION, PRIME 	: STD_LOGIC_VECTOR (16 DOWNTO 0);

SIGNAL UNREDUCED, REDUCED 									: STD_LOGIC_VECTOR(254 DOWNTO 0) := (OTHERS => '0');



-- STRUCTURAL
----------------------------------------------------------------------------------
BEGIN

	-- INSTANCES ------------------------------------------------------------------
	Operation : DSP_Accumulate_Operation
	PORT MAP (
		CLK			=> CLK,
		RST			=> RESET_OPERATION,
		CE				=> ENABLE_OPERATION,
		START			=>	START,
		SUM			=>	SUM,
		H1				=> HIGH1,
		H2				=> HIGH2,
		RESULT		=> RESULT_OPERATION,
		CARRY 		=> CARRY_OPERATION
	);
	
	Reduction : DSP_Accumulate_Reduction
	PORT MAP (
		CLK			=> CLK,
		RST			=> RESET_REDUCTION,
		CE				=> ENABLE_REDUCTION,
		CHUNK 		=> RESULT_OPERATION,
		PRIME			=> PRIME,
		CARRY_IN		=> CARRY_REDUCTION,
		RESULT		=> RESULT_REDUCTION,
		CARRY_OUT	=> CARRY_REDUCTION
	);
	
	Estimator : CarryEstimator
	PORT MAP (
		A				=> SUMS(618 DOWNTO 602),
		B				=> SUMS(592 DOWNTO 576),
		C				=> SUMS(558 DOWNTO 550),
		F				=> FLAG
	);
	
	-- 3-PROCESS FSM TO REALIZE ARITHMETIC UNIT -----------------------------------

		-- 1) STATE REGISTER PROCESS -----------------------------------------------
		STATE_REGISTER : PROCESS(CLK, RST)
		BEGIN
			IF RISING_EDGE(CLK) THEN
				IF RST = '1' THEN
					STATE <= S_RESET;
				ELSE
					STATE <= NEXT_STATE;
				END IF;
			END IF;
		END PROCESS;

		-- 2) STATE TRANSITION PROCESS ---------------------------------------------
		STATE_TRANSITION : PROCESS(STATE, CE)
		BEGIN
			-- DEFAULT ASSIGNMENTS --------------------------------------------------
			NEXT_STATE <= STATE;
			-------------------------------------------------------------------------			
			CASE STATE IS
				WHEN S_RESET	=> NEXT_STATE <= S_IDLE;
				WHEN S_IDLE		=> IF(CE = '1') THEN NEXT_STATE <= S_RUN1; END IF;
				WHEN S_RUN1		=> NEXT_STATE <= S_RUN2;
				WHEN S_RUN2		=> NEXT_STATE <= S_RUN3;
				WHEN S_RUN3		=> NEXT_STATE <= S_RUN4;
				WHEN S_RUN4		=> NEXT_STATE <= S_RUN5;
				WHEN S_RUN5		=> NEXT_STATE <= S_RUN6;
				WHEN S_RUN6		=> NEXT_STATE <= S_RUN7;
				WHEN S_RUN7		=> NEXT_STATE <= S_RUN8;
				WHEN S_RUN8		=> NEXT_STATE <= S_RUN9;
				WHEN S_RUN9		=> NEXT_STATE <= S_RUN10;
				WHEN S_RUN10	=> NEXT_STATE <= S_RUN11;
				WHEN S_RUN11	=> NEXT_STATE <= S_RUN12;
				WHEN S_RUN12	=> NEXT_STATE <= S_RUN13;
				WHEN S_RUN13	=> NEXT_STATE <= S_RUN14;
				WHEN S_RUN14	=> NEXT_STATE <= S_RUN15;
				WHEN S_RUN15	=> NEXT_STATE <= S_RUN16;
				WHEN S_RUN16	=> NEXT_STATE <= S_DONE;
				WHEN S_DONE		=> NEXT_STATE <= S_IDLE;
			END CASE;			
		END PROCESS;

		-- 3) OUTPUT PROCESS -------------------------------------------------------
		OUTPUT : PROCESS(STATE, SUMS)
		BEGIN
			-- DEFAULT ASSIGNMENTS --------------------------------------------------
			RESET_OPERATION	<= '0';
			RESET_REDUCTION	<= '0';
			
			ENABLE_OPERATION	<= '0';
			ENABLE_REDUCTION	<= '0';
			
			START					<= "0";
			
			HIGH1					<= (OTHERS => '0');
			HIGH2					<= (OTHERS => '0');
			
			SUM					<= (OTHERS => '0');
			PRIME					<= (OTHERS => '0');
			
			DONE					<= '0';
			-------------------------------------------------------------------------
			
			CASE STATE IS
				----------------------------------------------------------------------	
				WHEN S_RESET	=>	RESET_OPERATION				<= '1';
										RESET_REDUCTION				<= '1';
				----------------------------------------------------------------------											
				WHEN S_IDLE		=> NULL;
				----------------------------------------------------------------------	
				WHEN S_RUN1		=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										START								<= "1";
										HIGH1 							<= SUMS(639 DOWNTO 619);
										HIGH2 							<= SUMS(601 DOWNTO 593);
										SUM 								<= SUMS(42  DOWNTO 0);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(16 DOWNTO 0);
										ELSE
											PRIME							<= TWO_P(16 DOWNTO 0);
										END IF;
				----------------------------------------------------------------------
				WHEN S_RUN2		=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= SUMS(85  DOWNTO 43);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(33 DOWNTO 17);
										ELSE
											PRIME							<= TWO_P(33 DOWNTO 17);
										END IF;
				----------------------------------------------------------------------
				WHEN S_RUN3		=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= SUMS(128 DOWNTO 86);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(50 DOWNTO 34);	
										ELSE
											PRIME							<= TWO_P(50 DOWNTO 34);
										END IF;											
				----------------------------------------------------------------------									
				WHEN S_RUN4		=>	ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= SUMS(171 DOWNTO 129);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(67 DOWNTO 51);
										ELSE
											PRIME							<= TWO_P(67 DOWNTO 51);
										END IF;
				----------------------------------------------------------------------							
				WHEN S_RUN5		=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= SUMS(214 DOWNTO 172);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(84 DOWNTO 68);	
										ELSE
											PRIME							<= TWO_P(84 DOWNTO 68);
										END IF;
				----------------------------------------------------------------------									
				WHEN S_RUN6		=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= SUMS(257 DOWNTO 215);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(101 DOWNTO 85);
										ELSE
											PRIME							<= TWO_P(101 DOWNTO 85);
										END IF;											
				----------------------------------------------------------------------									
				WHEN S_RUN7		=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM								<= SUMS(300 DOWNTO 258);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(118 DOWNTO 102);
										ELSE
											PRIME							<= TWO_P(118 DOWNTO 102);
										END IF;
				----------------------------------------------------------------------										
				WHEN S_RUN8		=>	ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= SUMS(343 DOWNTO 301);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(135 DOWNTO 119);
										ELSE
											PRIME							<= TWO_P(135 DOWNTO 119);
										END IF;
				----------------------------------------------------------------------									
				WHEN S_RUN9		=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= SUMS(386 DOWNTO 344);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(152 DOWNTO 136);
										ELSE
											PRIME							<= TWO_P(152 DOWNTO 136);
										END IF;
				----------------------------------------------------------------------								
				WHEN S_RUN10	=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= SUMS(429 DOWNTO 387);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(169 DOWNTO 153);
										ELSE
											PRIME							<= TWO_P(169 DOWNTO 153);
										END IF;
				----------------------------------------------------------------------								
				WHEN S_RUN11	=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= SUMS(472 DOWNTO 430);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(186 DOWNTO 170);
										ELSE
											PRIME							<= TWO_P(186 DOWNTO 170);
										END IF;
				----------------------------------------------------------------------									
				WHEN S_RUN12	=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= SUMS(515 DOWNTO 473);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(203 DOWNTO 187);
										ELSE
											PRIME							<= TWO_P(203 DOWNTO 187);
										END IF;											
				----------------------------------------------------------------------									
				WHEN S_RUN13	=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= SUMS(558 DOWNTO 516);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(220 DOWNTO 204);
										ELSE
											PRIME							<= TWO_P(220 DOWNTO 204);
										END IF;											
				----------------------------------------------------------------------									
				WHEN S_RUN14	=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= "000000000" & SUMS(592 DOWNTO 559);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(237 DOWNTO 221);		
										ELSE
											PRIME							<= TWO_P(237 DOWNTO 221);
										END IF;											
				----------------------------------------------------------------------					
				WHEN S_RUN15	=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										SUM 								<= "00000000000000000000000000" & SUMS(618 DOWNTO 602);
										IF (FLAG = '0') THEN
											PRIME							<= ONE_P(254 DOWNTO 238);
										ELSE
											PRIME							<= TWO_P(254 DOWNTO 238);
										END IF;											
				----------------------------------------------------------------------	
				WHEN S_RUN16	=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';						
				----------------------------------------------------------------------	
				WHEN S_DONE		=> ENABLE_OPERATION				<= '1';
										ENABLE_REDUCTION				<= '1';
										DONE								<= '1';
				----------------------------------------------------------------------	
			END CASE;
		END PROCESS;

	-- REGISTERS FOR UNREDUCED/REDUCED RESULT -------------------------------------
	REGISTER_PROCESS : PROCESS(CLK)
	BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RESET_OPERATION = '1') THEN
				UNREDUCED 	<= (OTHERS => '0');
				REDUCED 		<= (OTHERS => '0');
			ELSIF (ENABLE_OPERATION = '1') THEN
				UNREDUCED  	<= RESULT_OPERATION & UNREDUCED(254 DOWNTO 17);
				REDUCED 		<= RESULT_REDUCTION & REDUCED(254 DOWNTO 17);
			ELSE
				UNREDUCED	<= UNREDUCED;
				REDUCED		<= REDUCED;
			END IF;
		END IF;
	END PROCESS;

	-- OUTPUT ---------------------------------------------------------------------
	RES <= REDUCED WHEN (CARRY_OPERATION = '1' OR FLAG = '1') ELSE UNREDUCED;
		
END Structural;

