

module modexp1 ( e ,n,m, r);
  input[7:0] e,n,m;
  output[7:0] r;

  wire [7:0] m000, r000; wire [7:0] m001, r001; wire [7:0] m002, r002; wire [7:0] m003, r003; wire [7:0] m004, r004; wire [7:0] m005, r005; wire [7:0] m006, r006; wire [7:0] m007, r007; wire [7:0] m008, r008; 

  assign m001 = m;
  assign r001 = (1 * (e[0] == 1'b1 ? m001 : 1)) % n;

  assign m002 = twice_mod(m001,n); assign r002 = (r001 * (e[1] == 1'b1 ? m002 : 1)) % n;
  assign m003 = twice_mod(m002,n); assign r003 = (r002 * (e[2] == 1'b1 ? m003 : 1)) % n;
  assign m004 = twice_mod(m003,n); assign r004 = (r003 * (e[3] == 1'b1 ? m004 : 1)) % n;
  assign m005 = twice_mod(m004,n); assign r005 = (r004 * (e[4] == 1'b1 ? m005 : 1)) % n;
  assign m006 = twice_mod(m005,n); assign r006 = (r005 * (e[5] == 1'b1 ? m006 : 1)) % n;
  assign m007 = twice_mod(m006,n); assign r007 = (r006 * (e[6] == 1'b1 ? m007 : 1)) % n;
  assign m008 = twice_mod(m007,n); assign r008 = (r007 * (e[7] == 1'b1 ? m008 : 1)) % n;

  assign r = r008;

  function [63:0] mult;
    input [7:0] m;
    mult = m * m;
  endfunction

  function [7:0] twice_mod;
    input [7:0] m, n;
    twice_mod = mult(m) % n;
  endfunction

endmodule





module test;
  reg  [0:7]e,n,m;
  wire [0:7]r;

  initial begin
    #10
      n  <= 16;
      m  <= 3;
      e  <= 3;
    #1000
      n  <= 127;
      m  <= 7;
      e  <= 7;
  end

  modexp1 modexp(e,n,m,r);

  initial begin
    $monitor ($stime , " hello world e:%h n:%h m:%h r:%h ",e,n,m,r);
    $monitor ($stime , " hello world modexp.e:%h modexp.n:%h modexp.m:%h modexp.r:%h ",modexp.e,modexp.n,modexp.m,modexp.r);
//    $monitor ($stime , " r001 %h r002 %h r003 %h",modexp.r001,modexp.r002,modexp.r003);
//    $monitor ($stime , " m001 %h m002 %h m003 %h m004 %h m005 %h m006 %h m007 %h",modexp.m001,modexp.m002,modexp.m003,modexp.m004,modexp.m005,modexp.m006,modexp.m007);
//    $monitor ($stime , " e[1] %h e[2] %h e[3] %h",modexp.e[0],modexp.e[1],modexp.e[2]);
  end

endmodule


