`timescale 1ns/1ps

module bus_tb;
  parameter WIDTH = 32;
  reg clk, rst;
  reg 					valid_dnt;
  reg 	[WIDTH-1:0]		data_dnt;
  reg 					ready_src;
  //input
  wire	 				valid_src;
  wire [WIDTH-1:0] 		data_src;  
  wire 					ready_dnt;
  
  initial begin
    fork
      begin 
		clk = 0;
        forever #5ns clk = !clk;
      end
      begin
		rst <= 1'b0;
        #12ns;
        rst <= 1'b1;
        //#100ns;
        //rst <= 1'b0;
        #10ns;
        rst <= 1'b1;
      end
    join_none
  end

  bus_handshake dut(
	.clk			(clk		)	
	,.rst			(rst		)
	,.valid_src		(valid_src	)
	,.data_src		(data_src	)
	,.ready_src		(ready_src	)
	,.valid_dnt		(valid_dnt	)
	,.data_dnt		(data_dnt	)
	,.ready_dnt		(ready_dnt	)
  );

  //ready_src geenration
  initial begin
			ready_src = 0;
    #8ns	ready_src = 1;
    #60ns	ready_src = 0;
    #10ns	ready_src = 1;
	#40ns	ready_src = 0;
    #10ns	ready_src = 1;
	#100ns  $finish;
  end
  
  //valid_dnt generation
  initial begin
   			valid_dnt = 0;
    #10ns	valid_dnt = 1;
			data_dnt = 32'h000_0001;
    #15ns	valid_dnt = 1;
			data_dnt = 32'h000_0002;
    #10ns	valid_dnt = 0;
			data_dnt = 32'h000_0000;
	#15ns	valid_dnt = 1;
			data_dnt = 32'h000_0003;
	#10ns	valid_dnt = 1;
			data_dnt = 32'h000_0004;
	#15ns	valid_dnt = 1;
			data_dnt = 32'h000_0005;
	#10ns	valid_dnt = 1;
			data_dnt = 32'h000_0006;
	#10ns	valid_dnt = 1;
			data_dnt = 32'h000_0007;
	#10ns	valid_dnt = 1;
			data_dnt = 32'h000_0008;
	#10ns	valid_dnt = 0;
			data_dnt = 32'h000_0000;
	#10ns	valid_dnt = 1;
			data_dnt = 32'h000_0009;
	#10ns	valid_dnt = 1;
			data_dnt = 32'h000_0010;
	#10ns	valid_dnt = 1;
			data_dnt = 32'h000_0011;
	#10ns	valid_dnt = 1;
			data_dnt = 32'h000_0010;
	#10ns	valid_dnt = 1;
			data_dnt = 32'h000_0011;
	#10ns	valid_dnt = 1;
			data_dnt = 32'h000_0012;
	#10ns	valid_dnt = 1;
			data_dnt = 32'h000_0013;
  end

endmodule
