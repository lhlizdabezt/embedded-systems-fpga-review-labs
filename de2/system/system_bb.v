
module system (
	clk_clk,
	hex_0_conduit_end_hex0,
	hex_0_conduit_end_hex1,
	hex_0_conduit_end_hex2,
	hex_0_conduit_end_hex3,
	hex_0_conduit_end_hex4,
	hex_0_conduit_end_hex5,
	key_reader_0_conduit_end_export,
	reset_reset_n,
	switches_0_conduit_end_export);	

	input		clk_clk;
	output	[6:0]	hex_0_conduit_end_hex0;
	output	[6:0]	hex_0_conduit_end_hex1;
	output	[6:0]	hex_0_conduit_end_hex2;
	output	[6:0]	hex_0_conduit_end_hex3;
	output	[6:0]	hex_0_conduit_end_hex4;
	output	[6:0]	hex_0_conduit_end_hex5;
	input	[31:0]	key_reader_0_conduit_end_export;
	input		reset_reset_n;
	input	[31:0]	switches_0_conduit_end_export;
endmodule
