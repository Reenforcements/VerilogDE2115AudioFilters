//Created by Austyn Larkin 2016
//All rights reserved

module Echo(
input clk,
input rst,
input AUD_BCLK,
input AUD_DACLRCK,
input AUD_ADCLRCK,
input [31:0]audioIn,

output reg [31:0]audioOut
);

reg [14:0]currentSample;
reg [14:0]lastSample;

//RAM Module
//I forget why I named it Rambo but Rambo it is

reg [14:0]address;
reg [31:0]data;
reg wren;
wire [31:0]ramOut;
Rambo myRam(
	.address(address),
	.clock(clk),
	.data(data),
	.wren(wren),
	.q(ramOut));

//Sample read from RAM
reg [31:0]echoSample;	
	
	
	

reg [3:0]s;
reg [3:0]ns;

parameter 
START = 4'd0,
WAIT = 4'd1,
GET0 = 4'd2,
GET1 = 4'd3,
GET2 = 4'd4,
STASH0 = 4'd5,
STASH1 = 4'd6,
STASH2 = 4'd7,
DONE = 4'd8,
BAD = 4'd9;

always @ (posedge clk or negedge rst)
begin
	if(rst == 0)
		begin
			s <= START;
		end
	else
		begin
			
			case(s)
				GET2:
					begin
						echoSample <= ramOut;
					end
				DONE:
					begin
						lastSample <= currentSample;
					end
				default:
					begin
					
					end
			
			endcase
			
			s <= ns;
		end
end



always @ (*)
begin
	data = 32'd0;
	address = 15'd0;
	wren = 1'b0;

	case(s)
		START:
			begin
				ns = WAIT;
			end
		WAIT:
			begin
				ns = WAIT;
			
				if(lastSample != currentSample)
					ns = GET0;
			end
		GET0:
			begin
				//Read the sample at the last sample address
				address = lastSample;
				//We're reading.
				wren = 1'b0;
				
				ns = GET1;
			end
		GET1:
			begin
				//Read the sample at the last sample address
				address = lastSample;
				//We're reading.
				wren = 1'b0;
				
				ns = GET2;
			end
		GET2:
			begin
				//Read the sample at the last sample address
				address = lastSample;
				//We're reading.
				wren = 1'b0;
				
				ns = STASH0;
			end
			
		STASH0:
			begin
				//Write the output to ram so it can echo again.
				address = lastSample;
				wren = 1'b1;
				data = audioIn;//audioOut;
				
				ns = STASH1;
			end
		STASH1:
			begin
				//Write the output to ram so it can echo again.
				address = lastSample;
				wren = 1'b1;
				data = audioIn;//audioOut;
				
				ns = STASH2;
			end
		STASH2:
			begin
				//Write the output to ram so it can echo again.
				address = lastSample;
				wren = 1'b1;
				data = audioIn;//audioOut;
				
				ns = DONE;
			end
			
		DONE:
			begin
				//We're caught up now			
				ns = WAIT;
			end
	
		BAD:
			begin
				ns = BAD;
			end
		default:
			begin
				ns = BAD;
			end
	endcase
end


wire signed [31:0]leftAudio = { {16{audioIn[31]}}, audioIn[31:16]};
wire signed [31:0]leftEcho = { {16{echoSample[31]}}, echoSample[31:16]};
reg signed [31:0]leftResult;

wire signed [31:0]rightAudio = { {16{audioIn[15]}}, audioIn[15:0]};
wire signed [31:0]rightEcho = {  {16{echoSample[15]}}, echoSample[15:0]};
reg signed [31:0]rightResult;

parameter ECHOMAIN = 32'd1;
parameter ECHOECHO = 32'd1;
parameter ECHOBOTTOM = 32'd1;

//Calculate audio output
always @ (*)
begin
	//Combine the left and right audio with their respective old echo sample from the RAM.
	/*leftResult = (($signed(leftAudio) / $signed(ECHOBOTTOM)) * $signed(ECHOMAIN))
						+ (($signed(leftEcho) / $signed(ECHOBOTTOM)) * $signed(ECHOECHO));
	rightResult = (($signed(rightAudio) / $signed(ECHOBOTTOM)) * $signed(ECHOMAIN))
						+ (($signed(rightEcho) / $signed(ECHOBOTTOM)) * $signed(ECHOECHO));
	*/
	leftResult = leftEcho;
	rightResult = rightEcho;
						
	audioOut = {leftResult[15:0], rightResult[15:0]};
						
end


//Switch to the next sample on the audio clock and when the LRCK goes high
always @ (posedge AUD_BCLK)
begin
	if(AUD_DACLRCK == 1)
		begin
			currentSample <= currentSample + 15'd1;
		end
end


endmodule