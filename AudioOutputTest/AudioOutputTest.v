//Created by Austyn Larkin 2016
//All rights reserved


module AudioOutputTest
(input rst, 
input clk, 
input sw0,
input sw1,
input sw2,
input sw3,
input sw4,
input sw5,


output AUD_XCK,
input AUD_BCLK,
output AUD_DACDAT,
input AUD_DACLRCK,
input AUD_ADCDAT,
input AUD_ADCLRCK,


inout SDAT, 
output SDCLK, 
output errorLED,
output reg initSuccessLED,
output [6:0]ss1,
output [6:0]ss2,
output [15:0]redLEDs);



//Audio Clock (12.288Mhz)
wire audioClk;
wire reset_source_reset;
AudioClocker myAudioClocker(
	.audio_clk_clk(audioClk),      //    audio_clk.clk
	.ref_clk_clk(clk),        //      ref_clk.clk
	.ref_reset_reset(rst),    //    ref_reset.reset
	.reset_source_reset(reset_source_reset)  // reset_source.reset
);


reg [31:0]audioClkCounter;
always @ (posedge AUD_BCLK)
begin	
		if(AUD_DACLRCK == 1)
			audioClkCounter <= audioClkCounter + 1;
		
		if(audioClkCounter == 48000)
		begin
			initSuccessLED <= !initSuccessLED;
			audioClkCounter <= 0;
		end
end



assign AUD_XCK = audioClk;//1'bz;


//DEBOUNCE INPUTS
wire sw0Debounced;
Debouncer sw0D(
.rst(rst),
.clk(clk),
.inp(sw0),
.out(sw0Debounced)
);

wire sw1Debounced;
Debouncer sw1D(
.rst(rst),
.clk(clk),
.inp(sw1),
.out(sw1Debounced)
);
wire sw2Debounced;
Debouncer sw2D(
.rst(rst),
.clk(clk),
.inp(sw2),
.out(sw2Debounced)
);
wire sw3Debounced;
Debouncer sw3D(
.rst(rst),
.clk(clk),
.inp(sw3),
.out(sw3Debounced)
);
wire sw4Debounced;
Debouncer sw4D(
.rst(rst),
.clk(clk),
.inp(sw4),
.out(sw4Debounced)
);
wire sw5Debounced;
Debouncer sw5D(
.rst(rst),
.clk(clk),
.inp(sw5),
.out(sw5Debounced)
);
//END DEBOUNCE INPUTS



//STATE MACHINE

parameter 
START = 4'd0,
INIT = 4'd1,
WAITBYPASSSWITCHON = 4'd2,
WAITBYPASSON = 4'd3,
WAITBYPASSSWITCHOFF = 4'd4,
WAITBYPASSOFF = 4'd5,

ERRORSTATE = 4'd9;

reg [3:0]s;
reg [3:0]ns;

initial s = START;

