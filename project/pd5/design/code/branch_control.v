//Purpose: to calculate brtk in excute stage

module branch_control (
    input wire enable,
    input wire [1:0] eq_or_lt //tells us if eq or less than
    input wire br_eq,
    input wire br_lt,
    output wire br_tk
);

always@(*) begin
    if(enable) begin
        case (eq_or_lt)
            2'b00: brn_tkn = br_eq;
            2'b01: brn_tkn = ~br_eq;
            2'b10: brn_tkn = br_lt;
            2'b11: brn_tkn = ~br_lt;
        endcase 
    end

    else begin
        br_tk = 0;
    end
end