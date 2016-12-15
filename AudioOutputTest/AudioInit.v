//Created by Austyn Larkin 2016
//All rights reserved

module AudioInit(
input rst,
input clk,
input initPulse,
inout SDAT,//i2c data line
output SDCLK,//i2c clock out.
output reg doneInit,//Goes high when the module is done doing its thing
output [3:0]audioInitError,

input manualSend,//Pulse high to send i2c data manually.
input [6:0]manualRegister,
input [8:0]manualData,
output reg manualDone
);


parameter ADDRESS = 7'b0011010;
reg [6:0]REGISTERS[0:5];
reg [8:0]DATA[0:5];

reg [3:0]currentInit;
reg [2:0]initState;


//i2c interface
reg i2cEnable;
initial i2cEnable = 1'b0;

reg [6:0]i2cRegister;
reg [8:0]i2cData;
wire [3:0]i2cError;
wire i2cDone;

i2c myI2c(
.rst(i2cEnable),
.clk(clk),
.address(ADDRESS),//Same address every time: the sound chip.
.register(i2cRegister),
.data(i2cData),
.rw(1'b0),//We're always writing. Can't read from this device.
.error(i2cError),//This will output an error if something goes wrong.
.SDAT(SDAT),//This is the i2c data line.
.SDCLK(SDCLK),
.done(i2cDone)//Will go high when i2c is done.
);



always @ (posedge clk or negedge rst)
begin

	if(rst == 0)
		begin
			initState <= 0;
		end
	else
		begin
		
			case(initState)
			
				3'd0:
					begin
					
						DATA[0] <= 9'b0_000_1_0000;//Power *most* on.
						DATA[1] <= 9'b0_0_1_0_1_00_11;//Audio format
						DATA[2] <= 9'b0000_11_000;//DACSEL ON, BYPASS on.
						
						DATA[3] <= 9'b0000_0_0_00_0;//DACMU[te] off
						DATA[4] <= 9'b000000001;//Activate
						DATA[5] <= 9'b0_000_0_0000;//Power all the way on.
						
						REGISTERS[0] <= 7'b0000110;//Power Control
						REGISTERS[1] <= 7'b0000111;//Digital Audio Interface (Audio format)
						REGISTERS[2] <= 7'b0000100;//Analog Audio Path Control (BYPASS, DACSEL)
						
						REGISTERS[3] <= 7'b0000101;//Digital Audio Path Control
						REGISTERS[4] <= 7'b0001001;//Activate Control
						REGISTERS[5] <= 7'b0000110;//Power Control
					
						//Wait for the go signal.
						if(initPulse)
							begin
								initState <= initState + 1'b1;
							end
					end
			
				3'd1:
					begin
					
						i2cEnable <= 1;
						i2cRegister <= REGISTERS[currentInit];
						i2cData <= DATA[currentInit];
					
						//Go to next state to wait
						initState <= initState + 1'b1;
					
					end
				3'd2:
					begin
						
						//Wait for completion
						if(i2cDone)
							begin
								initState <= initState + 1'b1;
							end
						else
							begin
								//Keep waiting
							end
					
					end
				3'd3:
					begin
						
						//Disable i2c.
						i2cEnable <= 1'b0;
						//Do we have more to do?
						if(currentInit < 5)
							begin
								//Setup next register.
								currentInit <= currentInit + 1'b1;
								//Go back to beginning
								initState <= 3'd1;
							end
						else
							begin
								//Stay here forever.
								//"Remove" this module from the circuit too.
								initState = 3'd4;
							end
					
					end
				3'd4:
					begin
						//Stay here forever.
						doneInit <= 1;
						manualDone <= 1'b0;
						i2cEnable <= 1'b0;
						
						//Unless we want to send data manually...
						if(manualSend == 1'b1)
						begin
						
							//Send i2c data manually.
							i2cEnable <= 1'b1;
							i2cData <= manualData;
							i2cRegister <= manualRegister;
							
							//Go to a wait state.
							initState <= 3'd5;
						end
					end
					
				3'd5:
					begin
						
						if(i2cDone)
						begin
							//Go to a finished state
							initState <= 3'd6;
						end
						
					end
				3'd6:
					begin
						//Done
						i2cEnable <= 1'b0;
						manualDone <= 1'b1;
						initState <= 3'd4;
					end
					
				default:
					begin
					
					end
			
			endcase
			
		end

end

assign audioInitError = i2cError;


endmodule