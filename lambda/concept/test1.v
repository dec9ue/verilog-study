module run_test1();
  integer i;
  reg    clock,request,reset;
  wire   out;
  reg  [31:0] in1,in2;
  wire [31:0] result;

  test1_func1 test1(clock,request,reset,out,in1,in2,result);

  initial begin
    $monitor($stime,"clock %d in1 %d in2 %d result %d proc %d rest %d request %d func2_1_req %d\n",clock,in1,in2,result,test1.proc,reset,request,test1.func2_1_req);
    
    for(i = 0 ; i < 20; i=i+1) begin
      if( i == 0 ) begin
        reset = 0;
        request = 0;
        clock = 0;
        in1 = 3;
        in2 = 7;
      end
      if( i == 1 ) reset = 1;
      if( i == 2 ) reset = 0;
      if( i == 3 ) request = 1;
      #1
        clock <= 1;    
      #1
        clock <= 0;    
    end
  end
endmodule

module test1_func1(clock,request,reset,out,in1,in2,result);
  input clock;
  input request;
  input reset;
  output out;
  reg    out;
  input [31:0] in1;
  input [31:0] in2;
  output [31:0] result;
  reg    [31:0] result;
  reg   func2_1_req = 0;
  reg   func2_2_req = 0;
  wire  func2_1_out;
  wire  func2_2_out;
  wire  [31:0] func2_1_res;
  wire  [31:0] func2_2_res;
  reg   [31:0] func2_1_req_reg;
  reg   [31:0] func2_2_req_reg;
  reg   [2:0]  proc;

  test1_func2 func2_1(clock,func2_1_req,reset,func2_1_out,in1,in2,func2_1_res);
  test1_func2 func2_2(clock,func2_2_req,reset,func2_2_out,in2,in1+in2,func2_2_res);

  always @( posedge clock ) begin
    if ( reset == 1'b1 ) begin
      proc = 3'b0;
    end else begin
      casex ( proc )
        3'b0xx: begin
          result <= 0;          
              proc <= 3'b100;
        end
        3'b10x: begin
          func2_1_req <= 1'b1;
          if( func2_1_out ) begin
            begin
              $display("2_1_ret");
              func2_1_req_reg <= func2_1_res;
              proc <= 3'b110;
            end
          end
        end
        3'b110: begin
          func2_2_req <= 1'b1;
          if( func2_2_out ) begin
              $display("2_2_ret");
            func2_2_req_reg <= func2_2_res;
            proc <= 3'b111;
          end
        end
        3'b111: begin
          result <= func2_1_req_reg + func2_2_req_reg;
          begin
            func2_1_req <= 1'b1;
            proc <= 3'b111;
          end
        end
      endcase
    end
  end
  
endmodule
  
  
module test1_func2(test1_clock,test1_request,test1_reset,test1_out,test1_in1,test1_in2,test1_result);
  input test1_clock;
  input test1_request;
  input test1_reset;
  output test1_out;
  reg    test1_out;
  input [31:0] test1_in1;
  input [31:0] test1_in2;
  output [31:0] test1_result;
  reg   [31:0] test1_result;
  reg   [0:0]  proc;

  always @( posedge test1_clock ) begin
    if ( test1_reset == 1'b1 ) begin
            $display($stime,"init0");
      proc <= 1'b0;
      test1_out <= 1'b0;
    end else begin
      if( test1_request ) begin
        // out assertion is needed
        casex ( proc )
          1'b0: begin
            $display($stime,"init1");
            test1_result <= 0;          
            proc <= 1'b1;
          end
          1'b1: begin
            $display($stime,"init2");
            begin
              test1_result <= test1_in1 * test1_in2;
            end
            test1_out <= 1'b1;
          end
        endcase
      end else begin
        proc <= 1'b0;
        test1_out <= 1'b0;
      end
    end
  end
  
endmodule

 
