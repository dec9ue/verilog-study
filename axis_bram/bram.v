

module bram #(
   parameter integer C_AXIS_BRAM_ADDR_WIDTH = 12,
   parameter integer C_AXIS_BRAM_DATA_WIDTH = 64,
   parameter integer C_AXIS_BRAM_DEPTH = 2**C_AXIS_BRAM_ADDR_WIDTH
)
(
   input wire reset_n,
   input wire clk,

   // BRAM
   input  wire bram_clk,
   input  wire [C_AXIS_BRAM_DATA_WIDTH-1:0] bram_din,
   output wire [C_AXIS_BRAM_DATA_WIDTH-1:0] bram_dout,
   input  wire [C_AXIS_BRAM_ADDR_WIDTH-1:0] bram_addr,
   input  wire bram_en,
   input  wire [C_AXIS_BRAM_DATA_WIDTH/8-1:0] bram_we
);

reg [C_AXIS_BRAM_DATA_WIDTH-1:0] data [0:C_AXIS_BRAM_DEPTH-1];
reg [$clog2(C_AXIS_BRAM_DEPTH)-1:0] index;
reg en_req = 0;
integer i;

assign bram_dout = en_req ? data[index] : {C_AXIS_BRAM_DATA_WIDTH{1'b1}};

always@(posedge clk) begin
   index <= bram_addr;
   en_req <= bram_en;
   if(bram_we != {C_AXIS_BRAM_DATA_WIDTH/8{1'b0}}) begin
      data[bram_addr] <= bram_din;
   end
end

always@(posedge clk) begin
   if(en_req) begin
      $display("BRAM output : %04x %04x", index, data[index]);
   end
   if(bram_we != {C_AXIS_BRAM_DATA_WIDTH/8{1'b0}}) begin
      $display("BRAM input  : %04x %04x", bram_addr, bram_din);
   end
end

initial begin
   for(i = 0 ; i < C_AXIS_BRAM_DEPTH ;i = i + 1) begin
      data [i] = {C_AXIS_BRAM_DATA_WIDTH{1'b1}};
   end
end

endmodule

