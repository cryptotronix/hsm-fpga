----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			8/7/2014
-- MODULE NAME:			MultiplicationUnit
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
ENTITY MultiplicationUnit IS
	PORT ( CLK 		: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 		: IN  STD_LOGIC;
          CE	 	: IN  STD_LOGIC;
			 SAVE 	: IN  STD_LOGIC;
          DONE 	: OUT STD_LOGIC;	
			 -- DATA IN PORTS --------------------------------
			 A 		: IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
          B 		: IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
			 -- DATA OUT PORT --------------------------------
          C 		: OUT STD_LOGIC_VECTOR (33 DOWNTO 0));
END MultiplicationUnit;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF MultiplicationUnit IS



-- COMPONENT
----------------------------------------------------------------------------------
COMPONENT LoadUnit IS
	PORT ( CLK 	: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 	: IN  STD_LOGIC;
          CE  	: IN  STD_LOGIC;
			 -- DATA IN PORTS --------------------------------
			 A   	: IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
          B   	: IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
			 -- DATA OUT PORTS -------------------------------
          M1  	: OUT STD_LOGIC_VECTOR (254 DOWNTO 0);
          M2  	: OUT STD_LOGIC_VECTOR (254 DOWNTO 0));
END COMPONENT;

COMPONENT RotateUnit IS
	PORT ( CLK 	: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 	: IN  STD_LOGIC;
          LOAD	: IN  STD_LOGIC;
          CE  	: IN  STD_LOGIC;
			 -- DATA IN PORTS --------------------------------
			 A   	: IN  STD_LOGIC_VECTOR (254 DOWNTO 0);
          B   	: IN  STD_LOGIC_VECTOR (254 DOWNTO 0);
			 -- DATA OUT PORTS -------------------------------
          ROTA : OUT STD_LOGIC_VECTOR (254 DOWNTO 0);
          ROTB : OUT STD_LOGIC_VECTOR (254 DOWNTO 0));
END COMPONENT;

COMPONENT MultiplyUnit IS
	PORT ( CLK 	: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 	: IN  STD_LOGIC;
          CE  	: IN  STD_LOGIC;
			 DONE : OUT STD_LOGIC;
			 -- DATA IN PORTS --------------------------------
			 A   	: IN  STD_LOGIC_VECTOR (254 DOWNTO 0);
          B   	: IN  STD_LOGIC_VECTOR (254 DOWNTO 0);
			 -- DATA OUT PORTS -------------------------------
          P		: OUT STD_LOGIC_VECTOR (644 DOWNTO 0));
END COMPONENT;

COMPONENT MulRegister IS
	PORT ( CLK 	: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 	: IN  STD_LOGIC;
          CE  	: IN  STD_LOGIC;
			 -- DATA IN PORT ---------------------------------
			 I   	: IN  STD_LOGIC_VECTOR (644 DOWNTO 0);      
			 -- DATA OUT PORT --------------------------------  
          O   	: OUT STD_LOGIC_VECTOR (644 DOWNTO 0));
END COMPONENT;

COMPONENT Accumulate IS
	PORT ( CLK 	: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 	: IN  STD_LOGIC;
          CE 	: IN  STD_LOGIC;
			 DONE : OUT STD_LOGIC;
			 -- DATA IN PORTS --------------------------------
			 SUMS : IN  STD_LOGIC_VECTOR (644 DOWNTO 0);
			 -- DATA OUT PORTS -------------------------------         
          RES 	: OUT STD_LOGIC_VECTOR (254 DOWNTO 0));
END COMPONENT;

COMPONENT StoreUnit IS
	PORT ( CLK 		: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 		: IN  STD_LOGIC;
          LOAD		: IN  STD_LOGIC;
          CE  		: IN  STD_LOGIC;
			 -- DATA IN PORT ---------------------------------
			 RESULT 	: IN  STD_LOGIC_VECTOR (254 DOWNTO 0);
			 -- DATA OUT PORT --------------------------------
          C   		: OUT STD_LOGIC_VECTOR (33 DOWNTO 0));
