`timescale 1 ns / 1 ps

module axi_write_burst_fixed #(
  parameter integer C_M_AXI_ADDR_WIDTH	= 32,
  parameter integer C_M_AXI_DATA_WIDTH	= 64
) (
	input wire  m_axi_aclk,
	input wire  m_axi_aresetn,

	output reg [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_awaddr,
	output reg [2 : 0] m_axi_awprot = 3'b000, // fixed
	output reg  m_axi_awvalid = 0,
	input wire  m_axi_awready,
	output reg [7 : 0] m_axi_awlen = 0, // burst length
	output reg [2 : 0] m_axi_awsize = $clog2(C_M_AXI_DATA_WIDTH)-3, // 8Bytes fixed
	output reg [1 : 0] m_axi_awburst = 1, // INCR fixed
	output reg m_axi_awlock = 0, // normal access fixed

	output wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_wdata,
	output wire m_axi_wvalid,
	input wire  m_axi_wready,
	output wire  m_axi_wlast,
	output reg [C_M_AXI_DATA_WIDTH/8-1 : 0] m_axi_wstrb = {C_M_AXI_DATA_WIDTH/8{1'b1}}, // all valid fixed
	input wire [1 : 0] m_axi_bresp,
	input wire  m_axi_bvalid,
	output reg  m_axi_bready = 1, // always accepts response fixed

	input wire run,
	input wire [C_M_AXI_ADDR_WIDTH-1 : 0] start_addr,
	input wire [9 : 0] byte_length, // byte length accepts

	input wire [C_M_AXI_DATA_WIDTH-1 : 0] s_axis_tdata,
	input wire s_axis_tvalid,
	output wire  s_axis_tready,
	input wire  s_axis_tlast
);

//	enum { IDLE, STARTING, RUNNING, WAITING } status;
	localparam IDLE = 0;
	localparam STARTING = 1;
	localparam RUNNING = 2;

	localparam integer C_BYTE_WIDTH = $clog2(C_M_AXI_DATA_WIDTH)-3;

	reg [1:0] status = IDLE;

	reg [C_M_AXI_DATA_WIDTH-1 : 0] read_data = 0;
	reg [9 : 0] rest_length; // byte length accepts

        reg interface_enable = 0;

	assign m_axi_wvalid = interface_enable && s_axis_tvalid;
	assign s_axis_tready = interface_enable && m_axi_wready;
	assign m_axi_wdata = s_axis_tdata;
	assign m_axi_wlast = s_axis_tlast;

	always @(posedge m_axi_aclk)
	begin
		if ( m_axi_aresetn == 1'b0 )
		begin
			 m_axi_awaddr <= 0;
			 m_axi_awvalid <= 0;
			 m_axi_awlen <= 0;
			 interface_enable <= 0;
			 status <= IDLE;
		end
		else if ( status == IDLE)
		begin
			if( run == 1 && (byte_length>>C_BYTE_WIDTH) > 0)
			begin
			 m_axi_awaddr <= start_addr;
			 m_axi_awvalid <= 1'b1;
			 m_axi_awlen <= (byte_length>>C_BYTE_WIDTH)-1;
			 interface_enable <= 0;
			 status <= STARTING;
			end
		end
		else if ( status == STARTING )
		begin
			if( m_axi_awready == 1 )
			begin
			 m_axi_awaddr <= 0;
			 m_axi_awvalid <= 0;
			 m_axi_awlen <= 0;
			 interface_enable <= 1;
			 status <= RUNNING;
			end
		end
		else if ( status == RUNNING )
		begin
			if( m_axi_wready && m_axi_wvalid && m_axi_wlast )
			begin
			 m_axi_awaddr <= 0;
			 m_axi_awvalid <= 0;
			 m_axi_awlen <= 0;
			 interface_enable <= 0;
			 status <= IDLE;
			end
		end
		else
		begin
			// do nothing
		end
	end

endmodule

