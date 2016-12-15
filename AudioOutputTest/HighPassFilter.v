//Created by Austyn Larkin 2016
//All rights reserved

module HighPassFilter(
input clk,
input rst,
input AUD_BCLK,
input AUD_DACLRCK,
input AUD_ADCLRCK,
input [31:0]audioIn,

output reg [31:0]audioOut
);

reg [31:0]lastAudioIn;
reg [31:0]lastOutput;
initial lastOutput = 32'd0;

//use 32 bits so we can do math and not have to worry about overflows.
wire signed [31:0]leftAudio = { {16{audioIn[31]}}, audioIn[31:16]};
wire signed [31:0]leftLastOutput = { {16{lastOutput[31]}}, lastOutput[31:16]};
wire signed [31:0]leftLastInput = { {16{lastAudioIn[31]}}, lastAudioIn[31:16]};
reg signed [31:0]leftResult;

wire signed [31:0]rightAudio = { {16{audioIn[15]}}, audioIn[15:0]};
wire signed [31:0]rightLastOutput = {  {16{lastOutput[15]}}, lastOutput[15:0]};
wire signed [31:0]rightLastInput = {  {16{lastAudioIn[15]}}, lastAudioIn[15:0]};

reg signed [31:0]rightResult;
reg signed [15:0]left;
reg signed [15:0]right;

always @ (*)
begin
	

	
	leftResult = ( $signed(leftLastOutput) * $signed(32'd2) / $signed(32'd3)) + ( ($signed(leftAudio) - $signed(leftLastInput)) * $signed(32'd2) / $signed(32'd3) );
	rightResult = ( $signed(rightLastOutput) * $signed(32'd2) / $signed(32'd3)) + ( ($signed(rightAudio) - $signed(rightLastInput)) * $signed(32'd2) / $signed(32'd3) );
	
	audioOut[31:16] = leftResult[15:0];
	audioOut[15:0] =  rightResult[15:0];
	
	
end

always @ (posedge AUD_BCLK or negedge rst)
begin
	
	if(rst == 0)
		begin
			lastOutput <= 0;
		end
	else 
		begin
		
			if(AUD_DACLRCK == 1)
			begin

				lastOutput <= audioOut;
				lastAudioIn <= audioIn;
			end
			
		end
	
end



endmodule