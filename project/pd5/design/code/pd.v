module pd(
  input clock,
  input reset
);


// naming scheme: SOURCE + name + DESTINATION LIST
//wires
//FETCH --------------------
reg [31:0]     F_address_E_WB;  // from PC module
wire           read_write;//unused

wire [31:0]    data_in;//unused
reg [31:0]     F_inst_D;  // from imem module
//------------------------
//DECODE
wire [6:0]      opcode;

wire [4:0]      addr_rd;
wire [4:0]      addr_rs1;
wire [4:0]      addr_rs2;

wire [2:0]      funct3;
wire [6:0]      funct7;

reg [31:0]      D_imm_E;

reg [4:0]       D_shamt_E;

reg             D_b_sel_E;
reg [3:0]       D_alu_sel_E;
reg             D_pc_reg1_sel_E;
reg             D_brn_tkn_F;  // daisy chained through remaining stages


reg             D_rs2_shamt_sel_E;

reg             D_unsign_E;
reg             D_d_rw_M;

//---------------
//REG FILE---------------------------------------------
reg [31:0] D_data_rs1_E;
reg [31:0] D_data_rs2_E;
wire write_enable;

//--------------------------------------------
//brch

reg         E_br_eq_D;
reg         E_br_lt_D;
//
//ALU-----------------------------------------------
reg [31:0]     E_alu_out_M_WB_F;
//

//DMEM---------------------------------------------------
reg [31:0]    M_data_R;
//

//WRITE BACK-------------------------------------- 
reg [1:0]   WB_wb_out_D;
//--------------------

reg [1:0] D_access_size_M_WB;
assign D_access_size_M_WB = funct3[1:0];

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
    .d_RW(d_rw)
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
  .in_b((b_sel) ? imm : 
        (rs2_shamt_sel) ? {{27{1'b0}},shamt} : data_rs2 ),
  .control(alu_sel),
  .out(alu_out)
);

//Dmemory

dmemory d_mem(
  .address(alu_out),
  .read_write(d_rw),
  .data_in(data_rs2),
  .access_size(access_size),
  .data_out(M_data_R)
);


//WRITE BACK
write_back w_back(
  .pc(address),
  .alu(alu_out),
  .data_r(
    (access_size == 0) ? ({{24{1'b0}}, M_data_R[7:0]}):
    (access_size == 1) ? ({{16{1'b0}}, M_data_R[15:0]}):
                        M_data_R
    ),
  .WB_sel(WB_sel),
  .wb(data_rd)
);

endmodule