# hsm-fpga
Port of cryptech.is FPGA to the Digilent ZYBO

-These IPs was created in Vivado 16.2
-Vivado is a design environment for FPGA products from Xilinx, and is tightly-coupled to the architecture of such chips, 
 and cannot be used with FPGA products from other vendors.
 
 
Instructions to use the IP:
 
-In order to use the IPs, download or clone the folder of the IP you would like to use in your project.
-Open the Vivado project in which you want to add the ip. 
-Open or create block design and click "IP Settings" from the buttons on the left margin of the "block design" pane.
-In the "Project Settings" dialog box which opens, select "Ip" and click "Repository Manager" Tab.
-CLick on the '+' symbol and select the folder of IP which was downloaded. CLick OK.
-Now, go to the block design and you can add the IP to the design, just like adding any other IP.


Instructions to modify the IP:

-In order to edit or modify an IP, download or clone the folder of the IP which you want to modify.
-Inside the main folder of the IP, there will be folder with part of the name as "project".
 For example, "sha256_1.0" will have a folder named "sha256_v1_0_project". 
-Open that folder and find the file with extension ".xpr" within the folder. Open it.
-The IP opens as a project file.
-Do the changes required to the source files and re-package it with a different version number.


Note:
-Test code and documentation of individual IPs can be found as ".docx" files along with this README file
-Digilent Zybo board was used for testing

Useful Links:

Getting started with Vivado
http://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_1/ug937-vivado-design-suite-simulation-tutorial.pdf

Creating and Packaging IP
http://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_1/ug1119-vivado-creating-packaging-ip-tutorial.pdf

Vivado Board files installation
https://reference.digilentinc.com/reference/software/vivado/board-files?redirect=1id=vivado:boardfiles

Getting Started with Digilent Zybo board
https://reference.digilentinc.com/learn/programmable-logic/tutorials/zybo-getting-started-with-zynq/start

