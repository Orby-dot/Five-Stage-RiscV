
/* Your Code Below! Enable the following define's 
 * and replace ??? with actual wires */
// ----- signals -----
// You will also need to define PC properly
`define F_PC                address
`define F_INSN              data_out

`define D_PC                address
`define D_OPCODE            opcode
`define D_RD                rd
`define D_RS1               rs1
`define D_RS2               rs2
`define D_FUNCT3            funct3
`define D_FUNCT7            funct7
`define D_IMM               imm
`define D_SHAMT             shamt

`define R_WRITE_ENABLE      write_enable
`define R_WRITE_DESTINATION ???
`define R_WRITE_DATA        data_rd
`define R_READ_RS1          ???
`define R_READ_RS2          ???
`define R_READ_RS1_DATA     data_rs1
`define R_READ_RS2_DATA     data_rs2

`define E_PC                ???
`define E_ALU_RES           ???
`define E_BR_TAKEN          ???

// ----- signals -----

// ----- design -----
`define TOP_MODULE                 pd
// ----- design -----
