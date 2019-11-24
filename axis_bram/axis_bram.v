

module axis_bram #(
   parameter integer C_AXIS_BRAM_ADDR_WIDTH = 12,
   parameter integer C_AXIS_BRAM_DATA_WIDTH = 64,

   parameter integer C_AXIS_BRAM_READ_FIFO_DEPTH = 4
)
(
   input wire reset_n,
   input wire clk,

   // control
   input wire ctrl_axis_m_start,
   input wire [C_AXIS_BRAM_ADDR_WIDTH-1:0] ctrl_r_start_index,
   input wire [C_AXIS_BRAM_ADDR_WIDTH-1:0] ctrl_r_length,
   input wire [C_AXIS_BRAM_ADDR_WIDTH-1:0] ctrl_w_start_index,

   // S_AXIS
   input  wire s_axis_tvalid,
   output wire s_axis_tready,
   input  wire [C_AXIS_BRAM_DATA_WIDTH-1:0] s_axis_tdata,
   input  wire [C_AXIS_BRAM_DATA_WIDTH/8-1:0] s_axis_tstrb,
   input  wire s_axis_tlast,
   
   // M_AXIS
   output wire m_axis_tvalid,
   input  wire m_axis_tready,
   output wire [C_AXIS_BRAM_DATA_WIDTH-1:0] m_axis_tdata,
   output wire [C_AXIS_BRAM_DATA_WIDTH/8-1:0] m_axis_tstrb,
   output wire m_axis_tlast,

   // BRAM
   output wire bram_clk,
   output wire [C_AXIS_BRAM_DATA_WIDTH-1:0] bram_din,
   input  wire [C_AXIS_BRAM_DATA_WIDTH-1:0] bram_dout,
   output wire [C_AXIS_BRAM_ADDR_WIDTH-1:0] bram_addr,
   output wire bram_en,
   output wire [C_AXIS_BRAM_DATA_WIDTH/8-1:0] bram_we
);

// read master
localparam E_R_IDLE = 0;
localparam E_R_RUNNING = 1;
localparam E_R_WAIT_FLUSH = 2;
localparam [C_AXIS_BRAM_DATA_WIDTH/8-1:0] E_R_DO_WRITE = {C_AXIS_BRAM_DATA_WIDTH/8{1'b1}};
localparam [C_AXIS_BRAM_DATA_WIDTH/8-1:0] E_R_NO_WRITE = {C_AXIS_BRAM_DATA_WIDTH/8{1'b0}};

reg [1:0] read_state = E_R_IDLE;
reg [C_AXIS_BRAM_ADDR_WIDTH-1:0] read_request_index = 0;
reg read_requested = 0;
reg [C_AXIS_BRAM_ADDR_WIDTH-1:0] read_rest_request_size = 0;
// TODO bit幅が怖い
wire [C_AXIS_BRAM_ADDR_WIDTH-1:0] read_last_data = (read_rest_request_size + read_fifo.size + read_requested) <= 1;

reg  [C_AXIS_BRAM_DATA_WIDTH/8-1:0] read_bram_write_enale = E_R_NO_WRITE;

myfifo #(
	.C_DATA_WIDTH(64),
	.C_FIFO_DEPTH(C_AXIS_BRAM_READ_FIFO_DEPTH)
) read_fifo(
	.clk(clk),
	.resetn(resetn),
	.read_valid(m_axis_tvalid),
	.read_ready(m_axis_tready),
	.read_data(m_axis_tdata),
	.write_valid(read_requested),
	.write_data(bram_dout)
        // ignore but reffered to..
	//.size()
        // ignore
	//.write_ready(),
	//.full(),
	//.empty(),
);

always @ ( posedge clk ) begin
end

endmodule

