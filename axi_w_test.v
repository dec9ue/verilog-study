
module axi_w_test ();
axi_write_burst_fixed #( .C_M_AXI_ADDR_WIDTH(32), .C_M_AXI_DATA_WIDTH(64)) w_burst (
        .m_axi_aclk(m_axi_aclk),
        .m_axi_aresetn(m_axi_aresetn),
        .m_axi_awready(m_axi_awready),
        .m_axi_wready(m_axi_wready),
        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),

        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awprot(m_axi_awprot),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_bready(m_axi_bready),

        .run(run),
        .start_addr({32{1'b0}}),
        .byte_length(9'b0),
        .bram_read_data({64{1'b0}})


);
initial begin
end
        reg m_axi_aclk = 0;
        reg m_axi_aresetn = 0;
        reg m_axi_awready = 0;
        reg m_axi_wready = 0;
        reg [1:0] m_axi_bresp = 0;
        reg m_axi_bvalid = 0;

        output wire [31 : 0] m_axi_awaddr;
        output wire [2 : 0] m_axi_awprot;
        output wire  m_axi_awvalid;
        output wire [63 : 0] m_axi_wdata;
        output wire [7 : 0] m_axi_wstrb;
        output wire m_axi_wvalid;
        output wire  m_axi_bready;


endmodule

