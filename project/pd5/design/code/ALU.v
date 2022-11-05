/* CONTROL LIST
    0000 = add
    default (0100)= sub
    0001 = SHIFT L signed
    0011 = SHIFT L unsigned
    0101 = SHIFT R normal 
    1101 = SHIFT R arithmetric
    0100 = XOR
    0110 = OR
    0111 = AND
    0010 = Set if less than signed
    1011 = Set if less than unsigned
*/
module ALU(
    input wire[31:0] in_a,
    input wire[31:0] in_b,
    input wire [3:0]  control, // {funct7[5], funct3}
    output reg [31:0] out
);
always@(in_a,in_b,control)begin
    case(control)
        4'b0000 :            out = in_a + in_b;                         // add
        4'b0001 :            out = {in_a[31], (in_a[30:0] << in_b) };   // shift L signed (keep same MSB, shift the rest)
        4'b0011 :            out = in_a << in_b;                        // shift L unsigned
        4'b0101 :            out = in_a >> in_b;                        // shift R 
        4'b1101 :            out = ({in_a[31],{31{1'b0}}} | (in_a >> in_b));   // shift R arithmetic (shift R and leave OG MSB)
        4'b0100 :            out = in_a ^ in_b;                         // XOR
        4'b0110 :            out = in_a | in_b;                         // OR
        4'b0111 :            out = in_a & in_b;                         // AND
        
        4'b0010 : out = (in_a[31] > in_b[31]) ? 1 :
                        (in_a[31] < in_b[31]) ? 0 :
                        (in_a == 1)?
                            ((in_a > in_b)? 1:0) :
                            ((in_a < in_b)? 1:0);//Set if less than

        4'b1011 : out = (in_a < in_b) ? 1:0;//Set if less unsign
        default:             out = in_a - in_b;                         // sub (1000)
    endcase
end
endmodule