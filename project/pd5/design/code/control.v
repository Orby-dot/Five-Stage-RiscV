/*
This will exist in DECODE
Will generate all signals 
NOTE TO SELF WILL NEED AN OR IN PD FOR BRK TKN!!!!!!
*/
module control (
    input wire [31:0]   inst,

    //probes
    output wire [6:0]   opcode,
    output wire [4:0]   rd,
    output wire [4:0]   rs1,
    output wire [4:0]   rs2,
    output wire [2:0]   funct3,
    output wire [6:0]   funct7,
    output reg [31:0]  imm,
    output wire [4:0]   shamt,

    //control signals
        //Reg signals
    output reg         b_sel,         //0 if rs2, 1 if imm
    output reg         pc_reg1_sel,    //0 if rs1, 1 is pc 
    output reg         rs2_shamt_sel, //0 if rs2, 1 if shamt
        //alu
    output reg [3:0]   alu_sel,
        //branch
    output reg         pc_jump,   //forces pc to jump to what alu calculates
    output wire         unsign,
    output reg [1:0]   brn_control, //tells brn control which branch to take
    output reg         brn_enable, //if 1 = enables brk_tk to be 1 if branch is taken
        //memory
    output reg         d_RW, //1 = write
        //write back
    output reg [1:0]   WB_sel,  // 0 = mem, 1= alu, 2 = pc+4
    output reg         write_back //if we should write back to reg file

);

//hardcode assigns, they do not change with type :D
assign opcode = inst[6:0];
assign rd =     inst[11:7];
assign rs1 =    inst[19:15];
assign rs2 =    inst[24:20];
assign funct3 = inst[14:12];
assign funct7 = inst[31:25];
assign shamt =  inst[24:20];
assign unsign = funct3[1];

//This can be always @(*) but this is more clear
always @(inst) begin 
    //1xx0x0xx
    //B type
    if(((opcode & 7'b100_0000) == 64) && ((~opcode & 7'b001_0100) == 20 ))begin

        imm = {{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};

        //reg select
        b_sel = 1'b1; //use imm instead of rs2
        pc_reg1_sel = 1; //want to add to the pc
        rs2_shamt_sel=0; //DC

        //excute
        alu_sel = 0; //add
        brn_control = {funct3[2],funct3[0]};//get code
        brn_enable = 1;//turn on brn control
        pc_jump = 0;

        //memory
        d_RW = 0;//don't need to write

        //writeback
        WB_sel = 0; //doesn't matter
        write_back = 0;//no write to regfile

    end
//----------------------------------------------------------------------------------------------//
    //0xx1x1xx
    //U type
    else if(((opcode & 7'b001_0100) ==20) && ((~opcode & 7'b100_0000) == 64 ))begin
        imm ={inst[31],inst[30:20],inst[19:12],{12{1'b0}}};

        //reg select
        b_sel = 1'b1;//use imm instead of rs2
        pc_reg1_sel = ~opcode[5];// auipc 
        rs2_shamt_sel = 0; //DC

        //excute
        alu_sel = 0; //add
        brn_enable = 0; //Don't need branch
        brn_control = 0;//DC
        pc_jump = 0;

        //memory
        d_RW =0;//don't need to write

        //write back
        WB_sel = 1;//alu
        write_back = 1; //write back to regfile

    end
//----------------------------------------------------------------------------------------------//
    //1x011xx
    //J type
    else if(((opcode & 7'b100_1100) == 76) && ((~opcode & 7'b001_0000) == 16 )) begin
        imm =({{12{inst[31]}}, inst[19:12], inst[20],inst[30:25],inst[24:21],1'b0});

        //reg select
        b_sel = 1'b1;//use imm
        pc_reg1_sel = 1;//select pc
        rs2_shamt_sel=0;

        //excute
        alu_sel = 0;//add
        pc_jump = 1;
        brn_enable = 0; //Don't need branch
        brn_control = 0;//DC

        //memory
        d_RW = 0;//dont need to write

        //write back
        WB_sel = 2; //select pc to write back
        write_back = 1;//no write to regfile
        
    end
//----------------------------------------------------------------------------------------------//
    //010xxxx
    //S type
    else if(((opcode[6:4] & 3'b010) ==2) && ((~opcode[6:4] & 3'b101) == 5 )) begin
        imm ={{21{inst[31]}},inst[30:25],inst[11:8],inst[7]};

        //reg select
        b_sel = 1'b1; //use imm nstead of rs2
        pc_reg1_sel = 0; //use rs1
        rs2_shamt_sel =0; //DC

        //excute
        alu_sel = 0; //add
        pc_jump = 0;
        brn_enable = 0; //Don't need branch
        brn_control = 0;//DC

        //memory 
         d_RW = 1;//need to write

        //write back
        WB_sel = 0; //doesn't matter
        write_back = 0;//no write to regfile
       
    end
//----------------------------------------------------------------------------------------------//
    //111xxx
    //ECALL
    else if((opcode[6:4] & 3'b111) == 7)begin

        imm= {32{1'b0}};

        //reg select
        b_sel = 1'b0;
        pc_reg1_sel = 0;
        rs2_shamt_sel = 0;

        //excute
        alu_sel = 0 ; //add
        pc_jump =0;
        brn_enable = 0; //Don't need branch
        brn_control = 0;//DC

        //memory
        d_RW = 0 ; //dont need to write
        
        //write back
        WB_sel = 0;// doesn't matter
        write_back = 0;//no write to regfile
        
    end
//----------------------------------------------------------------------------------------------//
    //I ad R type
    else begin

        imm = {{21{inst[31]}},inst[30:25],inst[24:21],inst[20]};

        //reg select
        b_sel = ((!opcode[5] | opcode[6])&&~(opcode[4] && funct3[0] &&~funct3[1]));
        pc_reg1_sel = 0;
        //rs2/shmat and alu sel
        //xx0xxxx
        if(!opcode[4])begin
            alu_sel = 0;//add
            rs2_shamt_sel = 0;
        end
        //xx1xxxx 
        else begin
            alu_sel = {((~opcode[5] && (((funct7[5]) && funct3 == 3'b101)|| funct3 == 3'b011))||(opcode[5] && ~funct3[0] && funct7[5])), funct3}; //control bits for alu
            rs2_shamt_sel = (funct3[0]) && ~(funct3[1] & funct3[2]);
        end

        //memory
        d_RW = 0; //don't need to write to dmem

        //write back and brtk
        write_back = 1;//write to regfile

        brn_enable = 0; //Don't need branch
        brn_control = 0;//DC

        //for wb sel and brtk
        //1xxxxxx
        //for jalr
        if(opcode[6]) begin
            WB_sel = 2;// pc+4
            pc_jump= 1;//want to jump
        end
        //xx1xxxx
        else if(opcode[4]) begin
            WB_sel = 1;//alu
            pc_jump= 0;
        end
        else begin
            WB_sel = 0; //mem
            pc_jump= 0;
        end

    end
end

endmodule


