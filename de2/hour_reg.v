module hour_reg (
    input         iClk,
    input         iReset_n,
    input         iChip_select_n,
    input         iWrite_n,
    input         iRead_n,
    input  [31:0] iWriteData,
    output reg [31:0] oReadData
);
    reg [15:0] val;

    always @(posedge iClk or negedge iReset_n) begin
        if (!iReset_n)
            val <= 16'd0;
        else if (~iChip_select_n && ~iWrite_n)
            val <= iWriteData[15:0];
    end

    always @(*) begin
        if (~iChip_select_n && ~iRead_n)
            oReadData = {16'd0, val};
        else
            oReadData = 32'd0;
    end
endmodule