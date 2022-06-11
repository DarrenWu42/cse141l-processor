// Design Name:      CSE141L
// Module Name:      TopLevel

// you will have the same 3 ports
module TopLevel(
  input        Reset,      // init/reset, active high
               Start,      // start next program
               Clk,        // clock -- posedge used inside design
  output logic Ack         // done flag from DUT
);

// ProgCtr outputs
wire  [9:0] pc_prog_ctr_out;    // the program counter

// InstROM outputs
wire  [8:0] ir_inst_out_out;    // the 9-bit opcode

// Control block outputs
logic       ctrl_branch_en_out;     // to program counter: branch enable
logic       ctrl_dest_reg_out;      // choose between r0 or other register
logic       ctrl_alu_src_out;       // choose between register data (0) or immediate (1)
logic       ctrl_reg_w_en_out;      // reg_file write enable
logic       ctrl_mem_w_en_out;      // data_memory write enable
logic       ctrl_ack_out;           // Done with program?
logic [1:0] ctrl_alu_mem_imm_out;   // choose alu, memory, or immediate

// Register file outputs
logic [7:0] rf_src_data_out;    // Contents of first selected register
logic [7:0] rf_dest_data_out;   // Contents of second selected register

// ALU outputs
logic [7:0] alu_out_out;
logic       alu_zero_out;
logic       alu_less_than_out;

// registers for ALU status outputs
reg zero_q;       // zero status register
reg less_than_q;  // less than status register

// Data Memory outputs
logic [7:0] dm_data_out_out;    // data out from data_memory

// MUXES
// selecting the correct destination register
logic [2:0] dest_reg_sel_out;   // dest_addr to reg file

// Output Mux deciding whether ALU, Memory, or Immediate result is used
logic [7:0] dest_reg_value_out; // data in to reg file

// Extras
//
// These are not really part of your processor per se, but can be
// useful for diagnostics or performance

logic[15:0] CycleCount; // Count the total number of clock cycles.


////////////////////////////////////////////////////////////////////////////////
// Fetch = Program Counter + Instruction ROM

// this is the program counter module
ProgCtr PC (
    .reset     (Reset),                 // reset to 0
    .start     (Start),                 // Your PC will have to do something smart with this
    .clk       (Clk),                   // System CLK
    .branch_en (ctrl_branch_en_out),    // branch enable
    .target    ({2'b00, rf_dest_data_out}),  // "where to?" or "how far?" during a jump or branch
    .pog_ctr   (pc_prog_ctr_out)        // program count = index to instruction memory
);

// instruction ROM -- holds the machine code pointed to by program counter
InstROM #(.W(9)) IR (
    .inst_addr  (pc_prog_ctr_out),
    .inst_out   (ir_inst_out_out)
);
/////////////////////////////////////////////////////////////////////// Fetch //



////////////////////////////////////////////////////////////////////////////////
// Decode = Control Decoder + Reg_file

// Control decoder
Ctrl Ctrl (
    .instruction  (ir_inst_out_out),        // from instr_ROM
    .zero         (zero_q),                 // status flags from CMP
    .less_than    (less_than_q),
    .branch_en    (ctrl_branch_en_out),     // to PC
    .dest_reg     (ctrl_dest_reg_out),      // choose between r0 or other register
    .alu_src      (ctrl_alu_src_out),       // choose between register data (0) or immediate (1)
    .reg_write_en (ctrl_reg_w_en_out),      // register file write enable
    .mem_write_en (ctrl_mem_w_en_out),      // data memory write enable
    .ctrl_ack_out (ctrl_ack_out),           // "done" flag
    .alu_mem_imm  (ctrl_alu_mem_imm_out)    // index into lookup table
);

// Register file
RegFile #(.W(8), .D(3)) RF (
    .clk        (Clk),
    .reset      (Reset),
    .write_en   (ctrl_reg_w_en_out),
    .src_addr   (ir_inst_out_out[2:0]),
    .dest_addr  (dest_reg_sel_out),
    .data_in    (dest_reg_value_out),
    .data_out_src   (rf_src_data_out),
    .data_out_dest  (rf_dest_data_out)
);

// mux to choose correct destination register for writing/comparison
assign dest_reg_sel_out = ctrl_dest_reg_out ? ir_inst_out_out[5:3] : 3'b0;

// Also need to hook up the signal back to the testbench for when we're done.
assign Ack = ctrl_ack_out;
////////////////////////////////////////////////////////////////////// Decode //



////////////////////////////////////////////////////////////////////////////////
// Execute + Memory = ALU + DataMem
//

// You can declare local wires if it makes sense, for instance
// if you need an local mux for the input
logic [ 7:0] input_a, input_b;      // ALU operand inputs

assign input_a = ctrl_alu_src_out ? ir_inst_out_out[2:0] : rf_src_data_out;     // select immediate or src reg data to ALU in
assign input_b = rf_dest_data_out;    // select dest reg data to ALU in

always @(posedge Clk) begin
    zero_q        <= ir_inst_out_out[8:6] == 'b010 ? alu_zero_out : zero_q;
    less_than_q   <= ir_inst_out_out[8:6] == 'b010 ? alu_less_than_out : less_than_q;
end

ALU ALU (
    .input_a  (input_a),
    .input_b  (input_b),
    .op       (ir_inst_out_out[6:3]),
    .op_cmp   (ir_inst_out_out[  7]),
    .out      (alu_out_out),
    .zero     (alu_zero_out),
    .less_than    (alu_less_than_out)
);


DataMem DM1 (
    .clk        (Clk),
    .reset      (Reset),
    .write_en   (ctrl_mem_w_en_out),
    .data_addr  (alu_out_out),          // lod and str default in alu so src reg is let trough
    .data_in    (rf_dest_data_out),
    .data_out   (dm_data_out_out)
);

// An output mux from this block, are we using the ALU result, the memory
// result, or the immediate this cycle? Controlled by Ctr
always_comb begin
    case(ctrl_alu_mem_imm_out)
        'b00 : dest_reg_value_out = alu_out_out;
        'b01 : dest_reg_value_out = dm_data_out_out;
        'b10 : dest_reg_value_out = rf_src_data_out;
        'b11 : dest_reg_value_out = ir_inst_out_out[7:0];
    endcase
end
//////////////////////////////////////////////////////////// Execute + Memory //



////////////////////////////////////////////////////////////////////////////////
// Extras

// count number of cycles executed
// not part of main design, potentially useful for performance measure...
// This one halts when Ack is high
always_ff @(posedge Clk)
  if (Reset)
    CycleCount <= 0;
  else if(ctrl_ack_out == 0)
    CycleCount <= CycleCount + 'b1;
////////////////////////////////////////////////////////////////////// Extras //
endmodule

