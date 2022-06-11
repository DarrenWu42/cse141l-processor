// Module Name:    ALU
// Project Name:   CSE141L
//
// Additional Comments:
//   combinational (unclocked) ALU
import Definitions::*;

module ALU #(parameter W=8, Ops=4)(
  input [W-1:0] input_a,    // data inputs
                input_b,
  input [Ops-1:0] op,       // ALU opcode
  input op_cmp,             // ALU op compare
  output logic [W-1:0] out, // data output
  output logic zero,        // comparison outputs
            less_than
);

// type enum: used for convenient waveform viewing
op_mne op_mnemonic;
op_cmp_mne op_cmp_mnemonic;

always_comb begin
    out = 'b0;

    // these values are always set, but only CMP allows direct comparison of 2 regs
    zero = (input_a == input_b);
    less_than = (input_b < input_a);

    // input_b is typically register 0, so it should be the one that is "acted upon"
    if(!op_cmp) begin
        case(op)
            ADD : out = input_b + input_a;
            // in case of subtraction, we subtract from the input_a register since it is easy to set input_b
            SUB : out = input_a + (~input_b) + 8'b1;
            LSH : out = input_b << input_a;
            RSH : out = input_b >> input_a;
            XOR : out = input_b ^ input_a;
            AND : out = input_b & input_a;
            ORR : out = input_b | input_a;
            // calculate parity of passed in register
            PAR : out = ^input_a;
            TGB : begin
                out = input_b;
                out[input_a] = ~input_b[input_a];
            end
            ASR : out = input_b >>> input_a;
            default : out = input_a;
        endcase
    end
end

// displays operation name in waveform viewer
always_comb begin
    op_mnemonic = op_mne'(op);
    op_cmp_mnemonic = op_cmp_mne'(op_cmp);
end

endmodule
