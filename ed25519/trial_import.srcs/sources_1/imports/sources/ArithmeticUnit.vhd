----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			9/7/2014
-- MODULE NAME:			ArithmeticUnit
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
ENTITY ArithmeticUnit IS
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
END ArithmeticUnit;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF ArithmeticUnit IS



-- COMPONENT
----------------------------------------------------------------------------------
COMPONENT BRAM_DualPort IS
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
END COMPONENT;

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
			S	  		: OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
         R 			: OUT STD_LOGIC_VECTOR (33 DOWNTO 0));
END COMPONENT;

COMPONENT MultiplicationUnit IS
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
END COMPONENT;

COMPONENT Flag_Register IS
	PORT ( CLK : 	IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
			 RST :   IN	 STD_LOGIC;
          SET : 	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
			 -- DATA OUT PORT --------------------------------
          FLAGS : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
END COMPONENT;



-- STATES
----------------------------------------------------------------------------------
TYPE STATES IS (S_RESET, S_IDLE, S_GET, S_SET,
S_ADD1, S_ADD2, S_ADD3, S_ADD4,
S_SUB1, S_SUB2, S_SUB3, S_SUB4,
S_TRANS1, S_TRANS2,
S_MUL1, S_MUL2, S_MUL3, S_MUL4, S_MUL5, S_MUL6, S_MUL7, S_MUL8, S_MUL9, S_MUL10, S_MUL11,
S_WAIT1, S_WAIT2, S_WAIT3,
S_STORE1, S_STORE2, S_STORE3,
S_MUL, S_DONE);
SIGNAL STATE, NEXT_STATE : STATES;



-- CONSTANTS
----------------------------------------------------------------------------------
CONSTANT NO_ADDR	: STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => 'Z');



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL OPERATION_DONE, ENABLE_INPUT, ENABLE_OUTPUT, TRANSFER 	: STD_LOGIC;

SIGNAL RAM1_IN1, RAM1_IN2, RAM2_IN1, RAM2_IN2 						: STD_LOGIC_VECTOR(33 DOWNTO 0);
SIGNAL RAM1_OUT1, RAM1_OUT2, RAM2_OUT1, RAM2_OUT2 					: STD_LOGIC_VECTOR(33 DOWNTO 0);
SIGNAL RAM1_ADDR1, RAM1_ADDR2, RAM2_ADDR1, RAM2_ADDR2 			: STD_LOGIC_VECTOR(3 DOWNTO 0);

SIGNAL RAM1_WE1, RAM1_WE2, RAM2_WE1, RAM2_WE2						: STD_LOGIC;
SIGNAL RAM1_READ, RAM2_READ 												: STD_LOGIC;

SIGNAL ADD_OUT1, ADD_OUT2 													: STD_LOGIC_VECTOR(33 DOWNTO 0);

SIGNAL A_EN, A_RST, A_SUB, A_DONE, A_FLAG 							: STD_LOGIC;
SIGNAL M_EN, M_RST, M_SAVE, M_DONE 										: STD_LOGIC;

SIGNAL TIMER 																	: UNSIGNED(7 DOWNTO 0);
SIGNAL T_EN, T_RST 															: STD_LOGIC;

SIGNAL F_RST 																	: STD_LOGIC;
SIGNAL FLAGS, F_SET 															: STD_LOGIC_VECTOR(7 DOWNTO 0);



