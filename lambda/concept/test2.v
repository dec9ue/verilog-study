



// standard non-recursive function
module test2_func1(clock,request,out,args,result);
  // control signals
  input   clock;
  input   request;
  output  out;
  reg     out;

  // args/returns
  input   [31:0] args;
  output  [31:0] result;
  reg     [31:0] result;

  // internal values
  reg     [1:0]  proc = 1'b0;
  reg     [31:0] proc_args;

  // for func2
  reg     func2_request;
  wire    func2_out;
  wire    [31:0] func2_result_wire;
  reg     [31:0] func2_args;
  reg     [31:0] func2_result;
  
  // wire with func2
  test2_func2 func2(clock,func2_request,func2_out,func2_args,func2_result_wire);

  always @ ( clock ) begin
    if( request == 1'b0 ) begin
      casex ( proc ) 
        2'b00:
          begin
            // init
            out <= 1'b0;
            result <= 32'b0;
            func2_request <= 1'b0;
            func2_args   <= 32'b0;
            func2_result <= 32'b0;
            // step1
            proc_args <= args;
            proc <= 2'b1;
          end
        2'b10:
          begin
            // step2
            func2_args    = proc_args;
            func2_request = 1'b0;
            if(func2_out) begin
              func2_result <= func2_result_wire;
              proc <= 2'b11;
            end
          end
        2'bx1:
          begin
            begin
              // result
              result <= proc_args;
              // finalization
              func2_request <= 1'b0;
              func2_args   <= 32'b0;
              func2_result <= 32'b0;
            end
            out <= 1'b1;
          end
      endcase
    end else begin
      // reset
      out <= 1'b0;
      result <= 32'b0;
      proc <= 2'b0;
    end
  end
endmodule


// function without call any function
module test2_func2(clock,request,out,args,result);
  input   clock;
  input   request;
  output  out;
  reg     out;

  input   [31:0] args;
  output  [31:0] result;
  reg     [31:0] result;
  reg     [0:0]  proc = 1'b0;
  reg     [31:0] proc_args;

  always @ ( clock ) begin
    if( request == 1'b0 ) begin
      casex ( proc ) 
        1'b0:
          begin
            // init
            out <= 1'b0;
            result <= 32'b0;
            // step1
            proc_args <= args;
            proc <= 1'b1;
          end
        1'b1:
          begin
            begin
              // result
              result <= proc_args;
            end
            out <= 1'b1;
          end
      endcase
    end else begin
      // reset
      out <= 1'b0;
      result <= 32'b0;
      proc <= 1'b0;
    end
  end
endmodule