END COMPONENT;



-- STATES
----------------------------------------------------------------------------------
TYPE STATES IS (S_RESET, S_IDLE, S_LOAD, S_LD_ROT, S_MUL_ACC, S_MUX, S_STORE, S_DONE);
SIGNAL STATE, NEXT_STATE : STATES;



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL RESET_LOAD, RESET_ROTATE, RESET_MULTIPLY, RESET_REGISTER, RESET_ACCUMULATE, RESET_STORE 	: STD_LOGIC;
SIGNAL ENABLE_LOAD, ENABLE_ROTATE, ENABLE_MULTIPLY, ENABLE_REGISTER, ENABLE_ACCUMULATE 			: STD_LOGIC;
SIGNAL DONE_MULTIPLY, DONE_ACCUMULATE																				: STD_LOGIC;
SIGNAL LOAD_ROTATE, LOAD_STORE																						: STD_LOGIC;

SIGNAL MA, MB, ROTA, ROTB, RESULT																					: STD_LOGIC_VECTOR (254 DOWNTO 0);

SIGNAL REGISTER_IN, REGISTER_OUT 																					: STD_LOGIC_VECTOR (644 DOWNTO 0);

SIGNAL TIMER 																												: UNSIGNED (7 DOWNTO 0);



-- STRUCTURAL
----------------------------------------------------------------------------------
BEGIN

	-- INSTANCES ------------------------------------------------------------------
	Load : LoadUnit
	PORT MAP (
		CLK		=> CLK,
		RST		=> RESET_LOAD,
		CE			=> ENABLE_LOAD,
		A			=> A,
		B			=> B,
		M1			=> MA,
		M2			=> MB
	);

	Rotate : RotateUnit
	PORT MAP (
		CLK		=> CLK,
		RST		=> RESET_ROTATE,
		LOAD		=> LOAD_ROTATE,
		CE			=> ENABLE_ROTATE,
		A			=> MA,
		B			=> MB,
		ROTA		=> ROTA,
		ROTB		=> ROTB
	);
	
	Mul : MultiplyUnit
	PORT MAP (
		CLK		=> CLK,
		RST		=> RESET_MULTIPLY,
		CE			=> ENABLE_MULTIPLY,
		DONE		=> DONE_MULTIPLY,
		A			=> ROTA,
		B			=> ROTB,
		P			=> REGISTER_IN
	);
	
	Reg : MulRegister
	PORT MAP (
		CLK		=>	CLK,
		RST		=> RESET_REGISTER,
		CE			=> ENABLE_REGISTER,
		I			=> REGISTER_IN,
		O			=> REGISTER_OUT
	);

	Acc : Accumulate
	PORT MAP (
		CLK		=> CLK,
		RST		=> RESET_ACCUMULATE,
		CE			=> ENABLE_ACCUMULATE,
		DONE		=> DONE_ACCUMULATE,
		SUMS		=> REGISTER_OUT,
		RES		=> RESULT
	);
	
	Store : StoreUnit
	PORT MAP (
		CLK 		=> CLK,
		RST 		=> RESET_STORE,
		LOAD 		=> LOAD_STORE,
		CE  		=> SAVE,
		RESULT	=> RESULT,
		C   		=> C	
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
		STATE_TRANSITION : PROCESS(STATE, CE, TIMER, DONE_MULTIPLY, DONE_ACCUMULATE)
		BEGIN
			-- DEFAULT ASSIGNMENTS --------------------------------------------------
			NEXT_STATE <= STATE;
			-------------------------------------------------------------------------			
			CASE STATE IS
				WHEN S_RESET	=> NEXT_STATE 		<= S_IDLE;
				WHEN S_IDLE		=> IF(CE = '1') THEN
											NEXT_STATE 	<= S_LOAD;
										END IF;
				WHEN S_LOAD		=> IF(TIMER = x"A") THEN
											NEXT_STATE 	<= S_LD_ROT;
										END IF;
				WHEN S_LD_ROT	=> NEXT_STATE 		<= S_MUL_ACC;
				WHEN S_MUL_ACC	=> IF(DONE_MULTIPLY = '1') THEN
											NEXT_STATE 	<= S_MUX;
										END IF;
				WHEN S_MUX		=> IF(CE = '1') THEN
											NEXT_STATE 	<= S_LD_ROT;
										ELSE
											NEXT_STATE 	<= S_STORE;
										END IF;
				WHEN S_STORE	=>	IF(TIMER = x"A") THEN
											NEXT_STATE <= S_DONE;
										END IF;
				WHEN S_DONE		=> NEXT_STATE <= S_IDLE;
			END CASE;			
		END PROCESS;
		
		-- 3) OUTPUT PROCESS -------------------------------------------------------
		OUTPUT : PROCESS(STATE, TIMER)
		BEGIN
			-- DEFAULT ASSIGNMENTS --------------------------------------------------
			RESET_LOAD				<= '0';
			RESET_ROTATE			<= '0';
			RESET_MULTIPLY			<= '0';
			RESET_REGISTER			<= '0';
			RESET_ACCUMULATE		<= '0';
			RESET_STORE				<= '0';
			
			ENABLE_LOAD				<= '0';
			ENABLE_ROTATE			<= '0';
			ENABLE_MULTIPLY		<= '0';
			ENABLE_REGISTER		<= '0';
			ENABLE_ACCUMULATE		<= '0';
			
			LOAD_ROTATE				<= '0';
			LOAD_STORE				<= '0';
			
			DONE						<= '0';
			-------------------------------------------------------------------------	
			
			CASE STATE IS
				----------------------------------------------------------------------	
				WHEN S_RESET	=> RESET_LOAD				<= '1';
										RESET_ROTATE			<= '1';
										RESET_MULTIPLY			<= '1';
										RESET_REGISTER			<= '1';
										RESET_ACCUMULATE		<= '1';
										RESET_STORE 			<= '1';
				----------------------------------------------------------------------											
				WHEN S_IDLE		=> NULL;
				----------------------------------------------------------------------					
				WHEN S_LOAD		=> ENABLE_LOAD				<= '1';
				----------------------------------------------------------------------					
				WHEN S_LD_ROT	=> RESET_LOAD				<= '1';
										LOAD_ROTATE				<= '1';										
										ENABLE_MULTIPLY		<= '1';
										ENABLE_ACCUMULATE		<= '1';
				----------------------------------------------------------------------											
				WHEN S_MUL_ACC	=> ENABLE_ROTATE			<= '1';				
										ENABLE_MULTIPLY		<= '1';
										ENABLE_ACCUMULATE		<= '1';
										
										IF (TIMER < X"08") THEN				-- LOAD NEXT
											ENABLE_LOAD			<= '1';
										END IF;
										
										IF (TIMER = x"01") THEN				-- RESET MUL AND ACC
											RESET_MULTIPLY		<= '1';
											RESET_ACCUMULATE	<= '1';
										END IF;
										
										IF (TIMER = x"0A") THEN
											DONE 					<= '1';
										END IF;
				----------------------------------------------------------------------	
				WHEN S_MUX		=> ENABLE_REGISTER		<= '1';
										LOAD_STORE				<= '1';
										ENABLE_LOAD				<= '1';
										RESET_ROTATE			<= '1';										
				----------------------------------------------------------------------	
				WHEN S_STORE	=> NULL;
				----------------------------------------------------------------------	
				WHEN S_DONE		=> DONE		<= '1';
				----------------------------------------------------------------------
			END CASE;
		END PROCESS;
		
		-- 4) TIMER PROCESS
		-------------------------------------------------------------------------------
		WAIT_PROC : PROCESS (CLK)
		BEGIN
			IF RISING_EDGE(CLK) THEN
				IF (STATE = S_LOAD OR STATE = S_STORE OR STATE = S_MUL_ACC) THEN
					TIMER <= TIMER - 1;
				ELSE
					TIMER <= x"11";
				END IF;
			END IF;
		END PROCESS WAIT_PROC;	
		
END Structural;

