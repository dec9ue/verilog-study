

module axis_bram #(
   parameter integer C_AXIS_BRAM_ADDR_WIDTH = 12,
   parameter integer C_AXIS_BRAM_DATA_WIDTH = 64,
   parameter integer C_AXIS_BRAM_READ_FIFO_DEPTH = 4,
   parameter integer C_AXIS_BRAM_WRITE_FIFO_DEPTH = 4
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

// common
assign bram_addr = read_request ? read_request_index : write_request_index ;
assign bram_en   = read_request;
assign bram_we   = write_request ? E_W_DO_WRITE : E_W_NO_WRITE;

// read master
localparam E_R_IDLE = 0;
localparam E_R_RUNNING = 1;
localparam E_R_WAIT_FLUSH = 2;

reg [1:0] read_state = E_R_IDLE;
reg [C_AXIS_BRAM_ADDR_WIDTH-1:0] read_request_index = 0;
reg read_requested = 0;
reg [C_AXIS_BRAM_ADDR_WIDTH-1:0] read_rest_request_size = 0;
// TODO bit幅が怖い
wire read_request = (read_state == E_R_RUNNING && read_rest_request_size > 0 && read_fifo.size < C_AXIS_BRAM_READ_FIFO_DEPTH );
// TODO bit幅が怖い
wire [C_AXIS_BRAM_ADDR_WIDTH-1:0] read_last_data = (read_rest_request_size + read_fifo.size + read_requested) <= 1;
assign m_axis_tlast = read_last_data;

myfifo #(
	.C_DATA_WIDTH(C_AXIS_BRAM_DATA_WIDTH),
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
	//.empty(),
        // ignore
	//.write_ready(),
	//.full(),
);

always @ ( posedge clk ) begin
   if(resetn == 0) begin
      read_state <= E_R_IDLE;
   end else begin
      if(read_state == E_R_IDLE) begin
         if( ctrl_axis_m_start ) begin
            read_request_index <= ctrl_r_start_index;
            read_rest_request_size <= ctrl_r_length;
            read_state <= E_R_RUNNING;
         end
      end else if (read_state == E_R_RUNNING) begin
         if(read_request) begin
            read_rest_request_size <= read_rest_request_size - 1;
            read_request_index <= read_request_index + 1;
         end
         if(read_rest_request_size <= 1) begin
            read_state <= E_R_WAIT_FLUSH;
         end
      end else begin // E_WAIT_FLUSH
         if((!read_requested) && read_fifo.empty ) begin
            read_state <= E_R_IDLE;
         end
      end
      read_requested <= read_request;
   end
end

// write master
localparam E_W_IDLE = 0;
localparam E_W_RUNNING = 1;
localparam E_W_WAIT_FLUSH = 2;
localparam [C_AXIS_BRAM_DATA_WIDTH/8-1:0] E_W_DO_WRITE = {C_AXIS_BRAM_DATA_WIDTH/8{1'b1}};
localparam [C_AXIS_BRAM_DATA_WIDTH/8-1:0] E_W_NO_WRITE = {C_AXIS_BRAM_DATA_WIDTH/8{1'b0}};

reg [1:0] write_state = E_W_IDLE;
reg [C_AXIS_BRAM_ADDR_WIDTH-1:0] write_request_index = 0;
wire write_request = (!read_request && write_fifo.read_valid && ((write_state == E_W_RUNNING)||(write_state == E_W_WAIT_FLUSH)));

assign s_axis_tready = s_axis_enabled && write_fifo.write_ready;

myfifo #(
	.C_DATA_WIDTH(C_AXIS_BRAM_DATA_WIDTH),
	.C_FIFO_DEPTH(C_AXIS_BRAM_WRITE_FIFO_DEPTH)
) write_fifo(
	.clk(clk),
	.resetn(resetn),
	.write_valid(s_axis_tvalid && s_axis_enabled),
	.write_data(s_axis_tdata),
	.read_ready(write_request),
	.read_data(bram_din)
        // ignore but reffered to..
	//.size()
	//.empty(),
	//.read_valid(),
	//.write_ready(s_axis_enabled && s_axis_tready),
        // ignore
	//.read_ready(),
	//.full(),
);

reg s_axis_enabled = 0;

always @ ( posedge clk ) begin
   if(resetn == 0) begin
      write_state <= E_W_IDLE;
      s_axis_enabled <= 0;
   end else begin
      if(write_state == E_W_IDLE) begin
         $display("write_init");
         if( write_fifo.read_valid ) begin
            write_request_index <= ctrl_w_start_index;
            write_state <= E_W_RUNNING;
            $display("write_fifo.read_valid %01x",write_fifo.read_valid);
         end
         s_axis_enabled <= 1;
      end else begin // E_W_WAIT_FLUSH or E_W_RUNNING
         $display("write state %01x write fifo %02x",write_state, write_fifo.size);
         if(s_axis_tlast) begin
            s_axis_enabled <= 0;
            $display("tlast detected 1");
         end
         if(write_state == E_W_WAIT_FLUSH && write_fifo.empty) begin
            write_state <= E_W_IDLE;
            write_request_index <= 0;
            $display("end of data. re-initting.");
         end else if(write_request) begin
            write_request_index <= write_request_index + 1;
            $display("write request : %02x value %08x", write_request_index, bram_din);
            if (write_state == E_W_RUNNING && (s_axis_tlast || !s_axis_enabled)) begin
               $display("tlast detected 2 moving state to WAIT FOR FLUSH");
               write_state <= E_W_WAIT_FLUSH;
            end
         end
      end
   end
end

endmodule

