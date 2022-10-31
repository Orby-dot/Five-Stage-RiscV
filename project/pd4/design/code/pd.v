module pd(
  input clock,
  input reset
);

//wires
//FETCH --------------------
wire [31:0]     address;
wire            read_write;//unused

wire [31:0]     data_in;//unused
wire [31:0]     inst;
//------------------------
//DECODE
wire [6:0]      opcode;

wire [4:0]      addr_rd;
wire [4:0]      addr_rs1;
wire [4:0]      addr_rs2;

wire [2:0]      funct3;
wire [6:0]      funct7;

wire [31:0]     imm;

wire [4:0]      shamt;

wire            b_sel;
wire [3:0]      alu_sel;
wire            pc_reg1_sel;
wire            brn_tkn;

wire [31:0]     e_pc;//effective pc after excute

wire [31:0]     alu_out;
wire            rs2_shamt_sel;

//---------------
//REG FILE---------------------------------------------
wire [31:0] data_rs1;
wire [31:0] data_rs2;
wire [31:0] data_rd;
wire write_enable;

//--------------------------------------------
//brch

wire         unsign;
wire         br_eq;
wire         br_lt;
//
//ALU-----------------------------------------------
wire [31:0] alu_out;
//

//DMEM---------------------------------------------------
wire d_RW;
wire [1:0] access_size;
wire [31:0] dmem_data_R;
//

//WRITE BACK-------------------------------------- 
wire [1:0] WB_sel;
//--------------------
assign e_pc= (brn_tkn) ? alu_out:address;
assign access_size = funct3[1:0];

//

//pc counter
pc_counter pc (
  .clock(clock),
  .reset(reset),
  .alu(alu_out),
  .PC_sel(brn_tkn),
  .pc(address)
);

//fetch instuction
imemory imem (
  .clock(clock),
  .address(address),
  .read_write(1'b0),//hard coded for imem
  .data_in(data_in),

  .data_out(inst)
);

//decode
control decode(
    .inst(inst),
    .br_eq(br_eq),
    .br_lt(br_lt),

    .opcode(opcode),
    .rd(addr_rd),
    .rs1(addr_rs1),
    .rs2(addr_rs2),
    .funct3(funct3),
    .funct7(funct7),
    .imm(imm),
    .shamt(shamt),

    .b_sel(b_sel),
    .alu_sel(alu_sel),
    .pc_reg1_sel(pc_reg1_sel),
    .brn_tkn(brn_tkn),
    .rs2_shamt_sel(rs2_shamt_sel),
    .unsign(unsign),
    .WB_sel(WB_sel),
    .write_back(write_enable),
    .d_RW(d_RW)
);

register_file reg_file(
  .clock(clock),

  .addr_rs1(addr_rs1),
  .data_rs1(data_rs1),

  .addr_rs2(addr_rs2),
  .data_rs2(data_rs2),

  .addr_rd(addr_rd),
  .data_rd(data_rd),
  .write_enable(write_enable)

);

branch_comp brn_cmpr(
    .in_a(data_rs1),
    .in_b(data_rs2),
    .unsign(unsign),
    .br_eq(br_eq),
    .br_lt(br_lt)
);


ALU alu(
  .in_a((pc_reg1_sel)? address: data_rs1 ),
  .in_b((b_sel)? imm : ((rs2_shamt_sel)?data_rs2:{{27{1'b0}},shamt})),
  .control(alu_sel),
  .out(alu_out)
);

//Dmemory

dmemory d_mem(
  .address(alu_out),
  .read_write(d_RW),
  .data_in(data_rs2),
  .access_size(access_size),
  .data_out(dmem_data_R)
);


//WRITE BACK
write_back w_back(
  .pc(address),
  .alu(alu_out),
  .data_r(
    (access_size == 0) ? ({{24{1'b0}}, dmem_data_R[7:0]}):
    (access_size == 1) ? ({{16{1'b0}}, dmem_data_R[15:0]}):
                        dmem_data_R
    ),
  .WB_sel(WB_sel),
  .wb(data_rd)
);

endmodule