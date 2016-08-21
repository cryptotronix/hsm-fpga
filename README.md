# hsm-fpga
Port of cryptech.is FPGA to the Digilent ZYBO

-These IPs was created in Vivado 16.2
-Vivado is a design environment for FPGA products from Xilinx, and is tightly-coupled to the architecture of such chips, 
 and cannot be used with FPGA products from other vendors.
 
 
Instructions to use the IP:
 
-In order to use the IPs, download the folder of the IP you would like to use in your project.
-Open the Vivado project in which you want to add the ip. 
-Open or create block design and click "IP Settings" from the buttons on the left margin of the "block design" pane.
-In the "Project Settings" dialog box which opens, select "Ip" and click "Repository Manager" Tab.
-CLick on the '+' symbol and select the folder of IP which was downloaded. CLick OK.
-Now, go to the block design and you can add the IP to the design, just like adding any other IP.


Instructions to modify the IP:

-In order to edit or modify the IP, find the file with extension ".xpr" within the folder.
-The IP opens as a project file.
-Do the changes required to the source files and re-package it with a different version number.


Note:
-Test code and documentation of individual IPs can be found as ".docx" files along with this README file

