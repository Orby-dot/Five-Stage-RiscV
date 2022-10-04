module pd(
  input clock,
  input reset
);
//wires
wire [31:0]     address;
wire            read_write;//unsed
wire [31:0]     data_in;

wire [31:0]     data_out;

wire [6:0]      opcode;
wire [4:0]      rd;
wire [4:0]      rs1;
wire [4:0]      rs2;
wire [2:0]      funct3;
wire [6:0]      funct7;
wire [31:0]     imm;
wire [4:0]      shamt;

//pc counter
pc_counter pc (
  .clock(clock),
  .reset(reset),
  
  .pc(address)
);

//fetch instuction
imemory imem (
  .clock(clock),
  .address(address),
  .read_write(1'b0),//hard coded for imem
  .data_in(data_in),

  .data_out(data_out)
);

//decode
control decode(
    .inst(data_out),

    .opcode(opcode),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .funct3(funct3),
    .funct7(funct7),
    .imm(imm),
    .shamt(shamt)
);



endmodule
