
module system (
	clk_clk,
	hex0_external_connection_export,
	hex1_external_connection_export,
	hex2_external_connection_export,
	hex3_external_connection_export,
	hex4_external_connection_export,
	hex5_external_connection_export,
	key_external_connection_export,
	reset_reset_n,
	switch_external_connection_export);	

	input		clk_clk;
	output	[31:0]	hex0_external_connection_export;
	output	[31:0]	hex1_external_connection_export;
	output	[31:0]	hex2_external_connection_export;
	output	[31:0]	hex3_external_connection_export;
	output	[31:0]	hex4_external_connection_export;
	output	[31:0]	hex5_external_connection_export;
	input	[31:0]	key_external_connection_export;
	input		reset_reset_n;
	input	[31:0]	switch_external_connection_export;
endmodule
