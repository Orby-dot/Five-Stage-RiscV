/*
NOTE:
  - This only has 31 total registers
  - We subtract the asked reg value by 1 (unless it is 0, then we just return 0)
  - TL;DR everything is shifted by -1
*/
module register_file 
(
  input wire             clock,

  //Rs1
  input wire    [4:0]    addr_rs1,
  output reg   [31:0]    data_rs1,

  //Rs2
  input wire    [4:0]    addr_rs2,
  output reg   [31:0]    data_rs2,

  //Rd
  input wire    [4:0]    addr_rd,
  input reg     [31:0]   data_rd,
  input wire             write_enable

);

reg [31:0] reg_mem [30:0]; //reg file

assign data_rs1 = (addr_rs1 == 0) ?  0: reg_mem[addr_rs1-1]; //rs1
assign data_rs2 = (addr_rs2 == 0) ?  0: reg_mem[addr_rs2-1]; //rs2

//loads all reg with 0 except for x2 which will be the stack pointer
integer x;
initial begin
  reg_mem[0] = `MEM_DEPTH + 32'h01000000;
  reg_mem[1] = `MEM_DEPTH + 32'h01000000;
  for (x = 2; x<32 ; x = x+1)begin 
    reg_mem[x] = 0;
  end
end


always @(*)begin
  if (write_enable) begin
    //write
    if(addr_rd != 0)
      reg_mem[addr_rd -1] <= data_rd;
  end
end

endmodule