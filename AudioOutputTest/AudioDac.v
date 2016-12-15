//Created by Austyn Larkin 2016
//All rights reserved

module AudioDAC(
input clk,//50Mhz
input rst,//reset
input AUD_BCLK,//Audio chip clock
input AUD_DACLRCK,//Will go high when ready for data.
input [31:0]data,//The full data we want to send.

output reg done,//Pulses high on done
output reg AUD_DACDAT//The data to send out on each pulse.
);

parameter 
START = 4'd0,
WAIT = 4'd1,
BITS = 4'd2,
DONE = 4'd3,
BAD = 4'd4;

reg [3:0]s;
reg [3:0]ns;


//For sending audio
reg [4:0]countDACBits;
initial countDACBits = 5'd31;
reg [31:0]dataCopy;


always @ (posedge AUD_BCLK or negedge rst)
begin
	if(rst == 0)
		begin
			s <= START;
			countDACBits <= 5'd31;
		end
	else
		begin
			s <= ns;
			
			case(s)
				
				WAIT:
					begin
						
						if(AUD_DACLRCK == 1)
							dataCopy <= data;
					end
				BITS:
					begin
						countDACBits <= countDACBits - 5'd1;
					end	
				DONE:
					begin
						countDACBits <= 5'd31;
					end
			
			endcase
		end
end


always @ (*)
begin
	done = 1'b0;

	case (s)
		START:
			begin
				ns = WAIT;
				
			end
		WAIT:
			begin
				ns = WAIT;
			
				if(AUD_DACLRCK == 1)
					ns = BITS;
			end
		BITS:
			begin
				ns = BITS;
			
				if(countDACBits == 0)
					ns = DONE;
			end
		DONE:
			begin
				done = 1'b1;
				
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

always @ (*)
begin
	AUD_DACDAT = dataCopy[countDACBits];
end



endmodule
