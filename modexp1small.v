

module modexp1 ( e ,n,m, r);
  input[7:0] e,n,m;
  output[7:0] r;

  wire [7:0] m000, r000; wire [7:0] m001, r001; wire [7:0] m002, r002; wire [7:0] m003, r003; wire [7:0] m004, r004; wire [7:0] m005, r005; wire [7:0] m006, r006; wire [7:0] m007, r007; wire [7:0] m008, r008; 

  assign m001 = m;
  assign r001 = (1 * (1 + e[0] * (m001 - 1))) % n;


  assign m002 = twice_mod(m001,n); assign r002 = (r001 * (1+ e[1] * (m002 - 1))) % n;
  assign m003 = twice_mod(m002,n); assign r003 = (r002 * (1+ e[2] * (m003 - 1))) % n;
  assign m004 = twice_mod(m003,n); assign r004 = (r003 * (1+ e[3] * (m004 - 1))) % n;
  assign m005 = twice_mod(m004,n); assign r005 = (r004 * (1+ e[4] * (m005 - 1))) % n;
  assign m006 = twice_mod(m005,n); assign r006 = (r005 * (1+ e[5] * (m006 - 1))) % n;
  assign m007 = twice_mod(m006,n); assign r007 = (r006 * (1+ e[6] * (m007 - 1))) % n;
  assign m008 = twice_mod(m007,n); assign r008 = (r007 * (1+ e[7] * (m008 - 1))) % n;

  assign r = r008;

  function [7:0] twice_mod;
    input [7:0] m, n;
    twice_mod = (m*m) % n;
  endfunction

endmodule





module test;
  reg  [0:7]e,n,m;
  wire [0:7]r;

  initial begin
    #10
      n  <= 127;
      m  <= 7;
      e  <= 7;
    #1000 e <= 4;
  end

  modexp1 aab(e,n,m,r);

  initial begin
    $monitor ($stime , " hello world e:%h n:%h m:%h r:%h ",e,n,m,r);
    $monitor ($stime , " hello world aab.e:%h aab.n:%h aab.m:%h aab.r:%h ",aab.e,aab.n,aab.m,aab.r);
//    $monitor ($stime , " r001 %h r002 %h r003 %h",aab.r001,aab.r002,aab.r003);
//    $monitor ($stime , " m001 %h m002 %h m003 %h",aab.m001,aab.m002,aab.m003);
//    $monitor ($stime , " e[1] %h e[2] %h e[3] %h",aab.e[0],aab.e[1],aab.e[2]);
  end

endmodule


