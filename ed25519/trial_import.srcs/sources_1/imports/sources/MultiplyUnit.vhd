----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			9/7/2014
-- MODULE NAME:			MultiplyUnit
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
ENTITY MultiplyUnit IS
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
END MultiplyUnit;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF MultiplyUnit IS




-- STATES
----------------------------------------------------------------------------------
TYPE STATES IS (S_RESET, S_IDLE, S_MUL1, S_MUL2, S_MUL3, S_MUL4, S_MUL5, S_MUL6, S_MUL7, S_MUL8,
					 S_MUL9, S_MUL10, S_MUL11, S_MUL12, S_MUL13, S_MUL14, S_MUL15, S_MUL16, S_DONE);
SIGNAL STATE, NEXT_STATE : STATES;



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL MACC_DSP_IN					: STD_LOGIC_VECTOR (329 DOWNTO 0);
SIGNAL PREREDUCED_B					: STD_LOGIC_VECTOR ( 21 DOWNTO 0);
SIGNAL MUX_SELECT						: STD_LOGIC_VECTOR ( 13 DOWNTO 0);
SIGNAL RESET_DSP, ENABLE_DSP		: STD_LOGIC;



-- COMPONENT
----------------------------------------------------------------------------------
COMPONENT DSP_Multiply_Prereduction IS
	PORT ( CLK : IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST : IN  STD_LOGIC;
          CE  : IN  STD_LOGIC;
			 -- DATA IN PORT ---------------------------------
			 B   : IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
			 -- DATA OUT PORT --------------------------------
          R   : OUT STD_LOGIC_VECTOR (21 DOWNTO 0));
END COMPONENT;

COMPONENT DSP_Multiply_Operation IS
	PORT ( CLK : IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RST : IN  STD_LOGIC;
          CE  : IN  STD_LOGIC;
			 -- DATA IN PORTS --------------------------------
			 A   : IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
          B   : IN  STD_LOGIC_VECTOR (21 DOWNTO 0);
			 -- DATA OUT PORT --------------------------------
          P   : OUT STD_LOGIC_VECTOR (42 DOWNTO 0));
END COMPONENT;



