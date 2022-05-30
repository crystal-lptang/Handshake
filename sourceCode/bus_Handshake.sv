

module bus_handshake(
	clk,
	rst,
	valid_src,
	data_src,
	ready_src,
	valid_dnt,
	data_dnt,
	ready_dnt,
	);
  parameter WIDTH = 32;
  
  input 				clk;
  input 				rst;
  input 				ready_src;
  output 				valid_src;
  output [WIDTH-1:0] 	data_src;  
  output 				ready_dnt;
  input 				valid_dnt;
  input [WIDTH-1:0] 	data_dnt;
  
  //source 
  reg 					valid_src;
  reg 	[WIDTH-1:0]		data_src;
  //destination
  reg 					ready_dnt;
  
  //output valid_src
  always @(posedge clk)begin
	if(!rst) valid_src <= 1'd0;
	else	valid_src <= ready_dnt?valid_dnt:valid_src;
  end
  
  //output data_src
  always @(posedge clk)begin
	if(!rst) data_src <= 32'd0;
	else	data_src <= (ready_dnt && valid_dnt)?data_dnt:data_src;
  end

  //ready signal
  assign ready_dnt = (ready_src || ~valid_src);
  //assign ready_dnt = ready_src;
  
endmodule
