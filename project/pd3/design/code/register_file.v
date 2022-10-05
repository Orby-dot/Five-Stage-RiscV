module register_file 
(
  input wire              clock,

  input wire    [4:0]    addr_rs1,
  output reg   [31:0]    data_rs1,

  input wire    [4:0]    addr_rs2,
  output reg   [31:0]    data_rs2,

  input wire    [4:0]    addr_rd,
  input reg     [31:0]    data_rd,
  input wire              write_enable

);

reg [31:0] reg_mem [30:0]; //reg file

assign data_rs1 = (addr_rs1 == 0) ?  0: reg_mem[addr_rs1-1]; //rs1
assign data_rs2 = (addr_rs2 == 0) ?  0: reg_mem[addr_rs2-1]; //rs2

  always @(*)begin
    if (write_enable) begin
      //write
      if(addr_rd != 0)
        reg_mem[addr_rd -1] = data_rd;
    end
  end

endmodule