-- STRUCTURAL
----------------------------------------------------------------------------------
BEGIN
	
	-- INSTANCES ------------------------------------------------------------------	
	Prereduction : DSP_Multiply_Prereduction
	PORT MAP (
		CLK => CLK,
		RST => RESET_DSP,
		CE	 => ENABLE_DSP,
		B	 => B(33 DOWNTO 17),
		R	 => PREREDUCED_B
	);
	
	MACC_DSP : FOR I IN 0 TO 14 GENERATE
		Operation : DSP_Multiply_Operation
		PORT MAP (
			CLK => CLK,
			RST => RESET_DSP,
			CE  => ENABLE_DSP,
			A 	 => A(I*17+16 DOWNTO I*17),
			B 	 => MACC_DSP_IN(I*22+21 DOWNTO I*22),
			P 	 => P(I*43+42 DOWNTO I*43)
		);
	END GENERATE;

	-- DSP INPUT MULTIPLEXER (OPERAND B) ------------------------------------------	
	MACC_DSP_IN( 21 DOWNTO   0)	<= PREREDUCED_B WHEN (MUX_SELECT(0)  = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN( 43 DOWNTO  22)	<= PREREDUCED_B WHEN (MUX_SELECT(1)  = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN( 65 DOWNTO  44)	<= PREREDUCED_B WHEN (MUX_SELECT(2)  = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN( 87 DOWNTO  66)	<= PREREDUCED_B WHEN (MUX_SELECT(3)  = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN(109 DOWNTO  88)	<= PREREDUCED_B WHEN (MUX_SELECT(4)  = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN(131 DOWNTO 110)	<= PREREDUCED_B WHEN (MUX_SELECT(5)  = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN(153 DOWNTO 132)	<= PREREDUCED_B WHEN (MUX_SELECT(6)  = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN(175 DOWNTO 154)	<= PREREDUCED_B WHEN (MUX_SELECT(7)  = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN(197 DOWNTO 176)	<= PREREDUCED_B WHEN (MUX_SELECT(8)  = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN(219 DOWNTO 198)	<= PREREDUCED_B WHEN (MUX_SELECT(9)  = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN(241 DOWNTO 220)	<= PREREDUCED_B WHEN (MUX_SELECT(10) = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN(263 DOWNTO 242)	<= PREREDUCED_B WHEN (MUX_SELECT(11) = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN(285 DOWNTO 264)	<= PREREDUCED_B WHEN (MUX_SELECT(12) = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN(307 DOWNTO 286)	<= PREREDUCED_B WHEN (MUX_SELECT(13) = '1') ELSE "00000" & B(16 DOWNTO 0);
	MACC_DSP_IN(329 DOWNTO 308)	<= "00000" & B(16 DOWNTO 0);
	
	

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
				WHEN S_IDLE		=> IF(CE = '1') THEN NEXT_STATE <= S_MUL1; END IF;
				WHEN S_MUL1		=> NEXT_STATE <= S_MUL2;
				WHEN S_MUL2		=> NEXT_STATE <= S_MUL3;
				WHEN S_MUL3		=> NEXT_STATE <= S_MUL4;
				WHEN S_MUL4		=> NEXT_STATE <= S_MUL5;
				WHEN S_MUL5		=> NEXT_STATE <= S_MUL6;
				WHEN S_MUL6		=> NEXT_STATE <= S_MUL7;
				WHEN S_MUL7		=> NEXT_STATE <= S_MUL8;
				WHEN S_MUL8		=> NEXT_STATE <= S_MUL9;
				WHEN S_MUL9		=> NEXT_STATE <= S_MUL10;
				WHEN S_MUL10	=> NEXT_STATE <= S_MUL11;
				WHEN S_MUL11	=> NEXT_STATE <= S_MUL12;
				WHEN S_MUL12	=> NEXT_STATE <= S_MUL13;
				WHEN S_MUL13	=> NEXT_STATE <= S_MUL14;
				WHEN S_MUL14	=> NEXT_STATE <= S_MUL15;
				WHEN S_MUL15	=> NEXT_STATE <= S_MUL16;
				WHEN S_MUL16	=> NEXT_STATE <= S_DONE;
				WHEN S_DONE		=> NEXT_STATE <= S_IDLE;
			END CASE;			
		END PROCESS;

		-- 3) OUTPUT PROCESS -------------------------------------------------------
		OUTPUT : PROCESS(STATE)
		BEGIN
			-- DEFAULT ASSIGNMENTS --------------------------------------------------
			RESET_DSP									<= '0';
			ENABLE_DSP									<= '0';
			
			DONE											<= '0';
			
			MUX_SELECT									<= (OTHERS => '0');
			-------------------------------------------------------------------------	
			
			CASE STATE IS
				----------------------------------------------------------------------	
				WHEN S_RESET	=> RESET_DSP		<= '1';
				----------------------------------------------------------------------	
				WHEN S_IDLE		=> NULL;
				----------------------------------------------------------------------	
				WHEN S_MUL1		=> ENABLE_DSP		<= '1';
				----------------------------------------------------------------------	
				WHEN S_MUL2		=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "00000000000001";
				----------------------------------------------------------------------	
				WHEN S_MUL3		=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "00000000000011";
				----------------------------------------------------------------------	
				WHEN S_MUL4		=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "00000000000111";
				----------------------------------------------------------------------	
				WHEN S_MUL5		=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "00000000001111";
				----------------------------------------------------------------------	
				WHEN S_MUL6		=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "00000000011111";
				----------------------------------------------------------------------	
				WHEN S_MUL7		=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "00000000111111";
				----------------------------------------------------------------------	
				WHEN S_MUL8		=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "00000001111111";
				----------------------------------------------------------------------	
				WHEN S_MUL9		=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "00000011111111";
				----------------------------------------------------------------------	
				WHEN S_MUL10		=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "00000111111111";
				----------------------------------------------------------------------	
				WHEN S_MUL11	=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "00001111111111";
				----------------------------------------------------------------------	
				WHEN S_MUL12	=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "00011111111111";
				----------------------------------------------------------------------	
				WHEN S_MUL13	=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "00111111111111";
				----------------------------------------------------------------------	
				WHEN S_MUL14	=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "01111111111111";
				----------------------------------------------------------------------	
				WHEN S_MUL15	=> ENABLE_DSP		<= '1';
										MUX_SELECT		<= "11111111111111";										
				----------------------------------------------------------------------	
				WHEN S_MUL16	=> ENABLE_DSP		<= '1';
				----------------------------------------------------------------------	
				WHEN S_DONE		=> DONE 		<= '1';
			END CASE;
		END PROCESS;
		
END Structural;

