//To decode instru

//i am going to build this a bit more than we need for the future
/*
---------CONSTANTS------------
@NOTE: We will copy all of these values but we can decide not to use them per instuction
[RD]
rd = [11:7]

[R1]
rs1 = [19:15]

[RS2]
rs2 = [24:20]

[FUNCT3]
funct3 = [14:12]

[FUNCT7]
funct7 = [31:25]

[OPCODE]
opcode = [6:0]

[SHAMT]
shamt = [24:20]


---------TYPE-----------------
if 01100xx or 01100xx then R
if 11000xx then B
if 00000xx or 00100xx or 11001xx then I
if 11011xx or 011011 or 00111 then U
if 11100xx then ECALL
------------------------------

---------FOR R TYPE-----------

[BSEL]
if x1xxxxx then Bsel = 0 
else Bsel = 1

[REG W/E]
RegW/E = 1

[DMEM W/R]
DMEM W/R = R

[WBSEL]
WBSEL = 1

[PCSEL]
PCSel = 0

[ALU]
*To do later*

[IMM]
NONE
-------------------------------

---------FOR I TYPE-----------

[BSEL]
Bsel = 1

[REG W/E]
*

[DMEM W/R]
DMEM W/R = R

[WBSEL]
*

[PCSEL]
if 0xxxxxxx then PCSel = 0
else PCSel = 1

[ALU]
*To do later*

[IMM]
immsel = 2
-------------------------------

---------FOR J TYPE-----------

[BSEL]
Bsel = 1

[REG W/E]
RedW/E = 1

[DMEM W/R]
DMEM W/R = R

[WBSEL]
1

[PCSEL]
PCSel = 1

[ALU]
add

[IMM]
imm sel = 0
-------------------------------

---------FOR B TYPE-----------

[BSEL]
Bsel = 1

[REG W/E]
RedW/E = 0

[DMEM W/R]
DMEM W/R = R

[WBSEL]
1

[PCSEL]
*

[ALU]
add

[IMM]
imm sel = 3
-------------------------------
---------FOR U TYPE-----------

[BSEL]
Bsel = 1

[REG W/E]
RedW/E = 1

[DMEM W/R]
DMEM W/R = R

[WBSEL]
1

[PCSEL]
0

[ALU]
add

[IMM]
imm sel = 1
-------------------------------

---------FOR S TYPE-----------

[BSEL]
Bsel = 1

[REG W/E]
RedW/E = 0

[DMEM W/R]
DMEM W/R = W

[WBSEL]
doesnt matter

[PCSEL]
0

[ALU]
add

[IMM]
imm sel = 4
-------------------------------


*/

/*
NOTE: old garbage MAY NOT USE

 if x1xxxxx then reg2 is used: 
----------FOR DW/E------------
 if 010xxxxx then DW/E = Write
 -----------------------------

----------FOR PC SELECT-------
 if 0xxxxxxx then PC select is 0
    -> if not then need to do a compare/check
------------------------------


----------FOR IMM SEL---------
 if xx101xx then imm sel = 1
 if xx011xx then imm sel = 0

 if xx100xx then
    if funct3 = 001 or 101 imm sel = 5
    else immsel = 2

 if xx000xx then
    if 01000xx then imm sel 4
    if 00000xx then imm sel 2
    if 11000xx then imm sel 3
------------------------------


*/

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

    output reg         unsign

);

assign opcode = inst[6:0];
assign rd =     inst[11:7];
assign rs1 =    inst[19:15];
assign rs2 =    inst[24:20];
assign funct3 = inst[14:12];
assign funct7 = inst[31:25];
assign shamt =  inst[24:20];
assign unsign = funct3[1];

/*
wire unsign;
wire br_eq;
wire br_lt;

*/


