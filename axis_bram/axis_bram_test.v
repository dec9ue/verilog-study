
module axi_bram_test #(
   parameter integer C_AXIS_BRAM_ADDR_WIDTH = 7,
   parameter integer C_AXIS_BRAM_DATA_WIDTH = 8,
   parameter integer C_AXIS_BRAM_READ_FIFO_DEPTH = 2,
   parameter integer C_AXIS_BRAM_WRITE_FIFO_DEPTH = 2
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
   test_write1;
   fork
      test_read1;
      test_write2;
   join
   test_read2;
   repeat (3) @(posedge clk);
   @(posedge clk) $display("finish");
   $finish();
end

task test_write1;
   begin
      ctrl_w_start_index = 4;
      @(negedge clk) begin
         s_axis_tvalid = 1;
         s_axis_tdata = 'h40;
         s_axis_tstrb = 1;
         s_axis_tlast = 0;
      end
      while(s_axis_tready == 0)@(posedge clk);
      @(negedge clk) begin
         s_axis_tvalid = 1;
         s_axis_tdata = 'h50;
         s_axis_tstrb = 1;
         s_axis_tlast = 0;
      end
      while(s_axis_tready == 0)@(posedge clk);
      @(negedge clk) begin
         s_axis_tvalid = 1;
         s_axis_tdata = 'h60;
         s_axis_tstrb = 1;
         s_axis_tlast = 0;
      end
      while(s_axis_tready == 0)@(posedge clk);
      @(negedge clk) begin
         s_axis_tvalid = 1;
         s_axis_tdata = 'h70;
         s_axis_tstrb = 1;
         s_axis_tlast = 1;
      end
      while(s_axis_tready == 0)@(posedge clk);
      @(negedge clk) begin
         s_axis_tvalid = 0;
         s_axis_tdata = 'h80;
         s_axis_tstrb = 1;
         s_axis_tlast = 1;
      end
   end
endtask

task test_read1;
   begin
      ctrl_r_start_index = 4;
      ctrl_r_length = 4;
      @(negedge clk) begin
         ctrl_axis_m_start = 1;
         m_axis_tready = 0;
      end
      @(negedge clk) begin
         ctrl_axis_m_start = 0;
         m_axis_tready = 1;
      end

      repeat(4) begin
         wait(m_axis_tvalid != 0) begin
            @(posedge clk) begin
               $display("value %08x tlast %01x",m_axis_tdata,m_axis_tlast);
            end
         end
      end

      @(negedge clk) begin
         m_axis_tready = 0;
      end
   end
endtask

task test_write2;
   begin
      ctrl_w_start_index = 0;
      @(negedge clk) begin
         s_axis_tvalid = 1;
         s_axis_tdata = 'h01;
         s_axis_tstrb = 1;
         s_axis_tlast = 0;
      end
      wait(s_axis_tready != 0)@(posedge clk);
      @(negedge clk) begin
         s_axis_tvalid = 1;
         s_axis_tdata = 'h11;
         s_axis_tstrb = 1;
         s_axis_tlast = 0;
      end
      wait(s_axis_tready != 0)@(posedge clk);
      @(negedge clk) begin
         s_axis_tvalid = 1;
         s_axis_tdata = 'h21;
         s_axis_tstrb = 1;
         s_axis_tlast = 0;
      end
      wait(s_axis_tready != 0)@(posedge clk);
      @(negedge clk) begin
         s_axis_tvalid = 1;
         s_axis_tdata = 'h31;
         s_axis_tstrb = 1;
         s_axis_tlast = 1;
      end
      wait(s_axis_tready != 0)@(posedge clk);
      @(negedge clk) begin
         s_axis_tvalid = 0;
         s_axis_tdata = 'h81;
         s_axis_tstrb = 1;
         s_axis_tlast = 1;
      end
   end
endtask

task test_read2;
   begin
      ctrl_r_start_index = 0;
      ctrl_r_length = 4;
      @(negedge clk) begin
         ctrl_axis_m_start = 1;
         m_axis_tready = 0;
      end
      @(negedge clk) begin
         ctrl_axis_m_start = 0;
         m_axis_tready = 1;
      end

      repeat(4) begin
         wait(m_axis_tvalid != 0) begin
            @(posedge clk) begin
               $display("value %08x tlast %01x",m_axis_tdata,m_axis_tlast);
            end
         end
      end

      @(negedge clk) begin
         m_axis_tready = 0;
      end
   end
endtask

always@(posedge axis_bram.read_request) $display("axis_bram.read_request raised");
always@(negedge axis_bram.read_request) $display("axis_bram.read_request fell");
always@(posedge axis_bram.s_axis_tready) $display("axis_bram.write_ready raised");
always@(negedge axis_bram.s_axis_tready) $display("axis_bram.write_ready fell");
always@(posedge axis_bram.write_fifo.read_ready) $display("axis_bram.write_ready raised");
always@(negedge axis_bram.write_fifo.read_ready) $display("axis_bram.write_ready fell");
always@(posedge axis_bram.write_fifo.read_valid) $display("axis_bram.read_valid raised");
always@(negedge axis_bram.write_fifo.read_valid) $display("axis_bram.read_valid fell");

always@(posedge clk) begin
   if(s_axis_tready && s_axis_tvalid)
      $display("AXIS input  : %08x tlast %01x",s_axis_tdata,s_axis_tlast);
   if(m_axis_tready && m_axis_tvalid)
      $display("AXIS output : %08x tlast %01x",m_axis_tdata,m_axis_tlast);
end

always@(negedge clk) begin
   $display("===============================");
end

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

