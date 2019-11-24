module myfifo #(
	parameter integer C_DATA_WIDTH = 64,
	parameter integer C_FIFO_DEPTH = 10,
	// before using this option, consider to extend FIFO_DEPTH
	parameter integer C_USE_SIMUL_IO = 0
)
(
	input  wire clk,
	input  wire resetn,
	output wire read_valid,
	input  wire read_ready,
	output wire [C_DATA_WIDTH-1:0] read_data,
	input  wire write_valid,
	output wire write_ready,
	input  wire [C_DATA_WIDTH-1:0] write_data,
	output wire full,
	output wire empty,
        output wire size
);

reg [C_DATA_WIDTH-1:0] data [0:C_FIFO_DEPTH-1];
reg [$clog2(C_FIFO_DEPTH)-1:0] wp = 0;
reg wp_wrapped = 0;
reg [$clog2(C_FIFO_DEPTH)-1:0] rp = 0;
reg rp_wrapped = 0;

assign size =
	( wp > rp ) ? wp - rp :
	( wp < rp ) ? (wp+C_FIFO_DEPTH) - rp :
	( wp_wrapped  != rp_wrapped ) ? C_FIFO_DEPTH : 0; 
wire write_committed = write_ready && write_valid;
wire read_committed  = read_ready && read_valid;

assign full  = (wp == rp) && (wp_wrapped != rp_wrapped);
assign empty = (wp == rp) && (wp_wrapped == rp_wrapped);
// TODO is condtion (read_ready && write_valid) reasonable??
// this condition can be eliminated but thruput downs
assign read_valid =  (!empty);
assign write_ready = (C_USE_SIMUL_IO) ?
	(!full) || (read_ready && write_valid) :
	(!full) ;
assign read_data = data[rp];

always @( posedge clk) begin
	if(resetn == 0) begin
		wp <= 0;
		rp <= 0;
		wp_wrapped <= 0;
		rp_wrapped <= 0;
	end
	else
	begin
		if(write_committed) begin
			data[wp] <= write_data;
			if( wp < C_FIFO_DEPTH -1) begin
				wp <= wp + 1;
			end else begin
				wp <= 0;
				wp_wrapped = ~wp_wrapped;
			end
		end
		if(read_committed) begin
			if( rp < C_FIFO_DEPTH -1) begin
				rp <= rp + 1;
			end else begin
				rp <= 0;
				rp_wrapped = ~rp_wrapped;
			end
		end
	end
end


endmodule

