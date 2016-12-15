//Created by Austyn Larkin 2016
//All rights reserved

module i2c
(input rst,
input clk,
input [6:0]address,//i2c addres
input [6:0]register,
input [8:0]data,
input rw,//Read/!Write for i2c
output [3:0]error,//Will output 1 for i2c error
inout SDAT,//i2c data line
output SDCLK,//i2c clock out.
output reg done);//Goes high when the module is done doing its thing

//The slowed down clock for i2c.
reg slowi2cclk;
//I2C clock output
reg SDCLKOUT;
//What will be assigned to SDAT
reg SDATOUT;
//Counter for slowing down clk to SDCLKOUT.
reg [9:0]clkCount;
//A counter for the state of i2c.
reg [9:0]i2cState;
//If this is high there was a bad error.
reg [3:0]errorReg;

initial slowi2cclk = 1'b0;
initial i2cState = 10'd0;
initial clkCount = 10'd0;
initial errorReg = 4'd0;
initial SDATOUT = 1'bz;
initial done = 1'b0;


//Slow down the clock
always @ (posedge clk or negedge rst)
begin

	//If we're resetting or disabling i2c, do the reset routine.
	if(rst == 1'b0)
	begin
		//Next clock cycle it will go to 0
		clkCount <= 10'd0;
		slowi2cclk <= 1'b0;
		
	end
	else
	begin
	
		//Count to make a slower clock.
		clkCount <= clkCount + 10'd1;
		if(clkCount == 10'd200)
		begin
			clkCount <= 10'd0;
			//Invert the clock.s
			slowi2cclk <= !slowi2cclk;
		end
		else
		begin
			slowi2cclk <= slowi2cclk;
		end

		
	end
	
end


//On the posedge of the slower clock.
always @ (posedge slowi2cclk or negedge rst)
begin

	if(rst == 1'b0)
	begin
		i2cState <= 10'd0;
		done <= 1'b0;
	end
	else
	begin

	
	//Only increment if we're below a certain arbitrary amount so we don't overflow.
	if(i2cState < 10'd58)
		i2cState <= i2cState + 10'd1;
		
	if((errorReg != 4'd0 && errorReg != 4'hf))
	begin
		//Stop all thing
	end
	else
	begin
		//Do the i2c routine
		case(i2cState)
		
			//Signal a start
			10'd0:
			begin
				if(done == 1'b1)
				begin
					errorReg <= 4'd1;
				end
			
				SDCLKOUT <= 1;
				SDATOUT <= 1;
			end
			10'd1:
			begin
				SDCLKOUT <= 1;
				SDATOUT <= 0;
			end
			
			//Send the address
			10'd2:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= address[6];
			end
			10'd3:
				SDCLKOUT <= 1;
			
			10'd4:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= address[5];
			end
			10'd5:
				SDCLKOUT <= 1;
				
			10'd6:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= address[4];
			end
			10'd7:
				SDCLKOUT <= 1;
				
			10'd8:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= address[3];
			end
			10'd9:
				SDCLKOUT <= 1;
				
			10'd10:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= address[2];
			end
			10'd11:
				SDCLKOUT <= 1;
				
			10'd12:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= address[1];
			end
			10'd13:
				SDCLKOUT <= 1;
				
			10'd14:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= address[0];
			end
			10'd15:
				SDCLKOUT <= 1;
				
			//Send whether we're reading or writing.
				
			10'd16:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= rw;
			end
			10'd17:
				SDCLKOUT <= 1;
				
			//See if they acknowledged (ACK)
			10'd18:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= 1;
			end
			10'd19:
			begin
				SDCLKOUT <= 1;
				if(SDAT == 1)
				begin
					//This shouldn't happen.
					//Put the fatal error bit to one.
					errorReg <= 4'd2;
				end
			end
			
			//If it got this far that means we can send the register.
			
			10'd20:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= register[6];
			end
			10'd21:
				SDCLKOUT <= 1;
				
			10'd22:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= register[5];
			end
			10'd23:
				SDCLKOUT <= 1;
				
			10'd24:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= register[4];
			end
			10'd25:
				SDCLKOUT <= 1;
				
			10'd26:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= register[3];
			end
			10'd27:
				SDCLKOUT <= 1;
				
			10'd28:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= register[2];
			end
			10'd29:
				SDCLKOUT <= 1;
				
			10'd30:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= register[1];
			end
			
			10'd31:
				SDCLKOUT <= 1;
			10'd32:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= register[0];
			end
			10'd33:
				SDCLKOUT <= 1;
				
			//And one bit of data
			10'd34:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= data[8];
			end
			10'd35:
				SDCLKOUT <= 1;	
				
				
			//Done sending address. Get all that?
			10'd36:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= 1;
			end
			10'd37:
			begin
				SDCLKOUT <= 1;
				if(SDAT == 1)
				begin
					//This shouldn't happen.
					errorReg <= 4'd3;
				end
			end
			
			
			//Send the data
			10'd38:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= data[7];
			end
			10'd39:
				SDCLKOUT <= 1;
			
			10'd40:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= data[6];
			end
			10'd41:
				SDCLKOUT <= 1;
				
			10'd42:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= data[5];
			end
			10'd43:
				SDCLKOUT <= 1;
				
			10'd44:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= data[4];
			end
			10'd45:
				SDCLKOUT <= 1;
				
			10'd46:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= data[3];
			end
			10'd47:
				SDCLKOUT <= 1;
				
			10'd48:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= data[2];
			end
			10'd49:
				SDCLKOUT <= 1;
				
			10'd50:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= data[1];
			end
			10'd51:
				SDCLKOUT <= 1;
			10'd52:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= data[0];
			end
			10'd53:
				SDCLKOUT <= 1;
				
			
			//ACK
			10'd54:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= 1;
			end
			10'd55:
			begin
				SDCLKOUT <= 1;
				if(SDAT == 1)
				begin
					//This shouldn't happen.
					errorReg <= 4'd4;
				end
			end
			
			//Signal done
			10'd56:
			begin
				SDCLKOUT <= 0;
				SDATOUT <= 0;
			end
			10'd57:
			begin
				SDCLKOUT <= 1;
				SDATOUT <= 0;
			end
			10'd58:
			begin
				SDCLKOUT <= 1;
				SDATOUT <= 1;
				
				//Signal done.
				done <= 1;
				//Just so we know it passed this state. This isn't an error.
				errorReg <= 4'hf;
			end
			
			
			default:
			begin
				//Error?
				errorReg <= 4'd5;
			end
			
		
		endcase
	
	end
	
	end
		
end

//Output the SDAT data if we're enabled. 
assign SDAT = ((rst ? SDATOUT : 1'b0) == 1) ? 1'bz : 1'b0;
//Output i2c clock
assign SDCLK = SDCLKOUT;


assign error = errorReg;

endmodule