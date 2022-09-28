// To increment the pc counter
//Will add more as project continues

module pc_counter (
    input wire clock,
    input wire reset,
    output wire [31:0] pc
);

initial begin
    pc = 32'h01000000 -4
end


always @(posedge clock) begin
  if(reset)
    address = 32'h01000000;

  else
    address = address + 4;

  //$display("PC = %h   FC = %h ", address,data_out);
end