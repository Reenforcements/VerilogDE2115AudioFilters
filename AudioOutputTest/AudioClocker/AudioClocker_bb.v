
module AudioClocker (
	ref_clk_clk,
	ref_reset_reset,
	audio_clk_clk,
	reset_source_reset);	

	input		ref_clk_clk;
	input		ref_reset_reset;
	output		audio_clk_clk;
	output		reset_source_reset;
endmodule
