module key_reader (
    input         iClk,
    input         iReset_n,
    input         iChip_select_n,
    input         iRead_n,
    input  [31:0] iKey_data,
    output reg [31:0] oKey_reg
);
    always @(posedge iClk or negedge iReset_n) begin
        if (!iReset_n)
            oKey_reg <= 32'd0;
        else if (~iChip_select_n && ~iRead_n)
            oKey_reg <= iKey_data;
    end
endmodule