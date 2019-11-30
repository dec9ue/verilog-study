`timescale 1 ns / 1 ps

module axi_read_burst_fixed #(
  parameter integer C_M_AXI_ADDR_WIDTH	= 32,
  parameter integer C_M_AXI_DATA_WIDTH	= 64
) (
	input wire  m_axi_aclk,
	input wire  m_axi_aresetn,

	output reg [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_araddr,
	output reg [2 : 0] m_axi_arprot = 3'b000, // fixed
	output reg m_axi_arready = 0,
	output reg m_axi_arvalid = 0,
	output reg [7 : 0] m_axi_arlen = 0, // burst length
	output reg [2 : 0] m_axi_arsize = $clog2(C_M_AXI_DATA_WIDTH)-3, // 8Bytes fixed
	output reg [1 : 0] m_axi_arburst = 1, // INCR fixed
	output reg m_axi_arlock = 0, // normal access fixed

	input wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata,
	output wire  m_axi_rready,
	input wire  m_axi_rvalid,
	input wire  m_axi_rlast,
	input wire [1 : 0] m_axi_rresp,

	input wire run,
	input wire [C_M_AXI_ADDR_WIDTH-1 : 0] start_addr,
	input wire [9 : 0] byte_length, // byte length accepts

	output wire m_axis_tvalid,
	input  wire m_axis_tready,
	output wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axis_tdata,
	output wire m_axis_tlast
);

//	enum { IDLE, STARTING, RUNNING, WAITING } status;
	localparam IDLE = 0;
	localparam STARTING = 1;
	localparam RUNNING = 2;

	localparam integer C_BYTE_WIDTH = $clog2(C_M_AXI_DATA_WIDTH)-3;

	reg [1:0] status = IDLE;
	reg interface_enable = 0;

	assign m_axis_tvalid = interface_enable && m_axi_rvalid;
	assign m_axi_rready = interface_enable && m_axis_tready;
	assign m_axis_tdata = m_axi_rdata;
	assign m_axis_tlast = m_axi_rlast;

	always @(posedge m_axi_aclk)
	begin
		if ( m_axi_aresetn == 1'b0 )
		begin
			 m_axi_araddr <= 0;
			 m_axi_arvalid <= 0;
			 m_axi_arlen <= 0;
			 interface_enable <= 0;
			 status <= IDLE;
		end
		else if ( status == IDLE)
		begin
			if( run == 1 && (byte_length>>C_BYTE_WIDTH) > 0)
			begin
			 m_axi_araddr <= start_addr;
			 m_axi_arvalid <= 1'b1;
			 m_axi_arlen <= (byte_length>>C_BYTE_WIDTH)-1;
			 interface_enable <= 0;
			 status <= STARTING;
			end
		end
		else if ( status == STARTING )
		begin
			if( m_axi_arready == 1 )
			begin
			 m_axi_araddr <= 0;
			 m_axi_arvalid <= 0;
			 m_axi_arlen <= 0;
			 interface_enable <= 1;
			 status <= RUNNING;
			end
		end
		else if ( status == RUNNING )
		begin
			// TODO rlastだけに依存するのは危険
			if( m_axi_rready && m_axi_rvalid && m_axi_rlast )
			begin
			 m_axi_araddr <= 0;
			 m_axi_arvalid <= 0;
			 m_axi_arlen <= 0;
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

