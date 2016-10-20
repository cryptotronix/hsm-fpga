--------------------------------------------------------------------------------
--    This file is owned and controlled by Xilinx and must be used solely     --
--    for design, simulation, implementation and creation of design files     --
--    limited to Xilinx devices or technologies. Use with non-Xilinx          --
--    devices or technologies is expressly prohibited and immediately         --
--    terminates your license.                                                --
--                                                                            --
--    XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" SOLELY    --
--    FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY    --
--    PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE             --
--    IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS      --
--    MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY      --
--    CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY       --
--    RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY       --
--    DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE   --
--    IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR          --
--    REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF         --
--    INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A   --
--    PARTICULAR PURPOSE.                                                     --
--                                                                            --
--    Xilinx products are not intended for use in life support appliances,    --
--    devices, or systems.  Use in such applications are expressly            --
--    prohibited.                                                             --
--                                                                            --
--    (c) Copyright 1995-2013 Xilinx, Inc.                                    --
--    All rights reserved.                                                    --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- You must compile the wrapper file Pre.vhd when simulating
-- the core, Pre. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synthesis directives "translate_off/translate_on" specified
-- below are supported by Xilinx, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synthesis translate_off
LIBRARY XilinxCoreLib;
-- synthesis translate_on
ENTITY Pre IS
  PORT (
    clk : IN STD_LOGIC;
    ce : IN STD_LOGIC;
    sclr : IN STD_LOGIC;
    a : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    p : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
  );
END Pre;

ARCHITECTURE Pre_a OF Pre IS
-- synthesis translate_off
COMPONENT wrapped_Pre
  PORT (
    clk : IN STD_LOGIC;
    ce : IN STD_LOGIC;
    sclr : IN STD_LOGIC;
    a : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    p : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
  );
END COMPONENT;

-- Configuration specification
  FOR ALL : wrapped_Pre USE ENTITY XilinxCoreLib.xbip_dsp48_macro_v2_1(behavioral)
    GENERIC MAP (
      c_a_width => 18,
      c_b_width => 6,
      c_c_width => 48,
      c_concat_width => 48,
      c_constant_1 => 1,
      c_d_width => 18,
      c_has_a => 1,
      c_has_acin => 0,
      c_has_acout => 0,
      c_has_b => 1,
      c_has_bcin => 0,
      c_has_bcout => 0,
      c_has_c => 0,
      c_has_carrycascin => 0,
      c_has_carrycascout => 0,
      c_has_carryin => 0,
      c_has_carryout => 0,
      c_has_ce => 1,
      c_has_cea => 0,
      c_has_ceb => 0,
      c_has_cec => 0,
      c_has_ceconcat => 0,
      c_has_ced => 0,
      c_has_cem => 0,
      c_has_cep => 0,
      c_has_cesel => 0,
      c_has_concat => 0,
      c_has_d => 0,
      c_has_indep_ce => 0,
      c_has_indep_sclr => 0,
      c_has_pcin => 0,
      c_has_pcout => 0,
      c_has_sclr => 1,
      c_has_sclra => 0,
      c_has_sclrb => 0,
      c_has_sclrc => 0,
      c_has_sclrconcat => 0,
      c_has_sclrd => 0,
      c_has_sclrm => 0,
      c_has_sclrp => 0,
      c_has_sclrsel => 0,
      c_latency => 128,
      c_model_type => 0,
      c_opmodes => "0000000001010000000",
      c_p_lsb => 0,
      c_p_msb => 23,
      c_reg_config => "00000000000000000000000001000000",
      c_sel_width => 0,
      c_test_core => 0,
      c_verbosity => 0,
      c_xdevicefamily => "zynq"
    );
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_Pre
  PORT MAP (
    clk => clk,
    ce => ce,
    sclr => sclr,
    a => a,
    b => b,
    p => p
  );
-- synthesis translate_on

END Pre_a;
