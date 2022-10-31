
/* Your Code Below! Enable the following define's 
 * and replace ??? with actual wires */
// ----- signals -----
// You will also need to define PC properly
`define F_PC                address
`define F_INSN              inst

`define D_PC                address
`define D_OPCODE            opcode
`define D_RD                addr_rd
`define D_RS1               addr_rs1
`define D_RS2               addr_rs2
`define D_FUNCT3            funct3
`define D_FUNCT7            funct7
`define D_IMM               imm
`define D_SHAMT             shamt

`define R_WRITE_ENABLE      write_enable
`define R_WRITE_DESTINATION addr_rd
`define R_WRITE_DATA        data_rd
`define R_READ_RS1          addr_rs1
`define R_READ_RS2          addr_rs2
`define R_READ_RS1_DATA     data_rs1
`define R_READ_RS2_DATA     data_rs2

`define E_PC                address
`define E_ALU_RES           alu_out
`define E_BR_TAKEN          brn_tkn

`define M_PC                address
`define M_ADDRESS           alu_out
`define M_RW                d_RW
`define M_SIZE_ENCODED      access_size
`define M_DATA              dmem_data_R

`define W_PC                address
`define W_ENABLE            write_enable
`define W_DESTINATION       addr_rd
`define W_DATA              data_rd

// ----- signals -----

// ----- design -----
`define TOP_MODULE                 pd
// ----- design -----
