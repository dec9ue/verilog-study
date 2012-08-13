

module modexp1 ( e ,n,m, r);
  input[511:0] e,n,m;
  output[511:0] r;

  assign r = modexp(e,n,m);

  function [511:0] modexp;
    input [511:0] e,n,m;
    integer i;
    reg   [1023:0] m1;
    reg   [1023:0] r1;
    
    begin
      for(i=0;i<512;i=i+1) begin
        if ( i == 0) begin
          m1 = m;
          r1 = (e[0]? m : 1) % n;
        end
        else begin
          m1 = twice_mod(m1,n);
          r1 = mult_non_zero(r1, e[i],m1) % n;
        end
      end
      modexp = r1;
    end
  endfunction

  function [1023:0] mult;
    input [511:0] m,n;
    mult = m * n;
  endfunction

  function [1023:0] mult_non_zero;
    input [511:0] r;
    input [1:0]   b;
    input [511:0] m;
    mult_non_zero = mult(r , (b == 1'b1 ? m : 1) );
  endfunction

  function [511:0] twice_mod;
    input [511:0] m, n;
    twice_mod = mult(m,m) % n;
  endfunction

endmodule





module test;
  reg  [0:511]e,n,m;
  wire [0:511]r;

  initial begin
      n  <= 16;
      m  <= 3;
      e  <= 3;
    #1
      n  <= 1024;
      m  <= 8;
      e  <= 2;
    #1
      n  <= 512'hA940A3603B2A227D3B7E945F528E92214A4F3DDAED3411A669E34AF64D59302BFAF333F281AF17C483901AF2490BC8AD3827ED7AC03A97A7B446C6AF84D2803B;
      m  <= 512'h166cc193544bf5666277170104384363562a8ff3c25ffb93f7c49244eb55ad654f51da4bbca25fa5f3fe727dbecdd0659af3d1b7b6ac8035d6cab2576aee4ce8;
      e  <= 512'h10001;
      // r:3030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030300a
  end

  modexp1 modexp(e,n,m,r);

  initial begin
    $monitor ($stime , " hello world e:%h n:%h m:%h r:%h ",e,n,m,r);
//    $monitor ($stime , " r001 %h r002 %h r003 %h",modexp.r001,modexp.r002,modexp.r003);
//    $monitor ($stime , " m001 %h m002 %h m003 %h",modexp.m001,modexp.m002,modexp.m003);
//    $monitor ($stime , " e[1] %h e[2] %h e[3] %h",modexp.e[0],modexp.e[1],modexp.e[2]);
  end

endmodule
