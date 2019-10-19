
module test_fifo #(
	parameter integer C_DATA_WIDTH = 8,
	parameter integer C_FIFO_DEPTH = 3
) ();
	reg clk = 0;
	reg resetn = 0;
	wire read_valid;
	reg read_ready;
	wire [C_DATA_WIDTH-1:0] read_data;
	reg write_valid;
	wire write_ready;
	reg [C_DATA_WIDTH-1:0] write_data;
	wire full;
	wire empty;

	wire write_committed = write_ready && write_valid;
	wire read_committed  = read_ready && read_valid;

	myfifo #(C_DATA_WIDTH,C_FIFO_DEPTH,0) fifo_dut(
		.clk(clk),
		.resetn(resetn),
		.read_valid(read_valid),
		.read_ready(read_ready),
		.read_data(read_data),
		.write_valid(write_valid),
		.write_ready(write_ready),
		.write_data(write_data),
		.full(full),
		.empty(empty)
	);

	reg disp_log = 0;
	always begin
		#5
		clk <= ~clk;
	end
	always @ (posedge resetn) begin
		$display("reset released");
	end
	always @ (posedge clk) begin
		if(disp_log) begin
		$display("===> clk");
		if(empty) $display("empty");
		if(full) $display("full");
		if(write_committed) $display("write : %c",write_data);
		if(read_committed) $display("read  : %c",read_data);
		#1
		$display("----");
		end
	end

	initial begin
		$display("fifo depth is %d(%dbit)",C_FIFO_DEPTH,$clog2(C_FIFO_DEPTH));
	end

	initial begin
		#5
		disp_log = 1;
		@(posedge clk) resetn = 1;
		#10
		@(negedge clk) begin
			read_ready = 1; // this read should not work
			write_data = "a";
			write_valid = 1;
		end
		#5
		@(negedge clk) begin
			read_ready = 0;
			write_data = "b";
			write_valid = 1;
		end
		#5
		@(negedge clk) begin
			read_ready = 0;
			write_data = "c";
			write_valid = 1;
		end
		#5
		@(negedge clk) begin
			read_ready = 1;
			write_data = "d";
			write_valid = 1;
		end
		#5
		@(negedge clk) begin
			read_ready = 1;
			write_data = "e";
			write_valid = 0;
		end
		#5
		@(negedge clk) begin
			read_ready = 1;
			write_data = "f";
			write_valid = 0;
		end
		#5
		@(negedge clk) begin
			read_ready = 1;
			write_data = "0";
			write_valid = 0;
		end
		#5
		@(negedge clk) begin
			read_ready = 0;
			write_data = "a";
			write_valid = 1;
		end
		#5
		@(negedge clk) begin
			read_ready = 1;
			write_data = "b";
			write_valid = 1;
		end
		#5
		@(negedge clk) begin
			read_ready = 1;
			write_data = "c";
			write_valid = 1;
		end
		#5
		@(negedge clk) begin
			read_ready = 1;
			write_data = "0";
			write_valid = 0;
		end
		#20
		$finish;
	end

endmodule

