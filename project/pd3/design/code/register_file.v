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


  // reads are combinational, writes are sequential
  // are we accessing registers or imemory?

  // // combinational read (from imemory.v)
  // assign data_out[7:0] = (memory[trueAddr] & {8{!read_write}} );
  // assign data_out[15:8] = (memory[trueAddr + 1] & {8{!read_write}} );
  // assign data_out[23:16] = (memory[trueAddr + 2] & {8{!read_write}} );
  // assign data_out[31:24] = (memory[trueAddr + 3] & {8{!read_write}} );


  // // sequential write (slightly modified from imemory.v)
  // should be posedge clk according to lecture slides (04_datapath_control slide 14)
  // always @(posedge clock) begin  
  //   if (write_enable) begin
  //     memory[trueAddr] = data_in[7:0];
  //     memory[trueAddr + 1] = data_in[15:8];
  //     memory[trueAddr+ 2] = data_in[23:16];
  //     memory[trueAddr + 3] = data_in[31:24];
  //   end
  // end
endmodule