
module control (
    //input wire inst_rdy,
    input wire [31:0]   inst,
    input wire         br_eq,
    input wire         br_lt,

    output reg [6:0]   opcode,
    output reg [4:0]   rd,
    output reg [4:0]   rs1,
    output reg [4:0]   rs2,
    output reg [2:0]   funct3,
    output reg [6:0]   funct7,
    output reg [31:0]  imm,
    output reg [4:0]   shamt,

    output reg         b_sel,         //0 if rs2, 1 if imm
    output reg [3:0]   alu_sel,
    output reg         pc_reg1_sel,    //0 if rs1, 1 is pc 
    output reg         brn_tkn,   
    output reg         rs2_shamt_sel, //0 if rs2, 1 if shamt

    output reg         unsign,
    //output reg [1:0]   access_size,//0 = 1 byte, 1 = half-word, 2 = fullword

    output reg [1:0]   WB_sel,  // 0 = mem, 1= alu, 2 = pc+4
    output reg         write_back, //if we should write back to reg file

    output reg         d_RW //1 = write

);

assign opcode = inst[6:0];
assign rd =     inst[11:7];
assign rs1 =    inst[19:15];
assign rs2 =    inst[24:20];
assign funct3 = inst[14:12];
assign funct7 = inst[31:25];
assign shamt =  inst[24:20];
assign unsign = funct3[1];

always @(inst) begin 
    if(((opcode & 7'b100_0000) == 64) && ((~opcode & 7'b001_0100) == 20 ))begin
        //B
        // if(inst != 0) begin
        //     $display ("IN B FORMAT %D",inst);
        // end

        imm = {{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};

        b_sel = 1'b1; //use imm
        alu_sel = 0; //add
        pc_reg1_sel = 1; //want to add to the pc
        rs2_shamt_sel=0;
        WB_sel = 0; //doesn't matter
        write_back = 0;//no write to regfile
        d_RW = 0;//don't need to write

        //for branch compare
        case ({funct3[2],funct3[0]})
            2'b00: brn_tkn = br_eq;
            2'b01: brn_tkn = ~br_eq;
            2'b10: brn_tkn = br_lt;
            2'b11: brn_tkn = ~br_lt;
        endcase 

    end
    else if(((opcode & 7'b001_0100) ==20) && ((~opcode & 7'b100_0000) == 64 ))begin
        //U
        // if(inst != 0) begin
        //     $display ("IN U FORMAT %D",inst);
        // end
        imm ={inst[31],inst[30:20],inst[19:12],{12{1'b0}}};
        b_sel = 1'b1;//use imm
        alu_sel = 0; //add

        pc_reg1_sel = ~opcode[5];// auipc 
        brn_tkn = 0;
        rs2_shamt_sel = 0;
        WB_sel = 1;//alu
        write_back = 1; //write back to regfile
        d_RW =0;//don't need to write

    end

    else if(((opcode & 7'b100_1100) == 76) && ((~opcode & 7'b001_0000) == 16 )) begin
        //J
        // if(inst != 0) begin
        //     $display ("IN J FORMAT %D",inst);
        // end
        imm =({{12{inst[31]}}, inst[19:12], inst[20],inst[30:25],inst[24:21],1'b0})<<1;
        b_sel = 1'b1;//use imm
        alu_sel = 0;//add
        pc_reg1_sel = 1;//select pc
        brn_tkn = 1;
        rs2_shamt_sel=0;
        WB_sel = 2; //select pc to write back
        write_back = 1;//no write to regfile
        d_RW = 0;//dont need to write
    end

    else if(((opcode[6:4] & 3'b010) ==2) && ((~opcode[6:4] & 3'b101) == 5 )) begin
        //s
        // if(inst != 0) begin
        //     $display ("IN S FORMAT %D",inst);
        // end
        imm ={{21{inst[31]}},inst[30:25],inst[11:8],inst[7]};
        b_sel = 1'b1; //use imm
        alu_sel = 0; //add
        pc_reg1_sel = 0;
        brn_tkn = 0;
        rs2_shamt_sel =0;
        WB_sel = 0; //doesn't matter
        write_back = 0;//no write to regfile
        d_RW = 1;//need to write
    end

    else if((opcode[6:4] & 3'b111) == 7)begin
        //ecal
        imm= {32{1'b0}};
        b_sel = 1'b0;
        alu_sel = 0 ; //add
        pc_reg1_sel = 0;
        brn_tkn =0;
        rs2_shamt_sel = 0;
        WB_sel = 0;// doesn't matter
        write_back = 0;//no write to regfile
        d_RW = 0 ; //dont need to write
    end
    else begin
        //i & R
        // if(inst != 0) begin
        //     $display ("IN I FORMAT %D",inst);
        // end
        imm = {{21{inst[31]}},inst[30:25],inst[24:21],inst[20]};
        //bsel
        b_sel = (!opcode[5] | opcode[6]);
        write_back = 1;//write to regfile
        d_RW = 0; //don't need to write to dmem
        //xx1xxxx
        if(!opcode[4])begin
            alu_sel = 0;//add
            rs2_shamt_sel = 0;
        end
        //xx0xxxx 
        else begin
            alu_sel = {(~opcode[5]&(funct3[0])&funct7[5]),funct3}; //control bits for alu
            rs2_shamt_sel = (funct3[0]) && ~(funct3[1] & funct3[2]);
        end
    
        pc_reg1_sel = 0;
        

        //for wb sel
        //1xxxxxx
        if(opcode[6]) begin
            WB_sel = 2;// pc+4
            brn_tkn= 1;//want to jump
        end
        //xx1xxxx
        else if(opcode[4]) begin
            WB_sel = 1;//alu
            brn_tkn= 0;
        end
        else begin
            WB_sel = 0; //mem
            brn_tkn= 0;
        end

    end
end

endmodule


