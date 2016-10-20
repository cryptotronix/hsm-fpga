----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2014 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Secure Hardware Group
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			28/7/2014
-- MODULE NAME:			CarryEstimator
--
--	REVISION:				1.00 - File created
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
ENTITY CarryEstimator IS
    PORT ( A : IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
           B : IN  STD_LOGIC_VECTOR (16 DOWNTO 0);
           C : IN  STD_LOGIC_VECTOR ( 8 DOWNTO 0);
           F : OUT STD_LOGIC);
END CarryEstimator;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF CarryEstimator IS



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL SUM : UNSIGNED(18 DOWNTO 0);


-- BEHAVIORAL
----------------------------------------------------------------------------------
BEGIN

	SUM <= UNSIGNED("00" & A) + UNSIGNED("00" & B) + UNSIGNED("0000000000" & C);
	F	 <= SUM(18);

END Behavioral;

