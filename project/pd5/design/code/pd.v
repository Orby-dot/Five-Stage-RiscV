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
reg [31:0]     F_WB_address_WB;

wire           read_write;//unused
wire [31:0]    data_in;//unused

reg [31:0]     F_inst_D;  // from imem module
reg [31:0]     D_inst_D;
//DECODE
wire [6:0]      opcode;

reg [4:0]       D_addr_rd_WB;
reg [4:0]       D_E_addr_rd_WB;
reg [4:0]       D_M_addr_rd_WB;
reg [4:0]       D_WB_addr_rd_WB;
//wire [4:0]      addr_rd;
reg [4:0]      D_addr_rs1_E;
reg [4:0]      D_E_addr_rs1_E;

reg [4:0]      D_addr_rs2_E;
reg [4:0]      D_E_addr_rs2_E;
reg [4:0]      D_M_addr_rs2_E;

wire [2:0]      funct3;
wire [6:0]      funct7;

reg [31:0]      D_imm_E;
reg [31:0]      D_E_imm_E;

reg [4:0]       D_shamt_E;
reg [4:0]       D_E_shamt_E;

reg             D_b_sel_E;
reg             D_E_b_sel_E;

reg [3:0]       D_alu_sel_E;
reg [3:0]       D_E_alu_sel_E;

reg             D_pc_reg1_sel_E;
reg             D_E_pc_reg1_sel_E;

reg             D_pc_jump_F;  // daisy chained through remaining stages
reg             D_E_pc_jump_F;
reg             D_M_pc_jump_F;
reg             D_WB_pc_jump_F;
reg             D_F_pc_jump_F;


reg             D_rs2_shamt_sel_E;
reg             D_E_rs2_shamt_sel_E;

reg             D_unsign_E;
reg             D_E_unsign_E; 

reg [1:0]       D_wb_sel_WB;
reg [1:0]       D_E_wb_sel_WB;
reg [1:0]       D_M_wb_sel_WB;
reg [1:0]       D_WB_wb_sel_WB;

reg             D_write_enable_WB;
reg             D_E_write_enable_WB;
reg             D_M_write_enable_WB;
reg             D_WB_write_enable_WB;

reg             D_d_rw_M;
reg             D_E_d_rw_M;
reg             D_M_d_rw_M;

//---------------
//REG FILE---------------------------------------------
reg [31:0] D_data_rs1_E;
reg [31:0] D_E_data_rs1_E;

reg [31:0] D_data_rs2_E_M;
reg [31:0] D_E_data_rs2_M;
reg [31:0] D_M_data_rs2_M;



//brch----------------------------------------
wire br_eq;
wire br_lt;

reg E_brn_tkn_F;
reg E_M_brn_tkn_F;
reg E_WB_brn_tkn_F;
reg E_F_brn_tkn_F;

reg D_brn_enable_E;
reg D_E_brn_enable_E;

reg [1:0] D_brn_signal_E;
reg [1:0] D_E_brn_signal_E;

//ALU-----------------------------------------------
reg [31:0]     E_alu_out_M_WB_F;
reg [31:0]     E_M_alu_out_WB_F;
reg [31:0]     E_WB_alu_out_F;
reg [31:0]     E_F_alu_out_F;

wire [31:0] in_a;
wire [31:0] in_b;


//DMEM---------------------------------------------------
reg [31:0]    M_data_r_WB;
reg [31:0]    M_WB_data_r_WB;


//WRITE BACK-------------------------------------- 
reg [31:0]   WB_data_rd_D;   // output wb
reg [31:0]   WB_F_data_rd_D;
reg [31:0]   WB_D_data_rd_D;


reg [1:0] D_access_size_M_WB;
reg [1:0] D_E_access_size_M_WB;
reg [1:0] D_M_access_size_WB;
reg [1:0] D_WB_access_size_WB;

////////////////////
// DAISY CHAINING //
////////////////////

wire stall; //stall control sig

//if execute is load and its rd is equal to either rs1 or rs2 of decode, and decode is not a store
assign stall = ((D_E_wb_sel_WB==0) && ((D_E_addr_rd_WB == D_addr_rs1_E && D_E_addr_rd_WB != 0) ||(D_E_addr_rd_WB == D_addr_rs2_E && D_E_addr_rd_WB != 0)) && (~D_d_rw_M));
initial begin
    F_address_E_WB = 32'h01000000-4;
