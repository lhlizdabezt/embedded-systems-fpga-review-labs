module project2
(
    input        CLOCK_50,
    input  [1:0] KEY,
    input  [17:0] SW,
    output [6:0]  HEX0,
    output [6:0]  HEX1,
    output [6:0]  HEX2,
    output [6:0]  HEX3,
    output [6:0]  HEX4,
    output [6:0]  HEX5
);

system Nios_system
(
    .clk_clk                         (CLOCK_50),
    .reset_reset_n                   (KEY[0]),
    .switches_0_conduit_end_export   ({22'd0, SW[9:0]}),
    .key_reader_0_conduit_end_export ({31'd0, KEY[1]}),
    .hex_0_conduit_end_hex0          (HEX0),
    .hex_0_conduit_end_hex1          (HEX1),
    .hex_0_conduit_end_hex2          (HEX2),
    .hex_0_conduit_end_hex3          (HEX3),
    .hex_0_conduit_end_hex4          (HEX4),
    .hex_0_conduit_end_hex5          (HEX5)
);

endmodule