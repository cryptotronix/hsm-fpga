IP is incomplete. Still under development.

This IP is an ed25519 elliptical encryption IP. The IP core is written in VHDL. 
The top module is written in Verilog. The VHDL core was taken from an open source. 
The VHDL core was actually created in the Xilinx ISE. But for creating IP, we have to use Vivado Design suite. 
Hence the Xilinx ISE project is ported into Vivado project.
*******************************************************************************
Problems in creating the IP
In the VHDL core, Dual port Block RAM IP and DSP accumulator block are used. 
But when ported to Vivado Design , these IPs were not supported in Vivado. 
As a result, there are issues with completing this IP. 