end

always@(posedge clock) begin
  if(reset)
    F_address_E_WB <= 32'h01000000;
  
  else if (~stall) 
  begin

    case ((D_F_pc_jump_F || E_F_brn_tkn_F))
      1'b0:F_address_E_WB <= F_address_E_WB + 4;
      1'b1:F_address_E_WB <= (E_F_alu_out_F);
    endcase
  
    D_access_size_M_WB <= funct3[1:0];
    //address
    F_D_address_E_WB <= F_address_E_WB;
    F_E_address_WB <= F_D_address_E_WB;
    F_M_address_WB <= F_E_address_WB;
    F_WB_address_WB <= F_M_address_WB;

    //inst
    D_inst_D = F_inst_D;

    //addr_rd
    D_E_addr_rd_WB <= D_addr_rd_WB;
    D_M_addr_rd_WB <= D_E_addr_rd_WB;
    D_WB_addr_rd_WB <= D_M_addr_rd_WB;

    //addr_rs1
    D_E_addr_rs1_E <= D_addr_rs1_E;

    //addr_rs2
    D_E_addr_rs2_E <= D_addr_rs2_E;
    D_M_addr_rs2_E <= D_E_addr_rs2_E;

    //imm
    D_E_imm_E <= D_imm_E;
    
    //shamt
    D_E_shamt_E = D_shamt_E;

    //b_sel
    D_E_b_sel_E <= D_b_sel_E;

    //alu_sel
    D_E_alu_sel_E <= D_alu_sel_E;

    //pc_reg1_sel
    D_E_pc_reg1_sel_E <= D_pc_reg1_sel_E;

    //pc_jump
    D_E_pc_jump_F <= D_pc_jump_F;
    D_M_pc_jump_F <= D_E_pc_jump_F;
    D_WB_pc_jump_F <= D_M_pc_jump_F;
    D_F_pc_jump_F <= D_WB_pc_jump_F;

    //rs2_shamt_sel
    D_E_rs2_shamt_sel_E <= D_rs2_shamt_sel_E;

    //unsign
    D_E_unsign_E <= D_unsign_E;

    // wb_sel
    D_E_wb_sel_WB <= D_wb_sel_WB;
    D_M_wb_sel_WB <= D_E_wb_sel_WB;
    D_WB_wb_sel_WB <= D_M_wb_sel_WB;

    //write_enable
    D_E_write_enable_WB <= D_write_enable_WB;
    D_M_write_enable_WB <= D_E_write_enable_WB;
    D_WB_write_enable_WB <= D_M_write_enable_WB;

    //d_rw
    D_E_d_rw_M <= D_d_rw_M;
    D_M_d_rw_M <= D_E_d_rw_M;

    // data_rs2
    D_E_data_rs2_M <= D_data_rs2_E_M;
    D_M_data_rs2_M <= D_E_data_rs2_M;

    //data_rs1
    D_E_data_rs1_E <= D_data_rs1_E;

    //alu_out 
    E_M_alu_out_WB_F <= E_alu_out_M_WB_F;
    E_WB_alu_out_F <= E_M_alu_out_WB_F;
    E_F_alu_out_F <= E_WB_alu_out_F;

    //data_r
    M_WB_data_r_WB <= M_data_r_WB;

    //brn_tkn
    E_M_brn_tkn_F <= E_brn_tkn_F;
    E_WB_brn_tkn_F <= E_M_brn_tkn_F;
    E_F_brn_tkn_F <= E_WB_brn_tkn_F;

    //brn_enable
    D_E_brn_enable_E <= D_brn_enable_E;

    //brn_signal
    D_E_brn_signal_E <= D_brn_signal_E;

    //data_rd
    WB_F_data_rd_D <= WB_data_rd_D;
    WB_D_data_rd_D <= WB_F_data_rd_D;
    

    //access_size
    D_E_access_size_M_WB <= D_access_size_M_WB;
    D_M_access_size_WB <= D_E_access_size_M_WB;
    D_WB_access_size_WB <= D_M_access_size_WB;
  end

  else begin
    //not changing pc 
    // case ((D_F_pc_jump_F || E_F_brn_tkn_F))
    //   1'b0:F_address_E_WB <= F_address_E_WB + 4;
    //   1'b1:F_address_E_WB <= (E_F_alu_out_F);
    // endcase

    $display("STALL at %h", F_D_address_E_WB);
    D_access_size_M_WB <= funct3[1:0];
    //address
    //not moving the address
    // F_D_address_E_WB <= F_address_E_WB;
    // F_E_address_WB <= F_D_address_E_WB;
    F_M_address_WB <= F_E_address_WB;
    F_WB_address_WB <= F_M_address_WB;

    //inst
    //D_inst_D = F_inst_D;

    //addr_rd
    D_E_addr_rd_WB <= 0;//nop
    D_M_addr_rd_WB <= D_E_addr_rd_WB;
    D_WB_addr_rd_WB <= D_M_addr_rd_WB;

    //addr_rs1
    D_E_addr_rs1_E <= 0;

    //addr_rs2
    D_E_addr_rs2_E <= 0;
    D_M_addr_rs2_E <= D_E_addr_rs2_E;

    //imm
    D_E_imm_E <= 0;
    
    //shamt
    D_E_shamt_E = 0;

    //b_sel
    D_E_b_sel_E <= 0;

    //alu_sel
    D_E_alu_sel_E <= 0;

    //pc_reg1_sel
    D_E_pc_reg1_sel_E <= 0;

    //pc_jump
    D_E_pc_jump_F <= 0;
    D_M_pc_jump_F <= D_E_pc_jump_F;
    D_WB_pc_jump_F <= D_M_pc_jump_F;
    D_F_pc_jump_F <= D_WB_pc_jump_F;

    //rs2_shamt_sel
    D_E_rs2_shamt_sel_E <= 0;

    //unsign
    D_E_unsign_E <= 0;

    // wb_sel
    D_E_wb_sel_WB <= 0;
    D_M_wb_sel_WB <= D_E_wb_sel_WB;
    D_WB_wb_sel_WB <= D_M_wb_sel_WB;

    //write_enable
    D_E_write_enable_WB <= 0;
    D_M_write_enable_WB <= D_E_write_enable_WB;
    D_WB_write_enable_WB <= D_M_write_enable_WB;

    //d_rw
    D_E_d_rw_M <= 0;
    D_M_d_rw_M <= D_E_d_rw_M;

    // data_rs2
    D_E_data_rs2_M <= 0;
    D_M_data_rs2_M <= D_E_data_rs2_M;

    //data_rs1
    D_E_data_rs1_E <= 0;

    //alu_out 
    E_M_alu_out_WB_F <= E_alu_out_M_WB_F;
    E_WB_alu_out_F <= E_M_alu_out_WB_F;
    E_F_alu_out_F <= E_WB_alu_out_F;

    //data_r
    M_WB_data_r_WB <= M_data_r_WB;

    //brn_tkn
    E_M_brn_tkn_F <= E_brn_tkn_F;
    E_WB_brn_tkn_F <= E_M_brn_tkn_F;
    E_F_brn_tkn_F <= E_WB_brn_tkn_F;

    //brn_enable
    D_E_brn_enable_E <= 0;

    //brn_signal
    D_E_brn_signal_E <= 0;

    //data_rd
    WB_F_data_rd_D <= WB_data_rd_D;
    WB_D_data_rd_D <= WB_F_data_rd_D;
    

    //access_size
    D_E_access_size_M_WB <= 0;
    D_M_access_size_WB <= D_E_access_size_M_WB;
    D_WB_access_size_WB <= D_M_access_size_WB;

  end