-- STRUCTURAL
----------------------------------------------------------------------------------
BEGIN						
	
	-- INPUT ----------------------------------------------------------------------
	RAM2_IN1 	<= POINT 		WHEN ENABLE_INPUT = '1' 	ELSE (OTHERS => '0');
	
	-- OUTPUT ---------------------------------------------------------------------
	RESULT 		<= RAM2_OUT1 	WHEN ENABLE_OUTPUT = '1'	ELSE (OTHERS => '0');	
	
	-- TRANSFER -------------------------------------------------------------------
	RAM1_IN1		<= RAM2_OUT1 	WHEN TRANSFER = '1' 			ELSE ADD_OUT1;
	RAM1_IN2		<= RAM2_OUT2 	WHEN TRANSFER = '1' 			ELSE ADD_OUT2;
	
	-- INSTANCES ------------------------------------------------------------------
	BRAM1 : BRAM_DualPort
	PORT MAP (
		CLK		=> CLK,
		ADDR1		=> RAM1_ADDR1,
		ADDR2		=> RAM1_ADDR2,
		WE1		=> RAM1_WE1,
		WE2		=> RAM1_WE2,
		RE			=> RAM1_READ,
		IN1 		=> RAM1_IN1,
		IN2		=> RAM1_IN2,
		OUT1		=> RAM1_OUT1,
		OUT2		=> RAM1_OUT2
	);

	BRAM2 : BRAM_DualPort
	PORT MAP (
		CLK		=> CLK,
		ADDR1		=> RAM2_ADDR1,
		ADDR2		=> RAM2_ADDR2,
		WE1		=> RAM2_WE1,
		WE2		=> RAM2_WE2,
		RE			=> RAM2_READ,
		IN1 		=> RAM2_IN1,
		IN2		=> RAM2_IN2,
		OUT1		=> RAM2_OUT1,
		OUT2		=> RAM2_OUT2
	);	
	
	Addition : AdditionUnit
	PORT MAP (
		CLK		=> CLK,
		RESET		=> A_RST,
		ENABLE	=> A_EN,
		SUB		=> A_SUB,
		DONE		=> A_DONE,
		FLAG		=> A_FLAG,
		A			=> RAM2_OUT1,
		B			=> RAM2_OUT2,
		S			=> ADD_OUT1,
		R			=> ADD_OUT2
	);
	
	Multiplication : MultiplicationUnit
	PORT MAP (
		CLK		=> CLK,
		RST		=> M_RST,
		CE			=> M_EN,
		SAVE		=> M_SAVE,
		DONE		=> M_DONE,
		A			=> RAM1_OUT1,
		B			=> RAM1_OUT2,
		C			=> RAM2_IN2	
	);
	
	FlagRegister : Flag_Register
	PORT MAP (
		CLK		=> CLK,
		RST		=> F_RST,
		SET		=> F_SET,
		FLAGS		=> FLAGS
	);
	
	

	-- 3-PROCESS FSM TO REALIZE ADDITION UNIT -------------------------------------

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
		STATE_TRANSITION : PROCESS(STATE, CE, GET_POINT, SET_POINT, DOUBLE_AND_ADD, MULTIPLY, TIMER)
		BEGIN
			-- DEFAULT ASSIGNMENTS --------------------------------------------------
			NEXT_STATE <= STATE;
			-------------------------------------------------------------------------			
			CASE STATE IS
				WHEN S_RESET	=> NEXT_STATE <= S_IDLE;
				WHEN S_IDLE		=> IF		(CE = '1' AND GET_POINT = '1')		THEN NEXT_STATE <= S_GET; 
										ELSIF	(CE = '1' AND SET_POINT = '1') 		THEN NEXT_STATE <= S_SET;
										ELSIF	(CE = '1' AND DOUBLE_AND_ADD = '1') THEN NEXT_STATE <= S_ADD1;
										ELSIF	(CE = '1' AND MULTIPLY = '1') 		THEN NEXT_STATE <= S_MUL;
										END IF;
				WHEN S_GET		=> IF(TIMER = x"08") THEN NEXT_STATE <= S_DONE; 	END IF;
				WHEN S_SET		=> IF(TIMER = x"08") THEN NEXT_STATE <= S_DONE; 	END IF;
				WHEN S_ADD1		=> IF(TIMER = x"09") THEN NEXT_STATE <= S_MUL1; 	END IF;
				WHEN S_MUL1		=> IF(TIMER = x"08") THEN NEXT_STATE <= S_SUB1; 	END IF;
				WHEN S_SUB1		=> IF(TIMER = x"09") THEN NEXT_STATE <= S_MUL2; 	END IF;
				WHEN S_MUL2		=> IF(TIMER = x"08") THEN NEXT_STATE <= S_ADD2; 	END IF;
				WHEN S_ADD2		=> IF(TIMER = x"09") THEN NEXT_STATE <= S_MUL3; 	END IF;
				WHEN S_MUL3		=> IF(TIMER = x"08") THEN NEXT_STATE <= S_SUB2; 	END IF;
				WHEN S_SUB2		=> IF(TIMER = x"09") THEN NEXT_STATE <= S_MUL4; 	END IF;
				WHEN S_MUL4		=> IF(TIMER = x"08") THEN NEXT_STATE <= S_TRANS1; 	END IF;
				WHEN S_TRANS1	=> IF(TIMER = x"09") THEN NEXT_STATE <= S_MUL11; 	END IF;
				WHEN S_MUL11	=> IF(TIMER = x"08") THEN NEXT_STATE <= S_SUB3;		END IF;
				WHEN S_SUB3		=> IF(TIMER = x"09") THEN NEXT_STATE <= S_MUL5; 	END IF;
				WHEN S_MUL5		=> IF(TIMER = x"08") THEN NEXT_STATE <= S_SUB4; 	END IF;
				WHEN S_SUB4		=> IF(TIMER = x"09") THEN NEXT_STATE <= S_MUL6; 	END IF;
				WHEN S_MUL6		=> IF(TIMER = x"08") THEN NEXT_STATE <= S_ADD3; 	END IF;
				WHEN S_ADD3		=> IF(TIMER = x"09") THEN NEXT_STATE <= S_MUL8; 	END IF;
				WHEN S_MUL8		=> IF(TIMER = x"08") THEN NEXT_STATE <= S_ADD4; 	END IF;
				WHEN S_ADD4		=> IF(TIMER = x"09") THEN NEXT_STATE <= S_MUL9; 	END IF;
				WHEN S_MUL9		=> IF(TIMER = x"08") THEN NEXT_STATE <= S_TRANS2; 	END IF;
				WHEN S_TRANS2	=> IF(TIMER = x"09") THEN NEXT_STATE <= S_MUL7; 	END IF;
				WHEN S_MUL7		=> IF(TIMER = x"08") THEN NEXT_STATE <= S_WAIT1; 	END IF;
				WHEN S_WAIT1	=> IF(TIMER = x"09") THEN NEXT_STATE <= S_MUL10; 	END IF;
				WHEN S_MUL10	=> IF(TIMER = x"08") THEN NEXT_STATE <= S_STORE1;	END IF;	
				WHEN S_STORE1	=> IF(TIMER = x"08") THEN NEXT_STATE <= S_WAIT2; 	END IF;
				WHEN S_WAIT2	=> IF(TIMER = x"09") THEN NEXT_STATE <= S_STORE2; 	END IF;
				WHEN S_STORE2	=> IF(TIMER = x"08") THEN NEXT_STATE <= S_WAIT3; 	END IF;
				WHEN S_WAIT3	=> IF(TIMER = x"09") THEN NEXT_STATE <= S_STORE3; 	END IF;
				WHEN S_STORE3	=> IF(TIMER = x"08") THEN NEXT_STATE <= S_DONE; 	END IF;
				WHEN S_MUL		=> IF(TIMER = x"37") THEN NEXT_STATE <= S_DONE; 	END IF;
				WHEN S_DONE		=> NEXT_STATE <= S_IDLE;
			END CASE;			
		END PROCESS;
		
		-- 3) OUTPUT PROCESS -------------------------------------------------------
		OUTPUT : PROCESS(STATE, A_FLAG, FLAGS, DAA_BIT, ADDR_M1, ADDR_M2, ADDR_RES, TIMER)
		BEGIN
			-- DEFAULT ASSIGNMENTS --------------------------------------------------
			IDLE				<= '0';
			DONE				<= '0';
			ERROR				<= '0';
			
			A_RST				<= '0';
			M_RST				<= '0';
			T_RST				<= '0';
			
			A_EN				<= '0';
			M_EN				<= '0';
			T_EN				<= '0';
			
			A_SUB				<= '0';
			M_SAVE			<= '0';
			
			F_SET				<= (OTHERS => '0');
			F_RST				<= '0';
			
			RAM1_READ		<= '0';
			RAM1_WE1			<= '0';
			RAM1_WE2			<= '0';
			RAM1_ADDR1		<= NO_ADDR;
			RAM1_ADDR2		<= NO_ADDR;
			
			RAM2_READ		<= '0';
			RAM2_WE1			<= '0';
			RAM2_WE2			<= '0';			
			RAM2_ADDR1		<= NO_ADDR;
			RAM2_ADDR2		<= NO_ADDR;
			
			TRANSFER			<= '0';
			
			ENABLE_INPUT	<= '0';
			ENABLE_OUTPUT	<= '0';			
			-------------------------------------------------------------------------	
			
			CASE STATE IS
				----------------------------------------------------------------------	
				WHEN S_RESET	=>	A_RST					<= '1';
										M_RST					<= '1';
										T_RST					<= '1';
										F_RST					<= '1';
				----------------------------------------------------------------------
				WHEN S_IDLE		=> IDLE					<= '1';
				----------------------------------------------------------------------
				WHEN S_GET		=> ENABLE_OUTPUT		<= '1';
										RAM2_ADDR1			<= "0000";
										RAM2_READ			<= '1';
										T_EN					<= '1';
				----------------------------------------------------------------------
				WHEN S_SET		=> IF(TIMER < x"08") THEN
											ENABLE_INPUT	<= '1';
											RAM2_ADDR1		<= ADDR_RES;
											RAM2_WE1			<= '1';
										END IF;
										
										IF(TIMER > x"00" AND ADDR_RES = "0000") THEN
											RAM1_ADDR1		<= "0001";
											RAM1_WE1			<= '1';
											TRANSFER 		<= '1';
										END IF;

										T_EN					<= '1';
				----------------------------------------------------------------------	
				WHEN S_ADD1		=> IF(TIMER = x"09") THEN 
											T_EN <= '0'; A_EN <= '0'; A_RST <= '1';
											IF(A_FLAG = '1') THEN F_SET <= x"80"; END IF;
										ELSE
											T_EN <= '1'; A_EN <= '1';										
										END IF;				
										RAM1_ADDR1 <= "0010";
										RAM1_ADDR2 <= "0011";				
										RAM2_ADDR1 <= "00"&NOT(DAA_BIT)&"0";
										RAM2_ADDR2 <= "00"&NOT(DAA_BIT)&"1";				
										IF(TIMER < x"08") THEN RAM2_READ <= '1'; END IF;
										IF(TIMER > x"01") THEN RAM1_WE1 <= '1'; RAM1_WE2 <= '1'; END IF;
				----------------------------------------------------------------------
				WHEN S_ADD2		=> M_EN <= '1';
										IF(TIMER = x"09") THEN 
											T_EN <= '0'; A_EN <= '0'; A_RST <= '1';
											IF(A_FLAG = '1') THEN F_SET <= x"40"; END IF;
										ELSE
											T_EN <= '1'; A_EN <= '1';										
										END IF;				
										RAM1_ADDR1 <= "0110";
										RAM1_ADDR2 <= "0111";				
										RAM2_ADDR1 <= "00"&DAA_BIT&"0";
										RAM2_ADDR2 <= "00"&DAA_BIT&"1";				
										IF(TIMER < x"08") THEN RAM2_READ <= '1'; END IF;
										IF(TIMER > x"01") THEN RAM1_WE1 <= '1'; RAM1_WE2 <= '1'; END IF;
				----------------------------------------------------------------------
				WHEN S_ADD3		=> M_EN <= '1';
										IF(TIMER = x"09") THEN 
											T_EN <= '0'; A_EN <= '0'; A_RST <= '1';
											IF(A_FLAG = '1') THEN F_SET <= x"20"; END IF;
										ELSE
											T_EN <= '1'; A_EN <= '1';										
										END IF;		
										RAM1_ADDR1 <= "0100";
										RAM1_ADDR2 <= "0101";				
										RAM2_ADDR1 <= "1000";
										RAM2_ADDR2 <= "1010";				
										IF(TIMER < x"08") THEN RAM2_READ <= '1'; M_SAVE <= '1'; END IF;
										IF(TIMER > x"01") THEN RAM1_WE1 <= '1'; RAM1_WE2 <= '1'; END IF;
				----------------------------------------------------------------------										
				WHEN S_ADD4		=> M_EN <= '1';
										IF(TIMER = x"09") THEN 
											T_EN <= '0'; A_EN <= '0'; A_RST <= '1';
											IF(A_FLAG = '1') THEN F_SET <= x"10"; END IF;
										ELSE
											T_EN <= '1'; A_EN <= '1';										
										END IF;		
										RAM1_ADDR1 <= "0100";
										RAM1_ADDR2 <= "0101";				
										RAM2_ADDR1 <= "0100";
										RAM2_ADDR2 <= "1100";											
										IF(TIMER < x"08") THEN RAM2_READ <= '1'; RAM2_WE2 <= '1'; M_SAVE <= '1'; END IF;
										IF(TIMER > x"01") THEN RAM1_WE1 <= '1'; RAM1_WE2 <= '1'; END IF;		
				----------------------------------------------------------------------
				WHEN S_SUB1		=> M_EN <= '1';
										IF(TIMER = x"09") THEN 
											T_EN <= '0'; A_EN <= '0'; A_SUB <= '0'; A_RST <= '1';
											IF(A_FLAG = '1') THEN F_SET <= x"08"; END IF;
										ELSE
											T_EN <= '1'; A_EN <= '1'; A_SUB <= '1';										
										END IF;		
										RAM1_ADDR1 <= "0100";
										RAM1_ADDR2 <= "0101";		
										RAM2_ADDR1 <= "00"&NOT(DAA_BIT)&"0";
										RAM2_ADDR2 <= "00"&NOT(DAA_BIT)&"1";	
										IF(TIMER < x"08") THEN RAM2_READ <= '1'; END IF;
										IF(TIMER > x"01") THEN RAM1_WE1 <= '1'; RAM1_WE2 <= '1'; END IF;		
				----------------------------------------------------------------------										
				WHEN S_SUB2		=> M_EN <= '1';
										IF(TIMER = x"09") THEN 
											T_EN <= '0'; A_EN <= '0'; A_SUB <= '0'; A_RST <= '1';
											IF(A_FLAG = '1') THEN F_SET <= x"04"; END IF;
										ELSE
											T_EN <= '1'; A_EN <= '1'; A_SUB <= '1';										
										END IF;		
										RAM1_ADDR1 <= "0110";
										RAM1_ADDR2 <= "0111";	
										RAM2_ADDR1 <= "00"&DAA_BIT&"0";
										RAM2_ADDR2 <= "00"&DAA_BIT&"1";		
										IF(TIMER < x"08") THEN RAM2_READ <= '1'; END IF;
										IF(TIMER > x"01") THEN RAM1_WE1 <= '1'; RAM1_WE2 <= '1'; END IF;	
				----------------------------------------------------------------------										
				WHEN S_SUB3		=> M_EN <= '1';
										IF(TIMER = x"09") THEN 
											T_EN <= '0'; A_EN <= '0'; A_SUB <= '0'; A_RST <= '1';
											IF(A_FLAG = '1') THEN F_SET <= x"02"; END IF;
										ELSE
											T_EN <= '1'; A_EN <= '1'; A_SUB <= '1';										
										END IF;			
										RAM1_ADDR1 <= "0010";
										RAM1_ADDR2 <= "0011";
										RAM2_ADDR1 <= "0100";
										RAM2_ADDR2 <= "0110";		
										IF(TIMER < x"08") THEN RAM2_READ <= '1'; END IF;
										IF(TIMER > x"01") THEN RAM1_WE1 <= '1'; RAM1_WE2 <= '1'; END IF;	
				----------------------------------------------------------------------										
				WHEN S_SUB4		=> M_EN <= '1';
										IF(TIMER = x"09") THEN 
											T_EN <= '0'; A_EN <= '0'; A_SUB <= '0'; A_RST <= '1';
											IF(A_FLAG = '1') THEN F_SET <= x"01"; END IF;
										ELSE
											T_EN <= '1'; A_EN <= '1'; A_SUB <= '1';										
										END IF;		
										RAM1_ADDR1 <= "0100";
										RAM1_ADDR2 <= "0101";		
										RAM2_ADDR1 <= "1000";
										RAM2_ADDR2 <= "1010";										
										IF(TIMER < x"08") THEN RAM2_READ <= '1'; RAM2_WE2   <= '1'; M_SAVE 	  <= '1'; END IF;
										IF(TIMER > x"01") THEN RAM1_WE1 <= '1'; RAM1_WE2 <= '1'; END IF;			
				----------------------------------------------------------------------
				WHEN S_MUL1		=>	M_EN <= '1';

										RAM1_ADDR1 <= "001"&FLAGS(7); 
										RAM1_ADDR2 <= "001"&FLAGS(7);				
				
										IF(TIMER = x"08") THEN T_EN <= '0'; RAM1_READ <= '0'; ELSE T_EN <= '1'; RAM1_READ <= '1'; END IF;
				----------------------------------------------------------------------										
				WHEN S_MUL2		=>	M_EN <= '1';

										RAM1_ADDR1 <= "010"&FLAGS(3);
										RAM1_ADDR2 <= "010"&FLAGS(3);					
				
										IF(TIMER = x"08") THEN T_EN <= '0'; RAM1_READ <= '0'; ELSE T_EN <= '1'; RAM1_READ <= '1'; END IF;
				----------------------------------------------------------------------										
				WHEN S_MUL3		=>	M_EN <= '1';
				
										RAM1_ADDR1 <= "011"&FLAGS(6);
										RAM1_ADDR2 <= "010"&FLAGS(3);	
										
										IF(TIMER = x"08") THEN T_EN <= '0'; RAM1_READ <= '0'; ELSE T_EN <= '1'; RAM1_READ <= '1'; END IF;
				----------------------------------------------------------------------										
				WHEN S_MUL4		=>	M_EN <= '1';
				
										RAM1_ADDR1 <= "011"&FLAGS(2);
										RAM1_ADDR2 <= "001"&FLAGS(7);												
										RAM2_ADDR2 <= "0100";				
				
										IF(TIMER < x"08") THEN 
											T_EN 		 <= '1';
											RAM1_READ <= '1';	
											RAM2_WE2   <= '1';
											M_SAVE 	  <= '1';	
										END IF;
				----------------------------------------------------------------------										
				WHEN S_MUL5		=>	M_EN <= '1';
				
										RAM1_ADDR1 <= "001"&FLAGS(1);
										RAM1_ADDR2 <= "0000";
										RAM2_ADDR2 <= "1000";
										
										IF(TIMER < x"08") THEN 
											T_EN 		 <= '1';
											RAM1_READ <= '1';	

											RAM2_WE2   <= '1';
											M_SAVE 	  <= '1';														
										END IF;
				----------------------------------------------------------------------										
				WHEN S_MUL6		=>	M_EN <= '1';
				
										RAM1_ADDR1 <= "010"&FLAGS(0);
										RAM1_ADDR2 <= "010"&FLAGS(0);	
				
										IF(TIMER = x"08") THEN T_EN <= '0'; RAM1_READ <= '0'; ELSE T_EN <= '1'; RAM1_READ <= '1'; END IF;
				----------------------------------------------------------------------			
				WHEN S_MUL7		=> M_EN <= '1';

										RAM1_ADDR1 <= "1000";
										RAM1_ADDR2 <= "1010";					
				
										IF(TIMER = x"08") THEN T_EN <= '0'; RAM1_READ <= '0'; ELSE T_EN <= '1'; RAM1_READ <= '1'; END IF;
				----------------------------------------------------------------------			
				WHEN S_MUL8		=>	M_EN <= '1';

										RAM1_ADDR1 <= "010"&FLAGS(5);
										RAM1_ADDR2 <= "010"&FLAGS(5);	
				
										IF(TIMER < x"08") THEN 
											T_EN 		 <= '1';
											RAM1_READ <= '1';												
										END IF;
				----------------------------------------------------------------------										
				WHEN S_MUL9		=>	M_EN <= '1';

										RAM1_ADDR1 <= "001"&FLAGS(1);
										RAM1_ADDR2 <= "010"&FLAGS(4);					
				
										IF(TIMER < x"08") THEN 
											T_EN 		 <= '1';
											RAM1_READ <= '1';												
										END IF;
				----------------------------------------------------------------------										
				WHEN S_MUL10	=>	M_EN <= '1';

										RAM1_ADDR1 <= "1100";
										RAM1_ADDR2 <= "0001";
										RAM2_ADDR2 <= "00"&DAA_BIT&"0";				
				
										IF(TIMER < x"08") THEN 
											T_EN 		 <= '1';
											RAM1_READ <= '1';
											RAM2_WE2   <= '1';
											M_SAVE 	  <= '1';												
										END IF;
				----------------------------------------------------------------------										
				WHEN S_MUL11	=>	M_EN <= '1';
										IF(TIMER < x"08") THEN 
											T_EN 		 <= '1';
											RAM1_READ <= '1';												
										END IF;
				----------------------------------------------------------------------										
				WHEN S_TRANS1	=> M_EN <= '1';				
										TRANSFER <= '1';
										
										RAM2_ADDR1 <= "0100";
										RAM2_ADDR2 <= "0110";
										RAM1_ADDR1 <= "1000";
										RAM1_ADDR2 <= "1010";	
										
										IF(TIMER < x"08") THEN
											RAM2_READ  <= '1';
											RAM2_WE2   <= '1';
											M_SAVE 	  <= '1';	
										END IF;
										IF(TIMER > x"00" AND TIMER < x"09") THEN
											RAM1_WE1   <= '1'; RAM1_WE2   <= '1';
										END IF;
										IF(TIMER = x"09") THEN T_EN <= '0'; ELSE T_EN <= '1'; END IF;
				----------------------------------------------------------------------										
				WHEN S_TRANS2	=> M_EN <= '1';
										TRANSFER <= '1';
										
										RAM1_ADDR2 <= "1100";											
										RAM2_ADDR2 <= "1110";
											
										IF(TIMER < x"08") THEN
											RAM2_READ <= '1';
											RAM2_WE2	 <= '1';
											M_SAVE 	 <= '1';
										END IF;
										IF(TIMER > x"00" AND TIMER < x"09") THEN
											RAM1_WE2   <= '1';
										END IF;										
										IF(TIMER = x"09") THEN T_EN <= '0'; ELSE T_EN <= '1'; END IF;
				----------------------------------------------------------------------				
				WHEN S_WAIT1	=> M_EN <= '1';
										IF(TIMER = x"09") THEN T_EN <= '0'; ELSE T_EN <= '1'; END IF;
				----------------------------------------------------------------------										
				WHEN S_WAIT2	=> M_EN <= '1';
										IF(TIMER = x"09") THEN T_EN <= '0'; ELSE T_EN <= '1'; END IF;										
				----------------------------------------------------------------------
				WHEN S_WAIT3	=> M_EN <= '1';
										IF(TIMER = x"09") THEN T_EN <= '0'; ELSE T_EN <= '1'; END IF;
				----------------------------------------------------------------------										
				WHEN S_STORE1	=> M_EN <= '1';
										IF(TIMER < x"08") THEN 
											T_EN <= '1'; 
											M_SAVE <= '1'; 

											RAM2_WE2 <= '1';
											RAM2_ADDR2 <= "00"&NOT(DAA_BIT)&"1";
										END IF;
				----------------------------------------------------------------------										
				WHEN S_STORE2	=> M_EN <= '1';
										IF(TIMER < x"08") THEN 
											T_EN <= '1'; 
											M_SAVE <= '1'; 

											RAM2_WE2 <= '1';
											RAM2_ADDR2 <= "00"&NOT(DAA_BIT)&"0";
										END IF;										
				----------------------------------------------------------------------
				WHEN S_STORE3	=> IF(TIMER < x"08") THEN 
											T_EN <= '1'; 
											M_SAVE <= '1'; 

											RAM2_WE2 <= '1';
											RAM2_ADDR2 <= "00"&DAA_BIT&"1";
										END IF;				
				----------------------------------------------------------------------
				WHEN S_MUL		=>	-- LOAD --------------------------------
										IF(TIMER < x"08") THEN
											RAM2_ADDR1		<= ADDR_M1;
											RAM2_ADDR2		<= ADDR_M2;
											RAM2_READ		<= '1';
										END IF;
										
										-- TRANSFER ----------------------------
										IF(TIMER > x"00" AND TIMER < x"09") THEN 
											TRANSFER <= '1'; 
											RAM1_ADDR1 <= "1110"; 
											RAM1_ADDR2 <= "1111"; 
											RAM1_WE1 <= '1'; 
											RAM1_WE2 <= '1';
										END IF;
										
										-- MULTIPLY ----------------------------
										IF(TIMER > x"00") THEN
											M_EN <= '1';
										END IF;
										
										-- SAVE --------------------------------
										IF(TIMER > x"2F") THEN
											M_SAVE <= '1';
											RAM2_ADDR2 <= ADDR_RES;
											RAM2_WE2	  <= '1';
										END IF;
										
										-- RESET -------------------------------
										IF(TIMER = x"37") THEN 
											M_RST <= '1'; 
										END IF;
										
										T_EN		<= '1';
				----------------------------------------------------------------------
				WHEN S_DONE		=> DONE		<= '1';
										A_RST				<= '1';
										M_RST				<= '1';
										T_RST				<= '1';
										F_RST				<= '1';
				----------------------------------------------------------------------
				WHEN OTHERS 	=> ERROR		<= '1';
				----------------------------------------------------------------------
			END CASE;
		END PROCESS;

		-- 4) TIMER PROCESS
		-------------------------------------------------------------------------------
		TIMER_PROC : PROCESS (CLK, T_EN, T_RST)
		BEGIN
			IF RISING_EDGE(CLK) THEN
				IF (T_RST = '1') THEN
					TIMER <= x"00";
				ELSIF (T_EN = '1') THEN
					TIMER <= TIMER + 1;
				ELSE
					TIMER <= x"00";
				END IF;
			END IF;
		END PROCESS TIMER_PROC;			
		
END Structural;