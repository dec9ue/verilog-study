

module axis_bram #(
   parameter integer C_AXIS_BRAM_ADDR_WIDTH = 12,
   parameter integer C_AXIS_BRAM_DATA_WIDTH = 64
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
   input  wire m_axis_tvalid,
   output wire m_axis_tready,
   input  wire [C_AXIS_BRAM_DATA_WIDTH-1:0] m_axis_tdata,
   input  wire [C_AXIS_BRAM_DATA_WIDTH/8-1:0] m_axis_tstrb,
   input  wire m_axis_tlast,

   // BRAM
   output wire bram_clk,
   output wire [C_AXIS_BRAM_DATA_WIDTH-1:0] bram_din,
   input  wire [C_AXIS_BRAM_DATA_WIDTH-1:0] bram_dout,
   output wire [C_AXIS_BRAM_ADDR_WIDTH-1:0] bram_addr,
   output wire bram_en,
   output wire [C_AXIS_BRAM_DATA_WIDTH/8-1:0] bram_we

);

endmodule