end

/////////////////

//pc counter
// pc_counter pc (
//   .clock(clock),
//   .reset(reset),
//   .alu(E_WB_alu_out_F),
//   .PC_sel((D_WB_pc_jump_F || E_WB_brn_tkn_F)),
//   .pc(F_address_E_WB)
// );

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
    .inst(D_inst_D),
    // .br_eq(E_br_eq_D),  // will be refactored 
    // .br_lt(E_br_lt_D),  // will be refactored

    .opcode(opcode),
    .rd(D_addr_rd_WB),
    .rs1(D_addr_rs1_E),
    .rs2(D_addr_rs2_E),
    .funct3(funct3),
    .funct7(funct7),
    .imm(D_imm_E),
    .shamt(D_shamt_E),

    .b_sel(D_b_sel_E),
    .pc_reg1_sel(D_pc_reg1_sel_E),
    .rs2_shamt_sel(D_rs2_shamt_sel_E),

    .alu_sel(D_alu_sel_E),
    
    .pc_jump(D_pc_jump_F),
    .unsign(D_unsign_E),
    .brn_control(D_brn_signal_E),
    .brn_enable(D_brn_enable_E),

    .d_RW(D_d_rw_M),

    .WB_sel(D_wb_sel_WB),
    .write_back(D_write_enable_WB)
    
);

