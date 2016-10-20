----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			9/7/2014
-- MODULE NAME:			Curve25519Core
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
ENTITY Curve25519Core IS
	PORT ( CLK 	  : IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          CE 	  : IN  STD_LOGIC;
			 CMD 	  : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
          RESP   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			 -- DATA IN PORTS --------------------------------
          P 	  : IN  STD_LOGIC_VECTOR (33 DOWNTO 0);
          K 	  : IN  STD_LOGIC_VECTOR (254 DOWNTO 0);
			 -- DATA OUT PORTS -------------------------------
          RESULT : OUT STD_LOGIC_VECTOR (33 DOWNTO 0));
END Curve25519Core;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF Curve25519Core IS



-- COMPONENTS
----------------------------------------------------------------------------------
COMPONENT ArithmeticUnit IS
	PORT ( CLK  				: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST  				: IN  STD_LOGIC;
          CE 					: IN  STD_LOGIC;	
			 -- STATUS PORTS ---------------------------------
			 IDLE  				: OUT STD_LOGIC;
			 DONE  				: OUT STD_LOGIC;
			 ERROR  				: OUT STD_LOGIC;
			 -- ARITHMETIC CONTROL PORTS ---------------------
			 SET_POINT 			: IN  STD_LOGIC;
			 GET_POINT 			: IN  STD_LOGIC;
			 DOUBLE_AND_ADD	: IN  STD_LOGIC;
			 MULTIPLY			: IN  STD_LOGIC;			 			 
			 -- ADDRESS PORTS --------------------------------
			 ADDR_M1				: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			 ADDR_M2				: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			 ADDR_RES			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			 -- DATA IN PORTS --------------------------------			 
			 DAA_BIT				: IN  STD_LOGIC;
          POINT			   : IN  STD_LOGIC_VECTOR(33 DOWNTO 0);
			 -- DATA OUT PORT --------------------------------		
          RESULT			   : OUT STD_LOGIC_VECTOR(33 DOWNTO 0));		
END COMPONENT;

COMPONENT LSR255 IS
	PORT ( CLK 	: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST 	: IN  STD_LOGIC;
          CE  	: IN  STD_LOGIC;        
			 LOAD : IN  STD_LOGIC;
			 -- DATA IN PORT ---------------------------------
			 K   	: IN  STD_LOGIC_VECTOR (254 DOWNTO 0);  
			 -- DATA OUT PORT --------------------------------
          MSB 	: OUT STD_LOGIC);
END COMPONENT;

COMPONENT Counter IS
	GENERIC (WIDTH : POSITIVE := 12);
	PORT ( 	CLK :   IN  STD_LOGIC;
				CE :    IN  STD_LOGIC;
				RST :   IN  STD_LOGIC;
				Q : 	  OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0));
END COMPONENT;



-- STATES
----------------------------------------------------------------------------------
TYPE STATES IS (S_RESET, S_IDLE, S_LOAD_P, S_LOAD_Z, S_LOAD_X0, S_LOAD_Z0, S_LOAD_K, S_COMPUTE, S_INVERT, S_RESULT, S_DONE,
S_COMP_2, S_COMP_4, S_COMP_8, S_COMP_9, S_COMP_11, S_COMP_22, S_COMP_2_5_0, S_COMP_2_6_1, S_COMP_2_10_5, S_COMP_2_10_0,
S_COMP_2_11_1, S_COMP_2_20_10, S_COMP_2_20_0, S_COMP_2_21_1, S_COMP_2_40_20, S_COMP_2_40_0, S_COMP_2_41_1, S_COMP_2_50_10,
S_COMP_2_50_0, S_COMP_2_51_1, S_COMP_2_100_50, S_COMP_2_100_0, S_COMP_2_101_1, S_COMP_2_200_100, S_COMP_2_200_0, S_COMP_2_250_50,
S_COMP_2_250_0, S_COMP_2_251_1, S_COMP_2_252_2, S_COMP_2_253_3, S_COMP_2_254_4, S_COMP_2_255_5, S_COMP_FINAL, S_MUL);
SIGNAL STATE, NEXT_STATE : STATES;


