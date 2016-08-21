
`timescale 1 ns / 1 ps

	module chacha_customip_trial_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 10
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,
		input wire chacha_clk
	);
// Instantiation of Axi Bus Interface S00_AXI
	chacha_customip_trial_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) chacha_customip_trial_v1_0_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(32'h00000000),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		.read_addr_out(read_addr_out_w),
        .write_addr_out(write_addr_out_w),
        .data_in(chacha_data_out_w)
	);

	// Add user logic here
	wire [7:0]read_addr_out_w;
	wire [7:0]write_addr_out_w;
	wire error_w;
	wire [31:0] chacha_data_in_w;
	wire [31:0] chacha_data_out_w;
	wire chacha_cs_w;
	wire chacha_we_w;
	wire [7:0] chacha_address_w;
 chacha inst0(
                // Clock and reset.
                .core_clk(chacha_clk),
                .clk(s00_axi_aclk),
                .reset_n(s00_axi_aresetn),
   
                // Control.
                .cs(chacha_cs_w),
                .we(chacha_we_w),
   
                // Data ports.
                .address(chacha_address_w),
                .write_data(chacha_data_in_w),
                .read_data(chacha_data_out_w),
                .error(error_w)
               );
	// User logic ends
    assign chacha_we_w = s00_axi_wvalid & s00_axi_awvalid;
    assign chacha_cs_w = (s00_axi_wvalid & s00_axi_awvalid)||s00_axi_arvalid;
    assign chacha_address_w = (chacha_we_w)?write_addr_out_w:read_addr_out_w;
    assign chacha_data_in_w = s00_axi_wdata;
	endmodule