always @ (posedge clk or negedge rst)
begin
	if(rst == 1'b0)
	begin
		s <= START;
	end
	else
	begin
		s <= ns;
	end

end



//TALKING TO AUDIO CHIP AND AUDIO CHIP INITIALIZATION.
reg audioInitPulse;
wire audioDoneInit;
wire [3:0]audioInitError;

reg manualSend;
reg [6:0]manualRegister;
reg [8:0]manualData;
wire manualSendDone;

AudioInit myAudioInit(
.rst(rst),
.clk(clk),
.initPulse(audioInitPulse),
.SDAT(SDAT),//i2c data line
.SDCLK(SDCLK),//i2c clock out.
.doneInit(audioDoneInit),//Goes high when the module is done doing its thing
.audioInitError(audioInitError),

.manualSend(manualSend),//Pulse high to send i2c data manually.
.manualRegister(manualRegister),
.manualData(manualData),
.manualDone(manualSendDone)
);
//END TALKING TO AUDIO CHIP SECTION.



//ADC AND DAC
wire DACDone;
wire ADCDone;
wire [31:0]currentADCData;
reg [31:0]currentDACData;

wire AUD_DACDATOUT;

AudioDAC myDAC(
.clk(clk),//50Mhz
.rst(rst),//reset
.AUD_BCLK(AUD_BCLK),//Audio chip clock
.AUD_DACLRCK(AUD_DACLRCK),//Will go high when ready for data.
.data(currentDACData),//The full data we want to send.

.done(DACDone),//Pulses high on done
.AUD_DACDAT(AUD_DACDATOUT)//The data to send out on each pulse.
);

assign AUD_DACDAT = (sw1Debounced == 1'b1) ? AUD_DACDATOUT : 1'b0;

AudioADC myADC(
.clk(clk),//50Mhz
.rst(rst),//reset
.AUD_BCLK(AUD_BCLK),//Audio chip clock
.AUD_ADCLRCK(AUD_ADCLRCK),//Will go high when ready for data.
.AUD_ADCDAT(AUD_ADCDAT),//The data to receive

.done(ADCDone),//Pulses high on done
.data(currentADCData)//The full data we want to send.
);


//This lights up the LEDs to show the current volume level.
Visualizer myVisual1(
clk,
rst,

currentDACData,
redLEDs);

//Effect modules
wire [31:0]echoFilterAudioOut;
Echo myEcho1(
.clk(clk),
.rst(rst),
.AUD_BCLK(AUD_BCLK),
.AUD_DACLRCK(AUD_DACLRCK),
.AUD_ADCLRCK(AUD_ADCLRCK),
.audioIn(currentADCData),

.audioOut(echoFilterAudioOut)
);

wire [31:0]lowPassFilterAudioOut;
LowPassFilter lowPassFilter(
.clk(clk),
.rst(rst),
.AUD_BCLK(AUD_BCLK),
.AUD_DACLRCK(AUD_DACLRCK),
.AUD_ADCLRCK(AUD_ADCLRCK),
.audioIn(currentADCData),

.audioOut(lowPassFilterAudioOut)
);

wire [31:0]highPassFilterAudioOut;
HighPassFilter highPassFilter(
.clk(clk),
.rst(rst),
.AUD_BCLK(AUD_BCLK),
.AUD_DACLRCK(AUD_DACLRCK),
.AUD_ADCLRCK(AUD_ADCLRCK),
.audioIn(currentADCData),

.audioOut(highPassFilterAudioOut)
);



//MID PASS
//Run the low pass through the high pass filter.
//The signal had to be amplified in the "effect selection" case below however.
wire [31:0]midPassFilterAudioOut;
HighPassFilter myHighPass2(
.clk(clk),
.rst(rst),
.AUD_BCLK(AUD_BCLK),
.AUD_DACLRCK(AUD_DACLRCK),
.AUD_ADCLRCK(AUD_ADCLRCK),
.audioIn(lowPassFilterAudioOut),

.audioOut(midPassFilterAudioOut)
);


//Effect selection
always @ (*)
begin
	currentDACData = currentADCData;
	
	case({sw5Debounced, sw4Debounced, sw3Debounced, sw2Debounced})
		4'b1000:
			begin
				currentDACData = echoFilterAudioOut;
			end
		4'b0100:
			begin
				currentDACData = highPassFilterAudioOut;
			end
		4'b0010:
			begin
				currentDACData = lowPassFilterAudioOut;
			end
		4'b0001:
			begin
				currentDACData = {$signed(midPassFilterAudioOut[31:16]) * $signed(16'd3), 
										$signed(midPassFilterAudioOut[15:0]) * $signed(16'd3)};
			end
		default:
			begin
				currentDACData = currentADCData;
			end
	endcase
end



always @ (*) 
begin
	
	audioInitPulse = 1'b0;
	
	manualSend = 1'b0;
	manualRegister = 7'd0;
	manualData = 9'd0;
	
	
	case(s)
		START:
		begin
			//Init audio
			audioInitPulse = 1'b1;
		
			ns = INIT;	
		end
		
		INIT:
		begin
		
			ns = INIT;
		
			if(audioDoneInit)
			begin
				if(sw0Debounced == 1'b1)
					ns = WAITBYPASSON;
				else
					ns = WAITBYPASSOFF;
			end
			
		end
		
		
		WAITBYPASSSWITCHON:
			begin
				
				ns = WAITBYPASSSWITCHON;
				
				if(sw0Debounced == 1'b1)
					begin
						
						ns = WAITBYPASSON;
						
					end
				
			end
		WAITBYPASSON:
			begin
			
				ns = WAITBYPASSON;
			
				manualSend = 1'b1;
				manualRegister = 7'b0000100;
				manualData = 9'b0000_11_000;
				if(manualSendDone == 1'b1)
					begin
						ns = WAITBYPASSSWITCHOFF;
					end
			
			end
		WAITBYPASSSWITCHOFF:
			begin
				
				ns = WAITBYPASSSWITCHOFF;
			
				if(sw0Debounced == 1'b0)
					begin
						
						ns = WAITBYPASSOFF;
						
					end
			end
		WAITBYPASSOFF:
			begin
			
				ns = WAITBYPASSOFF;
			
				manualSend = 1'b1;
				manualRegister = 7'b0000100;
				manualData = 9'b0000_10_000;
				if(manualSendDone == 1'b1)
					begin
						ns = WAITBYPASSSWITCHON;
					end
			
			end
		
		
		
		ERRORSTATE:
		begin
			ns = ERRORSTATE;
		end
		
		default:
		begin
			ns = s;
		end
	
	endcase
	
end
//STATE MACHINE END








//Generate a tone.
/*
//Loud noise
parameter signed tone = 16'd15000;

//100Hz
reg [31:0]toneCounter;
initial toneCounter = 0;
reg [31:0]DACIN;

//BCLK is 3,072,000Hz
//We want tone of 100Hz
always @ (posedge AUD_BCLK)
begin

	if(toneCounter < 2000)
		DACIN = {tone, tone};
	else
		DACIN = 0;
		
	toneCounter <= toneCounter + 1;	
	if(toneCounter == 4000)
		toneCounter <= 0;
	
end

*/




//Random stuff and displaying debug info
assign errorLED = sw1Debounced;

//Output the current state to the seven segment
output7Seg my7(s[3:0], ss1);
output7Seg i2cError7(audioInitError, ss2);

endmodule