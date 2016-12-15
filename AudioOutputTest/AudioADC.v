//Created by Austyn Larkin 2016
//All rights reserved

module AudioADC(
input clk,//50Mhz
input rst,//reset
input AUD_BCLK,//Audio chip clock
input AUD_ADCLRCK,//Will go high when ready for data.
input AUD_ADCDAT,//The data to receive on each pulse

output reg done,//Pulses high on done
output reg [31:0]data//The full data we want to send.
);

initial data = 32'd0;


parameter 
START = 4'd0,
WAIT = 4'd1,
BITS = 4'd2,
DONE = 4'd3,
BAD = 4'd4;

reg [3:0]s;
reg [3:0]ns;


//The current bit we're receiving
reg [4:0]countADCBits;
initial countADCBits = 5'd31;
reg [31:0]tempData;


always @ (posedge AUD_BCLK or negedge rst)
begin
	if(rst == 0)
		begin
			s <= START;
			countADCBits <= 5'd31;
		end
	else
		begin
			s <= ns;
			
			case(s)
				
				BITS:
					begin
						countADCBits <= countADCBits - 5'd1;
						tempData[countADCBits] <= AUD_ADCDAT;
					end	
				DONE:
					begin
						countADCBits <= 5'd31;
						
						data <= tempData;
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
			
				if(AUD_ADCLRCK == 1)
					ns = BITS;
			end
		BITS:
			begin
				ns = BITS;
				//data[countADCBits] = AUD_ADCDAT;
			
				if(countADCBits == 0)
					ns = DONE;
			end
		DONE:
			begin
				//This will pulse done high for one cycle.
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



endmodule