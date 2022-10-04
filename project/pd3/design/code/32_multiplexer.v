module 32_multiplexer(
    input wire  [31:0]  in_a,
    input wire  [31:0]  in_b,
    input wire          control,
    output wire [31:0]  out,
)

//defaults to in_a and if control is active it outputs B
assign (!control)? out = in_a : out = in_b;