-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL COMPUTE, LOAD_P, LOAD_K, RESET, GET_RES : STD_LOGIC;
SIGNAL IDLE, COMPUTING, DONE, ERROR, RET_RES : STD_LOGIC;

SIGNAL TIMER_EN, TIMER_RST : STD_LOGIC;
SIGNAL TIMER : STD_LOGIC_VECTOR(11 DOWNTO 0);

SIGNAL AU_EN, AU_RST, AU_SET, AU_GET, AU_DOUBLE_ADD, AU_MULTIPLY, AU_IDLE, AU_ERROR, AU_DONE : STD_LOGIC;
SIGNAL ADDR_M1, ADDR_M2, ADDR_RES : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL AU_POINT, AU_RESULT : STD_LOGIC_VECTOR(33 DOWNTO 0);

SIGNAL REG_EN, REG_LD, REG_RST, REG_BIT : STD_LOGIC;



-- BEHAVIORAL
----------------------------------------------------------------------------------
BEGIN

	-- COMMANDS -------------------------------------------------------------------
	COMPUTE <= CMD(0);
	LOAD_P  <= CMD(1);
	LOAD_K  <= CMD(2);
	RESET	  <= CMD(3);
	GET_RES <= CMD(4);
		
	-- RESPONSES ------------------------------------------------------------------
	RESP(0) <= IDLE;
	RESP(1) <= COMPUTING;
	RESP(2) <= DONE;
	RESP(3) <= ERROR;
	RESP(4) <= RET_RES;

	-- INSTANCES ------------------------------------------------------------------
	AU : ArithmeticUnit
	PORT MAP (
		CLK 		  		=> CLK,
		RST 		  		=> AU_RST,
		CE  		  		=> AU_EN,	
		IDLE		  		=> AU_IDLE,
		ERROR		  		=> AU_ERROR,
		DONE 		  		=> AU_DONE,
		SET_POINT  		=> AU_SET,
		GET_POINT  		=> AU_GET,
		DOUBLE_AND_ADD => AU_DOUBLE_ADD,
		MULTIPLY	  		=> AU_MULTIPLY,
		ADDR_M1	  		=> ADDR_M1,
		ADDR_M2	  		=> ADDR_M2,
		ADDR_RES  		=> ADDR_RES,		
		DAA_BIT	  		=> REG_BIT,		
		POINT		  		=> AU_POINT,
		RESULT 	  		=> AU_RESULT		
	);
	
	LSR : LSR255
	PORT MAP (
		CLK  => CLK,
		RST  => REG_RST,
		CE   => REG_EN,
		LOAD => REG_LD,
		K 	  => K,
		MSB  => REG_BIT	
	);
	
	ClockCounter: Counter
	GENERIC MAP (WIDTH => 12)
	PORT MAP (
		CLK => CLK,
		CE  => TIMER_EN,
		RST => TIMER_RST,
		Q 	 => TIMER
	);


	-- RESULT / OUTPUT ------------------------------------------------------------
	RESULT <= AU_RESULT;

	-- STATE CHANGE ---------------------------------------------------------------
	CHANGE: PROCESS(CLK, RESET, GET_RES)
	BEGIN
		IF RISING_EDGE(CLK) THEN
			IF RESET = '1' THEN
				STATE <= S_RESET;
			ELSE
				STATE <= NEXT_STATE;
			END IF;
		END IF;
	END PROCESS;
	
	-- CORE CONTROLLER FSM --------------------------------------------------------
	CORE_FSM : PROCESS(STATE, TIMER, CE, LOAD_P, LOAD_K, COMPUTE, GET_RES, AU_DONE, P, REG_BIT)
	BEGIN
		-- DEFAULT ASSIGNMENTS -----------------------------------------------------
		NEXT_STATE <= STATE;

		RESP(7 DOWNTO 5) <= (OTHERS => '0');		
		IDLE 		 <= '0';
		COMPUTING <= '0';
		DONE 		 <= '0';
		ERROR 	 <= '0';
		RET_RES	 <= '0';
		
		TIMER_RST <= '0';
		AU_RST	 <= '0';
		
		TIMER_EN  <= '0';
		AU_EN		 <= '0';
		
		AU_SET	 <= '0';
		AU_GET    <= '0';
		AU_DOUBLE_ADD <= '0';
		AU_MULTIPLY   <= '0';
		
		AU_POINT	 <= (OTHERS => '0');
		
		ADDR_M1	 <= (OTHERS => '0');
		ADDR_M2	 <= (OTHERS => '0');
		ADDR_RES	 <= (OTHERS => '0');
		
		REG_EN	 <= '0';
		REG_LD	 <= '0';
		REG_RST	 <= '0';
		
		-- STATE TRANSITIONS -------------------------------------------------------
		CASE STATE IS
			-- RESET CURVE25519CORE
			WHEN S_RESET 		=> TIMER_RST <= '1';
										REG_RST   <= '1';
										AU_RST	 <= '1';								
										
										NEXT_STATE <= S_IDLE;							
										
			-- WAIT FOR INSTRUCTIONS
			WHEN S_IDLE			=> IDLE <= '1';
			
										IF (CE = '1' AND LOAD_P = '1') THEN
											NEXT_STATE <= S_LOAD_P;
										ELSIF (CE = '1' AND LOAD_K = '1') THEN
											NEXT_STATE <= S_LOAD_K;
										ELSIF (CE = '1' AND COMPUTE = '1') THEN
											NEXT_STATE <= S_COMPUTE;
										ELSIF (CE = '1' AND GET_RES = '1') THEN
											NEXT_STATE <= S_RESULT;
										ELSE
											NEXT_STATE <= S_IDLE;
										END IF;
			
			-- LOAD CURVE POINT
			WHEN S_LOAD_P		=> COMPUTING <= '1';
										
										AU_EN		 <= '1';
										AU_SET	 <= '1';
										ADDR_RES	 <= "0000";
										
										AU_POINT	 <= P;
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_LOAD_Z;
										END IF;
										
			WHEN S_LOAD_Z		=> COMPUTING <= '1';
										
										AU_EN		 <= '1';										
										AU_SET	 <= '1';
										ADDR_RES	 <= "0001";
										
										IF (TIMER = x"001") THEN
											AU_POINT <= (0 => '1', OTHERS => '0');
										ELSE 
											AU_POINT <= (OTHERS => '0');
										END IF;
										
										TIMER_EN <= '1';
										IF (AU_DONE = '1') THEN 
											TIMER_RST <= '1';
											NEXT_STATE <= S_LOAD_X0;
										END IF;
										
			WHEN S_LOAD_X0		=> COMPUTING <= '1';
										
										AU_EN		 <= '1';			
										AU_SET	 <= '1';
										ADDR_RES	 <= "0010";
										
										IF (TIMER = x"001") THEN
											AU_POINT <= (0 => '1', OTHERS => '0');
										ELSE 
											AU_POINT <= (OTHERS => '0');
										END IF;

										TIMER_EN <= '1';
										IF (AU_DONE = '1') THEN 
											TIMER_RST <= '1';
											NEXT_STATE <= S_LOAD_Z0;
										END IF;
										
			WHEN S_LOAD_Z0		=> COMPUTING <= '1';
										
										AU_EN		 <= '1';			
										AU_SET	 <= '1';
										ADDR_RES	 <= "0011";
										
										AU_POINT	 <= (OTHERS => '0');
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_DONE;
										END IF;										
										
			-- LOAD MULTIPLICAND
			WHEN S_LOAD_K		=> COMPUTING <= '1';
			
										TIMER_EN  <= '1';
										REG_LD <= '1';
			
										IF (TIMER = x"007") THEN
											TIMER_RST <= '1';
											NEXT_STATE <= S_DONE;
										END IF;
										
			-- COMPUTE POINT MULTIPLICATION
			WHEN S_COMPUTE		=> COMPUTING <= '1';

										AU_EN		 	  <= '1';
										AU_DOUBLE_ADD <= '1';
											
										IF (AU_DONE = '1') THEN
											TIMER_EN <= '1';
											REG_EN  <= '1';	
											
											IF (TIMER = x"0FE") THEN
												TIMER_RST  <= '1';
												NEXT_STATE <= S_INVERT;
											END IF;
										END IF;
			
			WHEN S_INVERT		=> COMPUTING <= '1';
										NEXT_STATE <= S_COMP_2;
										
			WHEN S_COMP_2		=> COMPUTING 	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "0011";
										ADDR_M2  	<= "0011";
										ADDR_RES 	<= "1001";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_4;
										END IF;
										
			WHEN S_COMP_4		=> COMPUTING 	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1001";
										ADDR_M2  	<= "1001";
										ADDR_RES 	<= "1010";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_8;
										END IF;

			WHEN S_COMP_8		=> COMPUTING 	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1010";
										ADDR_M2  	<= "1010";
										ADDR_RES 	<= "1010";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_9;
										END IF;
										
			WHEN S_COMP_9		=> COMPUTING 	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "0011";
										ADDR_M2  	<= "1010";
										ADDR_RES 	<= "1010";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_11;
										END IF;										

			WHEN S_COMP_11		=> COMPUTING 	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1010";
										ADDR_M2  	<= "1001";
										ADDR_RES 	<= "1001";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_22;
										END IF;	
			
			WHEN S_COMP_22		=> COMPUTING 	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1001";
										ADDR_M2  	<= "1001";
										ADDR_RES 	<= "1011";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_5_0;
										END IF;	

			WHEN S_COMP_2_5_0	=> COMPUTING 	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1011";
										ADDR_M2  	<= "1010";
										ADDR_RES 	<= "1010";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_6_1;
										END IF;	
			
			WHEN S_COMP_2_6_1	=> COMPUTING 	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1010";
										ADDR_M2  	<= "1010";
										ADDR_RES 	<= "1011";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_10_5;
										END IF;	
			
			WHEN S_COMP_2_10_5 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1011";
										ADDR_M2  	<= "1011";
										ADDR_RES 	<= "1011";
										
										IF (AU_DONE = '1') THEN
											TIMER_EN <= '1';
											IF (TIMER = x"003") THEN
												NEXT_STATE <= S_COMP_2_10_0;
												TIMER_RST <= '1';
											END IF;
										END IF;				
			
			WHEN S_COMP_2_10_0 => COMPUTING 	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1010";
										ADDR_M2  	<= "1011";
										ADDR_RES 	<= "1011";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_11_1;
										END IF;	
										
			WHEN S_COMP_2_11_1 => COMPUTING <= '1';
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1011";
										ADDR_M2  	<= "1011";
										ADDR_RES		<= "1010";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_20_10;
										END IF;				
	
			WHEN S_COMP_2_20_10 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1010";
										ADDR_M2  	<= "1010";
										ADDR_RES 	<= "1010";
										
										IF (AU_DONE = '1') THEN
											TIMER_EN <= '1';
											IF (TIMER = x"008") THEN
												NEXT_STATE <= S_COMP_2_20_0;
												TIMER_RST <= '1';
											END IF;
										END IF;	

			WHEN S_COMP_2_20_0 => COMPUTING <= '1';
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1010";
										ADDR_M2  	<= "1011";
										ADDR_RES		<= "1010";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_21_1;
										END IF;		
										
			WHEN S_COMP_2_21_1 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1010";
										ADDR_M2  	<= "1010";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_40_20;
										END IF;														
	
			WHEN S_COMP_2_40_20 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1100";
										ADDR_M2  	<= "1100";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											TIMER_EN <= '1';
											IF (TIMER = x"012") THEN
												NEXT_STATE <= S_COMP_2_40_0;
												TIMER_RST <= '1';
											END IF;
										END IF;	

			WHEN S_COMP_2_40_0 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1010";
										ADDR_M2  	<= "1100";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_41_1;
										END IF;	
								
			WHEN S_COMP_2_41_1 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1100";
										ADDR_M2  	<= "1100";
										ADDR_RES 	<= "1010";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_50_10;
										END IF;	
										
			WHEN S_COMP_2_50_10 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1010";
										ADDR_M2  	<= "1010";
										ADDR_RES 	<= "1010";
										
										IF (AU_DONE = '1') THEN
											TIMER_EN <= '1';
											IF (TIMER = x"008") THEN
												NEXT_STATE <= S_COMP_2_50_0;
												TIMER_RST <= '1';
											END IF;
										END IF;
										
			WHEN S_COMP_2_50_0 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1010";
										ADDR_M2  	<= "1011";
										ADDR_RES 	<= "1010";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_51_1;
										END IF;	
										
			WHEN S_COMP_2_51_1 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1010";
										ADDR_M2  	<= "1010";
										ADDR_RES 	<= "1011";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_100_50;
										END IF;	
										
			WHEN S_COMP_2_100_50 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1011";
										ADDR_M2  	<= "1011";
										ADDR_RES 	<= "1011";
										
										IF (AU_DONE = '1') THEN
											TIMER_EN <= '1';
											IF (TIMER = x"030") THEN
												NEXT_STATE <= S_COMP_2_100_0;
												TIMER_RST <= '1';
											END IF;
										END IF;
										
			WHEN S_COMP_2_100_0 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1011";
										ADDR_M2  	<= "1010";
										ADDR_RES 	<= "1011";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_101_1;
										END IF;	
										
			WHEN S_COMP_2_101_1 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1011";
										ADDR_M2  	<= "1011";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_200_100;
										END IF;	
										
			WHEN S_COMP_2_200_100 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1100";
										ADDR_M2  	<= "1100";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											TIMER_EN <= '1';
											IF (TIMER = x"062") THEN
												NEXT_STATE <= S_COMP_2_200_0;
												TIMER_RST <= '1';
											END IF;
										END IF;
										
			WHEN S_COMP_2_200_0 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1100";
										ADDR_M2  	<= "1011";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_250_50;
										END IF;	
										
			WHEN S_COMP_2_250_50 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1100";
										ADDR_M2  	<= "1100";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											TIMER_EN <= '1';
											IF (TIMER = x"031") THEN
												NEXT_STATE <= S_COMP_2_250_0;
												TIMER_RST <= '1';
											END IF;
										END IF;
										
			WHEN S_COMP_2_250_0 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1100";
										ADDR_M2  	<= "1010";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_251_1;
										END IF;	
										
			WHEN S_COMP_2_251_1 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1100";
										ADDR_M2  	<= "1100";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_252_2;
										END IF;	
										
			WHEN S_COMP_2_252_2 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1100";
										ADDR_M2  	<= "1100";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_253_3;
										END IF;	
										
			WHEN S_COMP_2_253_3 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1100";
										ADDR_M2  	<= "1100";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_254_4;
										END IF;	
										
			WHEN S_COMP_2_254_4 => COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1100";
										ADDR_M2  	<= "1100";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_2_255_5;
										END IF;	
										
			WHEN S_COMP_2_255_5 =>  COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1100";
										ADDR_M2  	<= "1100";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_COMP_FINAL;
										END IF;	
										
			WHEN S_COMP_FINAL =>  COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1001";
										ADDR_M2  	<= "1100";
										ADDR_RES 	<= "1100";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_MUL;
										END IF;	
										
			WHEN S_MUL			=> COMPUTING	<= '1';
			
										AU_EN 		<= '1';
										AU_MULTIPLY <= '1';
										
										ADDR_M1  	<= "1100";
										ADDR_M2  	<= "0010";
										ADDR_RES 	<= "0000";
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_RESULT;
										END IF;	
								
			-- RETURN RESULT
			WHEN S_RESULT		=> RET_RES <= '1';
			
										AU_EN	 <= '1';
										AU_GET <= '1';
										
										IF (AU_DONE = '1') THEN
											NEXT_STATE <= S_DONE;
										END IF;
			
			-- DONE (LOADING OR COMPUTING)
			WHEN S_DONE			=> DONE <= '1';
										NEXT_STATE <= S_IDLE;
	
			-- ERROR CASE				
			WHEN OTHERS			=> ERROR <= '1';
										NEXT_STATE <= S_RESET;
		END CASE;
	END PROCESS;
	
END Behavioral;

