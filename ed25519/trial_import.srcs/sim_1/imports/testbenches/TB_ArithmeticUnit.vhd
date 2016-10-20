--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:19:39 10/15/2013
-- Design Name:   
-- Module Name:   C:/Users/Pascal/Subversions/Sasdrich/MultiplicationUnit/TB_ArithmeticUnit.vhd
-- Project Name:  MultiplicationUnit
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ArithmeticUnit
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_ArithmeticUnit IS
END TB_ArithmeticUnit;
 
ARCHITECTURE behavior OF TB_ArithmeticUnit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ArithmeticUnit
    PORT(
         CLK : IN  std_logic;
         CE : IN  std_logic;
         RST : IN  std_logic;
         SET_POINT : IN  std_logic;
         GET_POINT : IN  std_logic;
         DOUBLE_AND_ADD : IN  std_logic;
         MULTIPLY : IN  std_logic;
         DAA_BIT : IN  std_logic;
         POINT : IN  std_logic_vector(33 downto 0);
         RESULT : OUT  std_logic_vector(33 downto 0);
			ADDR_M1 : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			ADDR_M2 : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			ADDR_RES : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);			
         IDLE : OUT  std_logic;
         DONE : OUT  std_logic;
         ERROR : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal CE : std_logic := '0';
   signal RST : std_logic := '0';
   signal SET_POINT : std_logic := '0';
   signal GET_POINT : std_logic := '0';
   signal DOUBLE_AND_ADD : std_logic := '0';
   signal MULTIPLY : std_logic := '0';
   signal DAA_BIT : std_logic := '0';
   signal POINT : std_logic_vector(33 downto 0) := (others => '0');
	signal ADDR_M1 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
	signal ADDR_M2 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
	signal ADDR_RES : STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');		
 	--Outputs
   signal RESULT : std_logic_vector(33 downto 0);
   signal IDLE : std_logic;
   signal DONE : std_logic;
   signal ERROR : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ArithmeticUnit PORT MAP (
          CLK => CLK,
          CE => CE,
          RST => RST,
          SET_POINT => SET_POINT,
          GET_POINT => GET_POINT,
          DOUBLE_AND_ADD => DOUBLE_AND_ADD,
          MULTIPLY => MULTIPLY,
          DAA_BIT => DAA_BIT,
          POINT => POINT,
          RESULT => RESULT,
			 ADDR_M1 => ADDR_M1,
			 ADDR_M2 => ADDR_M2,
			 ADDR_RES => ADDR_RES,
          IDLE => IDLE,
          DONE => DONE,
          ERROR => ERROR
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '1';
		wait for CLK_period/2;
		CLK <= '0';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   STIM_PROC : PROCESS
   BEGIN	
      -- hold reset state for 100 ns.
      RST <= '1';
		WAIT FOR 100 NS;
		RST <= '0';

      WAIT FOR CLK_period*10;

      -- insert stimulus here 
		CE <= '1';
		
			-- SET POINT ---------------------------------------------------------
			SET_POINT <= '1'; WAIT FOR CLK_PERIOD;
				POINT <= "0000000000000000000000000000001001"; WAIT FOR CLK_PERIOD;
				POINT <= "0000000000000000000000000000000000"; WAIT FOR CLK_PERIOD;
				POINT <= "0000000000000000000000000000000000"; WAIT FOR CLK_PERIOD;
				POINT <= "0000000000000000000000000000000000"; WAIT FOR CLK_PERIOD;
				POINT <= "0000000000000000000000000000000000"; WAIT FOR CLK_PERIOD;
				POINT <= "0000000000000000000000000000000000"; WAIT FOR CLK_PERIOD;
				POINT <= "0000000000000000000000000000000000"; WAIT FOR CLK_PERIOD;
				POINT <= "0000000000000000000000000000000000"; WAIT FOR CLK_PERIOD;
				WAIT UNTIL DONE = '1';
			SET_POINT <= '0'; WAIT FOR CLK_PERIOD;
			----------------------------------------------------------------------

			-- GET POINT ---------------------------------------------------------
			GET_POINT <= '1'; WAIT FOR CLK_PERIOD;
				WAIT FOR CLK_PERIOD*9;
			GET_POINT <= '0'; WAIT FOR CLK_PERIOD;
			----------------------------------------------------------------------		

			-- DOUBLE AND ADD ----------------------------------------------------
			DOUBLE_AND_ADD <= '1'; WAIT FOR CLK_PERIOD;
				DAA_BIT <= '0';
				WAIT UNTIL DONE = '1';
			DOUBLE_AND_ADD <= '0'; WAIT FOR CLK_PERIOD;
			----------------------------------------------------------------------

			-- MULTIPLY ----------------------------------------------------------
--			MULTIPLY <= '1'; WAIT FOR CLK_PERIOD;
--				ADDR_M1  <= "00000";
--				ADDR_M2  <= "00000";
--				ADDR_RES <= "00001";
--				WAIT UNTIL DONE = '1';
--			MULTIPLY <= '0'; WAIT FOR CLK_PERIOD;
			----------------------------------------------------------------------

      WAIT;
	END PROCESS;

END;
