module register_file
(
  input wire              clock,
  input wire              write_enable, // active HIGH
  input wire    [4:0]     addr_rs1,     // select 1st reg
  input wire    [4:0]     addr_rs2,     // select 2nd reg
  input wire    [4:0]     addr_rd,      // select dest reg
  input wire    [31:0]    data_rd,
  output wire   [31:0]    data_rs1,
  output wire   [31:0]    data_rs2
);

endmodule