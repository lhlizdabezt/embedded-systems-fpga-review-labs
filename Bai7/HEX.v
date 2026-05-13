module HEX(
    input iClk,
    input iRst_n,
    input iChipSelect,
    input [2:0] iAddress,
    input iWrite,
    input [31:0] iWriteData,
    output reg [6:0] oHex0,
    output reg [6:0] oHex1,
    output reg [6:0] oHex2,
    output reg [6:0] oHex3,
    output reg [6:0] oHex4,
    output reg [6:0] oHex5
);

always @(posedge iClk or negedge iRst_n) begin
    if (!iRst_n) begin
        oHex0 <= 7'b1111111;
        oHex1 <= 7'b1111111;
        oHex2 <= 7'b1111111;
        oHex3 <= 7'b1111111;
        oHex4 <= 7'b1111111;
        oHex5 <= 7'b1111111;
    end 
    else if (iChipSelect && iWrite) begin
        case (iAddress)
            3'd0 : oHex0 <= iWriteData[6:0];
            3'd1 : oHex1 <= iWriteData[6:0];
            3'd2 : oHex2 <= iWriteData[6:0];
            3'd3 : oHex3 <= iWriteData[6:0];
            3'd4 : oHex4 <= iWriteData[6:0];
            3'd5 : oHex5 <= iWriteData[6:0];
        endcase
    end
end

endmodule