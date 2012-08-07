module incr ( a ,b);
input[0:8] a;
output[0:8] b;

assign b = a+1;

endmodule





module test;

reg  [0:8]in;
wire [0:8]res;

incr aab(in,res);


initial begin
#10 in <= 3;
#20 in <= 7;
#30 in <= 9;
end

initial $monitor ($stime , " hello world a:%h b:%h in:%h res:%h",aab.a,aab.b,in,res);

endmodule


