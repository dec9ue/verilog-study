module run_test1();

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
  reg   func2_1_req = 0;
  reg   func2_2_req = 0;
  wire  func2_1_out;
  wire  func2_2_out;
  wire  [31:0] func2_1_res;
  wire  [31:0] func2_2_res;
  reg   [31:0] func2_1_req_reg;
  reg   [31:0] func2_2_req_reg;

  test1_func2 func2_1(clock,func2_1_req,reset,func2_1_out,in1,in2,func2_1_res);
  test1_func2 func2_2(clock,func2_2_req,reset,func2_2_out,in1,in2,func2_2_res);

  always @( posedge clock ) begin
    if(func2_1_req) begin
      
    end else  begin
    end   
    
  end
  
endmodule
  
  
module test1_func2(test1_clock,test1_request,test1_reset,test1_out,test1_in1,test1_in2,test1_result);
  input test1_clock;
  input test1_request;
  input test1_reset;
  output test1_out;
  input [31:0] test1_in1;
  input [31:0] test1_in2;
  output [31:0] test1_result;

  always @( posedge test1_clock ) begin
    
    
  end
  
endmodule
  
  
  
  
