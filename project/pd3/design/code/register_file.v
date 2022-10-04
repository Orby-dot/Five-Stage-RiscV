module register_file 
(
  input wire              clock,

  input wire    [31:0]    addr_rs1,
  output wire   [31:0]    data_rs1,

  input wire    [31:0]    addr_rs2,
  output wire   [31:0]    data_rs2,

  input wire    [31:0]    addr_rd,
  input reg     [31:0]    data_rd,
  input wire              write_enable

);

reg [30:0] reg_mem [31:0]; //reg file

assign (addr_rs1 == 0) ? data_rs1 = 0:data_rs1 = reg_mem[addr_rs1]; //rs1
assign (addr_rs2 == 0) ? data_rs2 = 0:data_rs2 = reg_mem[addr_rs2]; //rs2

  always @(*)begin
    if (write_enable) begin
      //write
      if(addr_rd != 0)
        memory[addr_rd -1] = data_rd;
    end
  end

endmodule