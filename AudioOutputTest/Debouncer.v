//Created by Austyn Larkin 2016
//All rights reserved

module Debouncer(rst, clk, inp, out);

//IO
input rst, clk, inp;
output reg out;
initial out = 1'b0;

//Regs
reg [31:0]counter;
reg lastInp;

initial counter = 0;
initial lastInp = 0;
initial out = 0;

always @(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
	begin
		counter <= 0;
		out <= inp;
		lastInp <= inp;
	end
	else
	begin
		
		//If it changed
		if(inp != lastInp)
			begin
				//Restart our count
				counter <= 0;
				lastInp <= inp;
			end
		else
			begin
				//If it's the same input as last time
				//Increment the counter and check
				if(counter == (10_000_000))
					begin
						//Set the output.
						out <= lastInp;
						//Save the current counter value.
						counter <= counter;
					end
				else
					begin
						//Add one
						counter <= counter + 1;
					end
			end
		
	end
end

endmodule