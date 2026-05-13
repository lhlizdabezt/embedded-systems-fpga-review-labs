module Bai1 (
    // Các tín hiệu vật lý từ bo mạch DE10
    input  wire        CLOCK_50,
    input  wire [1:0]  KEY,       // Có 2 nút nhấn (Tùy bo mạch, có thể là [3:0])
    input  wire [9:0]  SW,        // 10 công tắc
    
    // 6 LED 7 đoạn hiển thị Giờ - Phút - Giây
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,
    output wire [6:0]  HEX4,
    output wire [6:0]  HEX5
);

    // Wire trung gian 32-bit kết nối với hệ thống Nios II
    wire [31:0] hex0_wire;
    wire [31:0] hex1_wire;
    wire [31:0] hex2_wire;
    wire [31:0] hex3_wire;
    wire [31:0] hex4_wire;
    wire [31:0] hex5_wire;

    // Trích xuất 7 bit thấp nhất để đẩy ra chân vật lý LED 7 đoạn
    assign HEX0 = hex0_wire[6:0];
    assign HEX1 = hex1_wire[6:0];
    assign HEX2 = hex2_wire[6:0];
    assign HEX3 = hex3_wire[6:0];
    assign HEX4 = hex4_wire[6:0];
    assign HEX5 = hex5_wire[6:0];

    // Khởi tạo (Instantiate) hệ thống Nios II dựa trên system.v
    system u0 (
        .clk_clk                           (CLOCK_50),
        .reset_reset_n                     (KEY[0]), // Dùng KEY[0] làm nút Reset cứng cho hệ thống
        
        // Ép kiểu SW (10-bit) thành 32-bit bằng cách đệm 22 bit 0
        .switch_external_connection_export ({22'd0, SW}), 
        
        // Ép kiểu KEY (2-bit) thành 32-bit bằng cách đệm 30 bit 0
        .key_external_connection_export    ({30'd0, KEY}),

        // Map các tín hiệu xuất ra HEX
        .hex0_external_connection_export   (hex0_wire),
        .hex1_external_connection_export   (hex1_wire),
        .hex2_external_connection_export   (hex2_wire),
        .hex3_external_connection_export   (hex3_wire),
        .hex4_external_connection_export   (hex4_wire),
        .hex5_external_connection_export   (hex5_wire)
    );

endmodule