register_file reg_file(
  .clock(clock),

  .addr_rs1(D_addr_rs1_E),
  .data_rs1(D_data_rs1_E),

  .addr_rs2(D_addr_rs2_E),
  .data_rs2(D_data_rs2_E_M),

  .addr_rd(D_WB_addr_rd_WB),
  .data_rd(WB_data_rd_D),
  .write_enable(D_WB_write_enable_WB)

);
//EXCUTE 

branch_control brn_cntr(
    .enable(D_E_brn_enable_E),
    .eq_or_lt(D_E_brn_signal_E),
    .br_eq(br_eq),
    .br_lt(br_lt),
    .br_tk(E_brn_tkn_F)
);

branch_comp brn_cmpr(
    .in_a(D_E_data_rs1_E),
    .in_b(D_E_data_rs2_M),
    .unsign(D_E_unsign_E),
    .br_eq(br_eq),
    .br_lt(br_lt)
);

/*
 this is needed for the input for alu as there is a lot of endcases
*/
bypass_excute by_exc(
  //address of reg
  .rs1_decode(D_E_addr_rs1_E),
  .rs2_decode(D_E_addr_rs2_E),
  .rd_memory((D_M_write_enable_WB) ? D_M_addr_rd_WB : 0),
  .rd_write_back((D_WB_write_enable_WB)?D_WB_addr_rd_WB: 0),

  //values in regs
  .rs1_data_decode(D_E_data_rs1_E),
  .rs2_data_decode(D_E_data_rs2_M),
  .rd_data_memory(E_M_alu_out_WB_F),
  .rd_data_write_back(WB_data_rd_D),

  //other possible inputs
  .pc(F_address_E_WB),
  .imm(D_E_imm_E),
  .shamt({{27{1'b0}},D_E_shamt_E}),

  //control sigs
  .pc_reg1_sel(D_E_pc_reg1_sel_E),
  .imm_rs2_shamt_sel({D_E_b_sel_E,D_E_rs2_shamt_sel_E}),

  //outputs
  .rs1_data_out(in_a),
  .rs2_data_out(in_b)

);

ALU alu(
  .in_a(in_a),
  .in_b(in_b),
  .control(D_E_alu_sel_E),
  .out(E_alu_out_M_WB_F)
);

//Dmemory

dmemory d_mem(
  .address(E_M_alu_out_WB_F),
  .read_write(D_M_d_rw_M),
  .data_in((D_WB_write_enable_WB && (D_M_addr_rs2_E == D_WB_addr_rd_WB)) ? WB_data_rd_D : D_M_data_rs2_M),
  .access_size(D_E_access_size_M_WB),
  .data_out(M_data_r_WB)
);


//WRITE BACK
write_back w_back(
  .pc(F_M_address_WB),
  .alu(E_WB_alu_out_F),
  .data_r(
    (D_WB_access_size_WB == 0) ? ({{24{1'b0}}, M_WB_data_r_WB[7:0]}):
    (D_WB_access_size_WB == 1) ? ({{16{1'b0}}, M_WB_data_r_WB[15:0]}):
                        M_WB_data_r_WB
    ),
  .WB_sel(D_WB_wb_sel_WB),
  .wb(WB_data_rd_D)
);

endmodule