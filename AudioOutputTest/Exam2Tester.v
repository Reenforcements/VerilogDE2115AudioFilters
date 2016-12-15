module Exam2Tester(clk, rst, sA, sB, sC, sD, A1, B1, C1, D1);

input clk, rst, sA, sB, sC, sD;
output A1, B1, C1, D1;

//Generate 60Hz clock
reg slowClk;

always @ (*)
begin
	slowClk = clk;
end

light_system exam2(
.clk(slowClk),
.rst(rst),
.sA(sA), 
.sB(sB), 
.sC(sC), 
.sD(sD), 
.A1(A1),
.B1(B1),
.C1(C1),
.D1(D1)
);

endmodule


module light_system(clk, rst, sA, sB, sC, sD, A1, B1, C1, D1);

input clk, rst, sA, sB, sC, sD;
output A1, B1, C1, D1;

reg [1:0]currentLight = 2'b11;


reg [3:0]s;
reg [3:0]ns;
parameter 
START = 4'd0,
CYCLE = 4'd1,
SWITCH = 4'd2,
WAITCHANGERED = 4'd3,
WAITCAR = 4'd4;

always @ (posedge clk or negedge rst)
begin
	if(rst == 0)
		begin
			s <= START;
		end
	else
		begin
			s <= ns;
		end
end

reg startTimer;
reg addTime;
reg [4:0]countValue;
wire timerExpired;

counting myCounting(
.rst(rst),
.clk(clk),
.en_start_count(startTimer),
.en_add_count(addTime),
.count_value(countValue),
.time_pulse(timerExpired)
);

always @ (*)
begin
	startTimer = 0;
	addTime = 0;
	
	case(s)
		START:
			begin
				ns = SWITCH;
				
				startTimer = 1;
				countValue = 12;
			end
		CYCLE:
			begin
				ns = CYCLE;
				if(sA | sB | sC | sD)
					begin
					
						//If the current light is already on.
						if(
						(({sA, sA}) & 2'd0 +
						({sB, sB}) & 2'd1 + 
						({sC, sC}) & 2'd2 + 
						({sD, sD}) & 2'd3) == currentLight)
						begin
							//Give the car time to get through and add time
							ns = WAITCAR;
							addTime = 1;
							countValue = 12;
						end
						else
						begin
							//Wait for the previous light to change
							ns = WAITCHANGERED;
							startTimer = 1;
							countValue = 6;
							
						end
					end
				else
					begin
						if(timerExpired == 1)
						begin
							ns = SWITCH;
						end
					end
			end
		SWITCH:
			begin
				ns = CYCLE;
				startTimer = 1;
				countValue = 12;
			end
		WAITCHANGERED:
			begin
				ns = WAITCHANGERED;
			
				if(timerExpired == 1)
				begin
					ns = WAITCAR;
					//Set time for car to go
					startTimer = 1;
					countValue = 12;
				end
			end
		WAITCAR:
			begin
				ns = WAITCAR;
				if(timerExpired == 1)
				begin
					ns = SWITCH;
				end
			end
		default:
			begin
			
			end
	
	endcase
	
end

always @ (posedge clk or negedge rst)
begin
	case(s)
		SWITCH:
			begin
				currentLight <= currentLight + 1'b1;
			end
	endcase
end

assign A1 = (currentLight == 2'd0) ? 1'b1 : 1'b0;
assign B1 = (currentLight == 2'd1) ? 1'b1 : 1'b0;
assign C1 = (currentLight == 2'd2) ? 1'b1 : 1'b0;
assign D1 = (currentLight == 2'd3) ? 1'b1 : 1'b0;

endmodule



module counting(rst, clk, en_start_count, en_add_count, count_value, time_pulse);

input rst, clk, en_start_count, en_add_count;
input [4:0]count_value;
output reg time_pulse;


reg [4:0]count;
reg [5:0]sec;
reg [4:0]threshold;
initial threshold = ~(5'd0);
reg added;

always @ (posedge clk or negedge rst)
begin
	if(rst == 0)
	begin
		count <= 0;
		sec <= 6'd0;
		time_pulse <= 0;
	end
	else
	begin
	
		if(en_add_count == 1)
		begin
			threshold <= threshold + count_value;
		end
			
		//If we're counting.
		if(en_start_count == 1)
		begin
			//If this is the first clock cycle we're counting
			//Then save what we're counting to.
			threshold <= count_value;
			count <= 0;
			sec <= 6'd0;
			time_pulse <= 0;
		end
		else
		begin
		
			if(count == threshold)
				begin
					time_pulse <= 1;
				end
				
			if(count > threshold)
				begin
					time_pulse <= 0;
				end
			else 
			begin
				//Count each clock
				sec <= sec + 1;
				if(sec == 60)
				begin
					//60 == 1 second
					sec <= 0;
					//Increment our seconds counter.
					count <= count + 1;
				end
			end
			
			
			
		end
		
	end
end



endmodule








