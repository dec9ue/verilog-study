`timescale 1 ns / 1 ps

module axi_read_burst_fixed #(
  parameter integer C_M_AXI_ADDR_WIDTH	= 32,
  parameter integer C_M_AXI_DATA_WIDTH	= 64
) (
	input wire  m_axi_aclk,
	input wire  m_axi_aresetn,

	output reg [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_araddr,
	output reg [2 : 0] m_axi_arprot = 3'b000, // fixed
	output reg  m_axi_arready,
	input wire  m_axi_arvalid = 0,
	output reg [7 : 0] m_axi_arlen = 0, // burst length
	output reg [2 : 0] m_axi_arsize = 3'b011, // 8Bytes fixed
	output reg [1 : 0] m_axi_arburst = 1, // INCR fixed
	output reg m_axi_arlock = 0, // normal access fixed

	input wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata,
	output reg  m_axi_rready,
	input wire  m_axi_rvalid = 0,
	input wire  m_axi_rlast = 0,
	input wire [1 : 0] m_axi_rresp,

	input wire run,
	input wire [C_M_AXI_ADDR_WIDTH-1 : 0] start_addr,
	input wire [9 : 0] byte_length, // byte length accepts

	output reg bram_write_enable = 0,
	output reg [9 : 0] bram_write_index = 0,
	output reg [C_M_AXI_DATA_WIDTH-1 : 0] bram_write_data = 0,
);

//	enum { IDLE, STARTING, RUNNING, WAITING } status;
	localparam IDLE = 0;
	localparam STARTING = 1;
	localparam WAITING = 2;

	reg [1:0] status = IDLE;

	reg [9 : 0] rest_length; // byte length accepts

	always @(posedge m_axi_aclk)
	begin
		if ( m_axi_aresetn == 1'b0 )
		begin
			 m_axi_araddr <= 0;
			 m_axi_arvalid <= 0;
			 m_axi_arlen <= 0;
			 m_axi_rready <= 0;
			 bram_write_enable <= 0;
			 bram_write_index <= 0;
			 bram_write_data <= 0;
			 rest_length <= 0;
			 status <= IDLE;
		end
		else if ( status == IDLE)
		begin
			if( run == 1 && (byte_length>>3) > 0)
			begin
			 m_axi_araddr <= start_addr;
			 m_axi_arvalid <= 1'b1;
			 m_axi_arlen <= (byte_length>>3)-1;
			 m_axi_rready <= 0;
			 bram_write_enable <= 0;
			 bram_write_index <= -1;
			 bram_write_data <= 0;
			 rest_length <= (byte_length>>3);
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
			 m_axi_rready <= 1;
			 bram_write_enable <= 0;
			 bram_write_index <= -1;
			 bram_write_data <= 0;
			 rest_length <= rest_length;
			 status <= WAITING;
			end
		end
		else if ( status == WAITING )
		begin // TODO: refer to RRESP a/o RLAST
			if( m_axi_rvalid == 1 && rest_length > 0)
			begin
			 m_axi_araddr <= 0;
			 m_axi_arvalid <= 0;
			 m_axi_arlen <= 0;
			 m_axi_rready <= 1;
			 bram_write_enable <= 1;
			 bram_write_index <= bram_write_index + 1;
			 bram_write_data <= m_axi_rdata;
			 rest_length <= rest_length -1;
			 status <= WAITING;
			end
			else if( m_axi_rvalid == 1 )
			begin
			 m_axi_araddr <= 0;
			 m_axi_arvalid <= 0;
			 m_axi_arlen <= 0;
			 m_axi_rready <= 1;
			 bram_write_enable <= 1;
			 bram_write_index <= bram_write_index + 1;
			 bram_write_data <= m_axi_rdata;
			 rest_length <= 0;
			 status <= IDLE;
			end
			else // m_axi_rvalid is not asserted
			 m_axi_araddr <= 0;
			 m_axi_arvalid <= 0;
			 m_axi_arlen <= 0;
			 m_axi_rready <= 1;
			 bram_write_enable <= 0;
			 // bram_write_index <= bram_write_index;
			 bram_write_data <= 0;
			 rest_length <= rest_length;
			 status <= WAITING;
			end
		end
		else
		begin
			// do nothing
		end
	end

endmodule

