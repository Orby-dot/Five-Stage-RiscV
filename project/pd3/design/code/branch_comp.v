module branch_comp(
    input wire [31:0]   in_a,
    input wire [31:0]   in_b,
    input wire          unsign,
    output reg         br_eq,
    output reg         br_lt
);

always @(in_a,in_b,unsign)begin 
    br_eq = (in_a == in_b);
    
    if(unsign)begin
        br_lt = (in_a < in_b);
    end

    else begin
        case ({in_a[31],in_b[31]})
        2'b00: br_lt = (in_a < in_b);
        2'b01: br_lt = 1'b0;
        2'b10: br_lt = 1'b1;
        2'b11: br_lt = (in_a > in_b);
        endcase
    end

end

endmodule