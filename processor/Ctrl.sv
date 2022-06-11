// Project Name:   CSE141L
// Module Name:    Ctrl
// Create Date:    ?
// Last Update:    2022.01.13

// control decoder (combinational, not clocked)
// inputs from ... [instrROM, ALU flags, ?]
// outputs to ...  [program_counter (fetch unit), ?]
import Definitions::*;

module Ctrl (
    input  [8:0]    instruction,    // machine code
    input  logic    zero,           // status flags from CMP
                    less_than,
    output logic    branch_en,      // branch at all?
                    dest_reg,       // select dest reg source (r0 (0) or instruction reg(1))
                    alu_src,        // choose alu source (reg data (0) or immediate (1))
                    reg_write_en,   // write to reg file
                    mem_write_en,   // write to data mem
                    ctrl_ack_out,   // done with program?
    output logic [1:0] alu_mem_imm  // select what to write
);

logic i_type;
logic m_type;
logic r_type;
logic cmp_inst;
logic shift_inst;
logic break_inst;
logic store_inst;
logic load_inst;

assign i_type = instruction[8];
assign m_type = instruction[8:7] == 'b01;
assign r_type = instruction[8:7] == 'b00;
assign cmp_inst   = m_type && instruction[6] == 'b0;
assign mov_inst   = m_type && instruction[6] == 'b1;
assign shift_inst = r_type && ((instruction[6:3] == 'b0010) || (instruction[6:3] == 'b0011) || (instruction[6:3] == 'b1111));
assign break_inst = r_type && instruction[6:5] == 'b10;
assign store_inst = r_type && instruction[6:3] == 'b1100;
assign load_inst  = r_type && instruction[6:3] == 'b1101;

always_comb begin
    case(instruction[6:3])
        'b1000 : branch_en = break_inst && zero;        // break equal
        'b1001 : branch_en = break_inst && ~zero;       // break not equal
        'b1010 : branch_en = break_inst && less_than;   // break less than
        'b1011 : branch_en = break_inst;    // break
        default: branch_en = 'b0;           // don't break
    endcase
    dest_reg = m_type;      // 1 if M type instruction otherwise, always choose 0. this means it is typically input_b into the ALU
    alu_src  = shift_inst;  // only shift instructions
    reg_write_en = ~cmp_inst && ~break_inst && ~store_inst; // reg write turn off for cmp, breaks, and store instructions
    mem_write_en = store_inst;  // mem write only on for store instruction
    ctrl_ack_out = instruction === 9'b0; // when instruction bits are all 0
    alu_mem_imm  = {mov_inst || i_type, load_inst || i_type};
end

endmodule
