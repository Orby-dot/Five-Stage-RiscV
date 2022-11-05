// To increment the pc counter

module pc_counter (
    input wire clock,
    input wire reset,
    input wire [31:0] alu,
    input wire PC_sel,
    output reg [31:0] pc
);

initial begin
    pc = 32'h01000000;
end


always @(posedge clock) begin
  if(reset)
    pc = 32'h01000000;
  
  else
    case (PC_sel)
    1'b0:pc = pc + 4;
    1'b1:pc = (alu & 32'hfffffffe);//removed LSB due to RISC DOC (refer to jalr)
    endcase
  //$display("PC = %h   FC = %h ", address,data_out);
  end
endmodule