/* don't need as we are doing it below
assign imm = (((opcode & 7'b100_0000) == 64) && ((~opcode & 7'b001_0100) == 20 ) ) ? {{20{inst[31]}},inst[11],inst[30:25],inst[11:8],1'b0}: //B
            (((opcode & 7'b001_0100) ==20) && ((~opcode & 7'b100_0000) == 64 ) ) ? {inst[31],inst[30:20],inst[19:12],{12{1'b0}}}://U
            (((opcode & 7'b100_0100) == 68) && ((~opcode & 7'b001_0000) == 16 )) ? {{12{inst[31]}}, inst[19:12], inst[20],inst[30:25],inst[24:21],1'b0}: //j
            (((opcode[6:4] & 3'b010) ==2) && ((~opcode[6:4] & 3'b101) == 5 )) ? {{21{inst[31]}},inst[30:25],inst[11:8],inst[7]}://s
            ((opcode[6:4] & 3'b111) == 7) ? {32{1'b0}}:// ecall
            {{21{inst[31]}},inst[30:25],inst[24:21],inst[20]} ;//i 
*/

// EXECUTE STAGE (combinational)
// is the immediate just 0 if we don't use it? 
// how can we detect the type of instruction we have rn?
always @(inst) begin 
    if(((opcode & 7'b100_0000) == 64) && ((~opcode & 7'b001_0100) == 20 ))begin
        //B

        imm = {{20{inst[31]}},inst[11],inst[30:25],inst[11:8],1'b0};

        b_sel = 1'b0; //use r2
        alu_sel = 0; //add
        pc_reg1_sel = 1; //want to add to the pc
        rs2_shamt_sel=0;


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
        imm ={inst[31],inst[30:20],inst[19:12],{12{1'b0}}};
        b_sel = 1'b1;//use imm
        alu_sel = 0; //add

        pc_reg1_sel = ~opcode[5];// auipc 
        brn_tkn = 0;
        rs2_shamt_sel = 0;

    end

    else if(((opcode & 7'b100_0100) == 68) && ((~opcode & 7'b001_0000) == 16 )) begin
        //J
        imm ={{12{inst[31]}}, inst[19:12], inst[20],inst[30:25],inst[24:21],1'b0};
        b_sel = 1'b1;//use imm
        alu_sel = 0;//add
        pc_reg1_sel = 1;//select pc
        brn_tkn = 1;
        rs2_shamt_sel=0;
    end

    else if(((opcode[6:4] & 3'b010) ==2) && ((~opcode[6:4] & 3'b101) == 5 )) begin
        //s
        imm ={{21{inst[31]}},inst[30:25],inst[11:8],inst[7]};
        b_sel = 1'b1; //use imm
        alu_sel = 0; //add
        pc_reg1_sel = 0;
        brn_tkn = 0;
        rs2_shamt_sel =0;
    end

    else if((opcode[6:4] & 3'b111) == 7)begin
        //ecal
        imm= {32{1'b0}};
        b_sel = 1'b0;
        alu_sel = 0 ; //add
        pc_reg1_sel = 0;
        brn_tkn =0;
        rs2_shamt_sel = 0;
    end
    else begin
        //i & R
        imm = {{21{inst[31]}},inst[30:25],inst[24:21],inst[20]};
        //bsel
        b_sel = (!opcode[5] | opcode[6]);
        //x1xxxxx
        if(!opcode[4])begin
            alu_sel = 0;//add
            rs2_shamt_sel = 0;
        end
        //xx0xxxx 
        else begin
            alu_sel = {funct7[5],funct3}; //control bits for alu
            rs2_shamt_sel = (funct3[0] && ~(funct3[1] & funct3[2]));
        end

        pc_reg1_sel = 0;
        brn_tkn= 0;

    end
end
// add vs sub there's just inst[30] that's different

// funct3 = 000 =>      (~(1 && funct3))
// funct3 = 001 =>      ( (~(funct3[2] || funct3[1])) && funct3[0] )
// funct3 = 010 =>      ( (~(funct3[2] || funct3[0])) && funct3[1] )
// funct3 = 011 =>      ( (funct3[1] && funct3[0]) && ~funct3[2] )
// funct3 = 100 =>      ( (~(funct3[1] || funct3[0])) && funct3[2] )
// funct3 = 101 =>      ( (funct3[2] && funct3[0]) && ~funct3[1] )
// funct3 = 110 =>      ( (funct3[2] && funct3[1]) && ~funct3[0] )
// funct3 = 111 =>      ( funct3[2] && funct3[1] && funct3[0] )


endmodule


