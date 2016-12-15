//Created by Austyn Larkin 2016
//All rights reserved

module Visualizer(
input clk,
input rst,

input [31:0]inputAudio,
output reg [15:0]leds);

integer i;

reg signed [15:0]averaged;
reg signed [31:0]left;
reg signed [31:0]right;

always @ (*)
begin
	left = { {16{inputAudio[31]}}, inputAudio[31:16]};
	right = { {16{inputAudio[15]}}, inputAudio[15:0]};

	
	averaged = ((left + right) / 32'd2);
	for(i = 0; i < 16; i = i + 1)
		begin
			leds[i] = ( averaged > (2048*i) ) ? 1'b1 : 1'b0;
		end
end


endmodule