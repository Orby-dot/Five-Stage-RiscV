module reg_file 
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

  always @(posedge clock)begin
    if (read_write) begin
      //write
      memory[addr_rd] = data_rd;
    end
  end

  //rs1
  always @(*) begin
    // $display("Addr %h", address);
    // $display("TrueAddr %h", trueAddr);
    if(addr_rs1 == 0)
        data_rs1 = 0;
    else
        data_rs1 = reg_mem[addr_rs1];
  end
  //rs2
  always @(*) begin
    // $display("Addr %h", address);
    // $display("TrueAddr %h", trueAddr);
    if(addr_rs2 == 0)
        data_rs2 = 0;
    else
        data_rs2 = reg_mem[addr_rs2];
  end

endmodule