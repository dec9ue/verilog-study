
module axi_bram_test #(
   parameter integer C_AXIS_BRAM_ADDR_WIDTH = 7,
   parameter integer C_AXIS_BRAM_DATA_WIDTH = 8,
   parameter integer C_AXIS_BRAM_READ_FIFO_DEPTH = 4,
   parameter integer C_AXIS_BRAM_WRITE_FIFO_DEPTH = 4
)();

bram#(
	.C_AXIS_BRAM_ADDR_WIDTH(C_AXIS_BRAM_ADDR_WIDTH),
	.C_AXIS_BRAM_DATA_WIDTH(C_AXIS_BRAM_DATA_WIDTH)
) bram (
	.reset_n(reset_n),
	.clk(clk)
);

axis_bram#(
	.C_AXIS_BRAM_ADDR_WIDTH(C_AXIS_BRAM_ADDR_WIDTH),
	.C_AXIS_BRAM_DATA_WIDTH(C_AXIS_BRAM_DATA_WIDTH),
	.C_AXIS_BRAM_READ_FIFO_DEPTH(C_AXIS_BRAM_READ_FIFO_DEPTH),
	.C_AXIS_BRAM_WRITE_FIFO_DEPTH(C_AXIS_BRAM_WRITE_FIFO_DEPTH)
) axis_bram (
	.reset_n(reset_n),
	.clk(clk),

	// control
	.ctrl_axis_m_start(ctrl_axis_m_start),
	.ctrl_r_start_index(ctrl_r_start_index),
	.ctrl_r_length(ctrl_r_length),
	.ctrl_w_start_index(ctrl_w_start_index),

	// S_AXIS
	.s_axis_tvalid(s_axis_tvalid),
	.s_axis_tready(s_axis_tready),
	.s_axis_tdata(s_axis_tdata),
	.s_axis_tstrb(s_axis_tstrb),
	.s_axis_tlast(s_axis_tlast),
   
	// M_AXIS
	.m_axis_tvalid(m_axis_tvalid),
	.m_axis_tready(m_axis_tready),
	.m_axis_tdata(m_axis_tdata),
	.m_axis_tstrb(m_axis_tstrb),
	.m_axis_tlast(m_axis_tlast),

	// BRAM
	.bram_clk(bram.bram_clk),
	.bram_din(bram.bram_din),
	.bram_dout(bram.bram_dout),
	.bram_addr(bram.bram_addr),
	.bram_en(bram.bram_en),
	.bram_we(bram.bram_we)
);

always begin
   #5;
   clk = ~clk;
end

initial begin
   @(posedge clk);
   @(posedge clk) begin
      reset_n = 1;
   end
   @(posedge clk);
   test_write;
   @(posedge clk) $display("test");
   repeat (20) @(posedge clk) $display("test");
   $finish();
end

task test_write;
   begin
      ctrl_w_start_index = 4;
      @(posedge clk) begin
         s_axis_tvalid = 1;
         s_axis_tdata = 4;
         s_axis_tstrb = 1;
         s_axis_tlast = 0;
      end
      $display("test_write 1");
      @(posedge clk) begin
         s_axis_tvalid = 1;
         s_axis_tdata = 5;
         s_axis_tstrb = 1;
         s_axis_tlast = 0;
      end
      $display("test_write 2");
      @(posedge clk) begin
         s_axis_tvalid = 1;
         s_axis_tdata = 6;
         s_axis_tstrb = 1;
         s_axis_tlast = 0;
      end
      $display("test_write 3");
      @(posedge clk) begin
         s_axis_tvalid = 1;
         s_axis_tdata = 7;
         s_axis_tstrb = 1;
         s_axis_tlast = 1;
      end
      $display("test_write 4");
   end
endtask

task test_write_prim;
   begin
   end
endtask

task test_read;
   begin
   end
endtask

task test_read_prim;
   begin
   end
endtask

reg    reset_n;
reg    clk = 0;

   // control
reg    ctrl_axis_m_start;
reg    [C_AXIS_BRAM_ADDR_WIDTH-1:0] ctrl_r_start_index;
reg    [C_AXIS_BRAM_ADDR_WIDTH-1:0] ctrl_r_length;
reg    [C_AXIS_BRAM_ADDR_WIDTH-1:0] ctrl_w_start_index;

   // S_AXIS
reg    s_axis_tvalid;
wire s_axis_tready;
reg    [C_AXIS_BRAM_DATA_WIDTH-1:0] s_axis_tdata;
reg    [C_AXIS_BRAM_DATA_WIDTH/8-1:0] s_axis_tstrb;
reg    s_axis_tlast;
   
   // M_AXIS
wire m_axis_tvalid;
reg    m_axis_tready;
wire [C_AXIS_BRAM_DATA_WIDTH-1:0] m_axis_tdata;
wire [C_AXIS_BRAM_DATA_WIDTH/8-1:0] m_axis_tstrb;
wire m_axis_tlast;

endmodule

