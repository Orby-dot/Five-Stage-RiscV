
/* Your Code Below! Enable the following define's 
 * and replace ??? with actual wires */
// ----- signals -----
// You will also need to define PC properly
`define F_PC                F_address_E_WB
`define F_INSN              F_inst_D

`define D_PC                F_D_address_E_WB
`define D_OPCODE            opcode
`define D_RD                D_addr_rd_WB
`define D_RS1               D_addr_rs1_E
`define D_RS2               D_addr_rs2_E
`define D_FUNCT3            funct3
`define D_FUNCT7            funct7
`define D_IMM               D_imm_E
`define D_SHAMT             D_shamt_E

`define R_WRITE_ENABLE      write_enable
`define R_WRITE_DESTINATION D_WB_addr_rd_WB
`define R_WRITE_DATA        WB_D_data_rd_D
`define R_READ_RS1          D_addr_rs1_E
`define R_READ_RS2          D_addr_rs2_E
`define R_READ_RS1_DATA     D_data_rs1_E
`define R_READ_RS2_DATA     D_data_rs2_E_M

`define E_PC                F_E_address_WB
`define E_ALU_RES           E_alu_out_M_WB_F
`define E_BR_TAKEN          D_E_brn_enable_E

`define M_PC                F_M_address_WB
`define M_ADDRESS           E_M_alu_out_WB_F
`define M_RW                D_M_d_rw_M
`define M_SIZE_ENCODED      D_M_access_size_WB
`define M_DATA              M_data_r_WB

`define W_PC                F_WB_address_WB
`define W_ENABLE            D_WB_wb_sel_WB
`define W_DESTINATION       D_WB_addr_rd_WB
`define W_DATA              WB_data_rd_D

// ----- signals -----

// ----- design -----
`define TOP_MODULE                 pd
// ----- design -----
