//may not have to make this a sepreate module

module write_back (
    input wire  [31:0]  pc,
    input wire  [31:0]  alu,
    input wire  [31:0]  data_r,
    input wire  [1:0]   WB_sel, // 0 = mem, 1= alu, 2 = pc+4
    output reg [31:0]  wb
);

always@(*)begin 
    case(WB_sel)
    2'b00: wb = data_r;
    2'b01: wb = alu;
    2'b10: wb = pc+4;
    2'b11: wb = 0;
    endcase
end
endmodule