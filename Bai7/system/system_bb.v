
module system (
	clk_clk,
	reset_reset_n,
	switches_0_conduit_end_export,
	hex_0_0_conduit_end_hex0,
	hex_0_0_conduit_end_hex2,
	hex_0_0_conduit_end_hex3,
	hex_0_0_conduit_end_hex4,
	hex_0_0_conduit_end_hex5,
	hex_0_0_conduit_end_hex1);	

	input		clk_clk;
	input		reset_reset_n;
	input	[31:0]	switches_0_conduit_end_export;
	output	[6:0]	hex_0_0_conduit_end_hex0;
	output	[6:0]	hex_0_0_conduit_end_hex2;
	output	[6:0]	hex_0_0_conduit_end_hex3;
	output	[6:0]	hex_0_0_conduit_end_hex4;
	output	[6:0]	hex_0_0_conduit_end_hex5;
	output	[6:0]	hex_0_0_conduit_end_hex1;
endmodule
