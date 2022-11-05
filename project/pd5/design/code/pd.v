module pd(
  input clock,
  input reset
);


// naming scheme: SOURCE + CURRENT STAGE + name + DESTINATION LIST
// modules in stage X should have vars in format:
// (source) + (stage X-1) + name + (stage X) + (other destinations)
//wires
//FETCH --------------------
reg [31:0]     F_address_E_WB;  // from PC module
reg [31:0]     F_D_address_E_WB;
reg [31:0]     F_E_address_WB;
reg [31:0]     F_M_address_WB;

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
reg             D_E_brn_tkn_F;
reg             D_M_brn_tkn_F;
reg             D_WB_brn_tkn_F;


reg             D_rs2_shamt_sel_E;

reg             D_unsign_E;

reg [1:0]       D_wb_sel_WB;
reg [1:0]       D_E_wb_sel_WB;
reg [1:0]       D_M_wb_sel_WB;

wire             write_enable;

reg             D_d_rw_M;
reg             D_E_d_rw_M;

//---------------
//REG FILE---------------------------------------------
reg [31:0] D_data_rs1_E;
reg [31:0] D_data_rs2_E_M;
reg [31:0] D_E_data_rs2_M;


//--------------------------------------------
//brch

reg         E_br_eq_D;  // will be refactored anyways
reg         E_br_lt_D;
//
//ALU-----------------------------------------------
reg [31:0]     E_alu_out_M_WB_F;
reg [31:0]     E_M_alu_out_WB_F;
reg [31:0]     E_WB_alu_out_F;
//

//DMEM---------------------------------------------------
reg [31:0]    M_data_r_WB;
//

//WRITE BACK-------------------------------------- 
reg [1:0]   WB_data_rd_D;   // output wb
reg [1:0]   WB_F_data_rd_D;
//--------------------

reg [1:0] D_access_size_M_WB;
reg [1:0] D_E_access_size_M_WB;
reg [1:0] D_M_access_size_WB;

assign D_access_size_M_WB = funct3[1:0];

//

//pc counter
pc_counter pc (
  .clock(clock),
  .reset(reset),
  .alu(alu_out),
  .PC_sel(D_WB_brn_tkn_F),
  .pc(F_address_E_WB)
);

//fetch instuction
imemory imem (
  .clock(clock),
  .address(F_address_E_WB),
  .read_write(1'b0),//hard coded for imem
  .data_in(data_in),

  .data_out(F_inst_D)
);

//decode
control decode(
    .inst(F_inst_D),
    .br_eq(E_br_eq_D),  // will be refactored 
    .br_lt(E_br_lt_D),  // will be refactored

    .opcode(opcode),
    .rd(addr_rd),
    .rs1(addr_rs1),
    .rs2(addr_rs2),
    .funct3(funct3),
    .funct7(funct7),
    .imm(D_imm_E),
    .shamt(D_shamt_E),

    .b_sel(D_b_sel_E),
    .alu_sel(D_alu_sel_E),
    .pc_reg1_sel(D_pc_reg1_sel_E),
    .brn_tkn(D_brn_tkn_F),
    .rs2_shamt_sel(D_rs2_shamt_sel_E),
    .unsign(D_unsign_E),
    .WB_sel(D_wb_sel_WB),
    .write_back(write_enable),
    .d_RW(D_d_rw_M)
);

register_file reg_file(
  .clock(clock),

  .addr_rs1(addr_rs1),
  .data_rs1(D_data_rs1_E),

  .addr_rs2(addr_rs2),
  .data_rs2(D_data_rs2_E_M),

  .addr_rd(addr_rd),
  .data_rd(WB_F_data_rd_D),
  .write_enable(write_enable)

);

branch_comp brn_cmpr(
    .in_a(D_data_rs1_E),
    .in_b(D_data_rs2_E_M),
    .unsign(D_unsign_E),
    .br_eq(E_br_eq_D),
    .br_lt(E_br_lt_D)
);


ALU alu(
  .in_a((D_pc_reg1_sel_E)? F_address_E_WB: D_data_rs1_E ),
  .in_b((D_b_sel_E) ? D_imm_E : 
        (D_rs2_shamt_sel_E) ? {{27{1'b0}},D_shamt_E} : D_data_rs2_E_M ),
  .control(D_alu_sel_E),
  .out(E_alu_out_M_WB_F)
);

//Dmemory

dmemory d_mem(
  .address(E_alu_out_M_WB_F),
  .read_write(D_E_d_rw_M),
  .data_in(D_E_data_rs2_M),
  .access_size(D_E_access_size_M_WB),
  .data_out(M_data_r_WB)
);


//WRITE BACK
write_back w_back(
  .pc(F_M_address_WB),
  .alu(E_M_alu_out_WB_F),
  .data_r(
    (D_M_access_size_WB == 0) ? ({{24{1'b0}}, M_data_r_WB[7:0]}):
    (access_size == 1) ? ({{16{1'b0}}, M_data_r_WB[15:0]}):
                        M_data_r_WB
    ),
  .WB_sel(D_M_wb_sel_WB),
  .wb(WB_data_rd_D)
);

endmodule