	AudioClocker u0 (
		.ref_clk_clk        (<connected-to-ref_clk_clk>),        //      ref_clk.clk
		.ref_reset_reset    (<connected-to-ref_reset_reset>),    //    ref_reset.reset
		.audio_clk_clk      (<connected-to-audio_clk_clk>),      //    audio_clk.clk
		.reset_source_reset (<connected-to-reset_source_reset>)  // reset_source.reset
	);

