// Project Name:   CSE141L
// Module Name:    ProgCtr
// Description:    instruction fetch (pgm ctr) for processor

// Parameters:
//  A: Number of address bits in instruction memory
module ProgCtr #(parameter A=10)(
    input reset,            // reset, init, etc. -- force PC to 0
            start,          // begin next program in series (request issued by test bench)
            clk,            // PC can change on pos. edges only
            branch_en,      // jump unconditionally to Target value
    input [A-1:0] target,   // jump ... "how high?"
    output logic [A-1:0] pog_ctr  // the program counter register itself
);

logic starting;
logic running;

always_ff @(posedge clk) begin
    // starting always stores previous start
    starting <= start;

    // reset program counter and states to 0
    if(reset) begin
        pog_ctr <= '0;
        running <= '0;
    end
    // on downedge of start
    else if(starting && ~start) running <= '1; // put running into high
    // if branch enabled and running and not start
    else if(running && branch_en) pog_ctr <= target;    // conditional absolute jump
    // if running and not start
    else if(running) pog_ctr <= pog_ctr+'b1;    // default increment
    // else do nothing
    else pog_ctr <= pog_ctr;
end

endmodule
