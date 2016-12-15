//Created by Austyn Larkin 2016
//All rights reserved

module output7Seg(input [3:0]inp, output reg [6:0]display = 6'b111111);
	
	
	always@(*) begin
		case(inp)
			4'd0: 
				display = {1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1};
			4'd1: 
				display = {1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0};
			4'd2: 
				display = {1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1};
			4'd3: 
				display = {1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1};
			4'd4: 
				display = {1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0};
			4'd5: 
				display = {1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1};
			4'd6: 
				display = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1};
			4'd7: 
				display = {1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1};
			4'd8: 
				display = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1};
			4'd9: 
				display = {1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1};
			4'd10: 
				display = {1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1};
			4'd11: 
				display = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0};
			4'd12: 
				display = {1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0};
			4'd13: 
				display = {1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0};
			4'd14: 
				display = {1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1};
			4'd15: 
				display = {1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1};
		
			default:
				display = {1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0};
		endcase
		display = ~display;
	end
		

endmodule