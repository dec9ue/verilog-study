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
	output reg [2 : 0] m_axi_awsize = 3'b011, // 8Bytes fixed
	output reg [1 : 0] m_axi_awburst = 1, // INCR fixed
	output reg m_axi_awlock = 0, // normal access fixed

	output reg [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_wdata,
	output reg [C_M_AXI_DATA_WIDTH/8-1 : 0] m_axi_wstrb = {C_M_AXI_DATA_WIDTH/8{1'b1}}, // all valid fixed
	output reg m_axi_wvalid = 0,
	input wire  m_axi_wready,
	output reg  m_axi_wlast = 0,
	input wire [1 : 0] m_axi_bresp,
	input wire  m_axi_bvalid,
	output reg  m_axi_bready = 1, // always accepts response fixed

	input wire run,
	input wire [C_M_AXI_ADDR_WIDTH-1 : 0] start_addr,
	input wire [9 : 0] byte_length, // byte length accepts

	output reg bram_read_enable = 0,
	output reg [9 : 0] bram_read_index = 0,
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] bram_read_data
);

//	enum { IDLE, STARTING, RUNNING, WAITING } status;
	localparam IDLE = 0;
	localparam STARTING = 1;
	localparam RUNNING = 2;
	localparam WAITING = 3;

	reg [1:0] status = IDLE;

	reg [C_M_AXI_DATA_WIDTH-1 : 0] read_data = 0;
	reg [9 : 0] rest_length; // byte length accepts

	always @(posedge m_axi_aclk)
	begin
		if ( m_axi_aresetn == 1'b0 )
		begin
			 m_axi_awaddr <= 0;
			 m_axi_awvalid <= 0;
			 m_axi_awlen <= 0;
			 m_axi_wdata <= 0;
			 m_axi_wvalid <= 0;
			 m_axi_wlast <= 0;
			 bram_read_enable <= 1;
			 bram_read_index <= 0;
			 read_data <= 0;
			 rest_length <= 0;
			 status <= IDLE;
		end
		else if ( status == IDLE)
		begin
			if( run == 1 && (byte_length>>3) > 0)
			begin
			 m_axi_awaddr <= start_addr;
			 m_axi_awvalid <= 1'b1;
			 m_axi_awlen <= (byte_length>>3)-1;
			 m_axi_wdata <= 0;
			 m_axi_wvalid <= 0;
			 m_axi_wlast <= 0;
			 bram_read_enable <= 1;
			 bram_read_index <= 0;
			 read_data <= bram_read_data;
			 rest_length <= (byte_length>>3)-1;
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
			 m_axi_wdata <= read_data;
			 m_axi_wvalid <= 1;
			 m_axi_wlast <= (rest_length == 0);
			 bram_read_enable <= 1;
			 bram_read_index <= bram_read_index + 1; // actual value is 1
			 read_data <= bram_read_data; // this is old data. is this right?
			 rest_length <= rest_length;
			 status <= (rest_length == 0)? WAITING : RUNNING;
			end
		end
		else if ( status == RUNNING )
		begin
			if( m_axi_wready == 1 )
			begin
			 m_axi_awaddr <= 0;
			 m_axi_awvalid <= 0;
			 m_axi_awlen <= 0;
			 m_axi_wdata <= read_data;
			 m_axi_wvalid <= 1;
			 m_axi_wlast <= (rest_length == 0);
			 bram_read_enable <= 1;
			 bram_read_index <= bram_read_index + 1;
			 read_data <= bram_read_data;
			 rest_length <= rest_length - 1;
			 status <= (rest_length == 0)? WAITING : RUNNING;
			end
		end
		else if ( status == WAITING )
		begin
			if( m_axi_wready == 1 )
			begin
			 m_axi_awaddr <= 0;
			 m_axi_awvalid <= 0;
			 m_axi_awlen <= 0;
			 m_axi_wdata <= 0;
			 m_axi_wvalid <= 0;
			 m_axi_wlast <= 0;
			 bram_read_enable <= 1;
			 bram_read_index <= 0;
			 read_data <= 0;
			 rest_length <= 0;
			 status <= IDLE;
			end
		end
		else
		begin
			// do nothing
		end
	end

endmodule

