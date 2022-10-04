/* CONTROL LIST
    000 = add
    default = sub
    001 & 011 = SHIFT L
    101 = SHIFT R
    100 = XOR
    110 = OR
    111 = AND
*/
module ALU(
    input wire[31:0] in_a,
    input wire[31:0] in_b,
    input wire [2:0]  control,
    output wire [31:0] out
);
always@(in_a,in_b,control)begin
    case(control)begin
        3'b000 :            out = in_a + in_b;
        3'b011, 3'b001:     out = in_a << in_b;
        3'b101 :            out = in_a >> in_b;
        3'b100 :            out = in_a ^ in_b;
        3'b110 :            out = in_a | in_b;
        3'b111 :            out = in_a & in_b;
        default :           out = in_a - in_b;
    end
end
endmodule