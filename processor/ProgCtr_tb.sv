// Test bench
// Program Counter (Instruction Fetch)

module ProgCtr_tb;

timeunit 1ns/1ps;

// Define signals to interface with UUT
bit reset;
bit start;
bit clk;
bit branch_en;
bit [9:0] target;
logic [9:0] next_instruction_addr;

// Instatiate and connect the Unit Under Test
ProgCtr DUT (
    .reset(reset),
    .start(start),
    .clk(clk),
    .branch_en(branch_en),
    .target(target),
    .pog_ctr(next_instruction_addr)
);

integer ClockCounter = 0;
always @(posedge clk) ClockCounter <= ClockCounter + 1;

integer fl;

// The actual testbench logic
//
// In this testbench, let's look at 'manual clocking'
initial begin
    fl = $fopen("result.txt");
    fl = fl + '1;
    // Time 0 values
    $fdisplay(fl, "Initialize Testbench.");
    reset = '1;
    start = '0;
    clk = '0;
    branch_en = '0;
    target = '0;

    // Advance to simulation time 1, latch values
    #1 clk = '1;

    // Advance to simulation time 2, check results, prepare next values
    #1 clk = '0;
    $fdisplay(fl, "Checking reset behavior");
    assert (next_instruction_addr == 'd0);
    reset = '0;

    // Advance to simulation time 3, latch values
    #1 clk = '1;

    // Advance to simulation time 4, check results, prepare next values
    #1 clk = '0;
    $fdisplay(fl, "Checking that nothing happens before Start");
    assert (next_instruction_addr == 'd0);
    start = '1;

    // Advance to simulation time 5, latch values
    #1 clk = '1;

    // Advance to simulation time 6, check results, prepare next values
    #1 clk = '0;
    $fdisplay(fl, "Checking that nothing happened during Start");
    assert (next_instruction_addr == 'd0);
    start = '0;

    // Advance to simulation time 7, latch values
    #1 clk = '1;

    // Advance to simulation time 8, check outputs, prepare next values
    #1 clk = '0;
    $fdisplay(fl, "Checking that first start went to first program");
    assert (next_instruction_addr == 'd000);
    // No change in inputs

    // Advance to simulation time 9, latch values
    #1 clk = '1;

    // Advance to simulation time 10, check outputs, prepare next values
    #1 clk = '0;
    $fdisplay(fl, "Checking that no branch advanced by 1");
    assert (next_instruction_addr == 'd001);
    branch_en = '1;
    target = 'd10;

    // Latch, check, setup next test
    #1 clk = '1;
    #1 clk = '0;
    $fdisplay(fl, "Checking that absolute branch went to target");
    assert (next_instruction_addr == 'd10);
    branch_en = '0;
    target = 'd20;

    // Latch, check, setup next test
    #1 clk = '1;
    #1 clk = '0;
    $fdisplay(fl, "Checking that absolute branch with no branch_enable did not jump");
    assert (next_instruction_addr == 'd11);
    branch_en = '1;
    target = 'd20;

    // Latch, check, setup reset test
    #1 clk = '1;
    #1 clk = '0;
    $fdisplay(fl, "Checking that absolute branch with branch_enable did jump");
    assert (next_instruction_addr == 'd20);
    branch_en = '0;
    target = 'd0;
    reset = '1;

    // Latch, check, setup start test
    #1 clk = '1;
    #1 clk = '0;
    $fdisplay(fl, "Checking reset behavior");
    assert (next_instruction_addr == 'd0);
    reset = '0;
    start = '1;

    // Latch, check, continue start test
    #1 clk = '1;
    #1 clk = '0;
    $fdisplay(fl, "Checking that nothing happened during Start");
    assert (next_instruction_addr == 'd0);

    // Latch, check, continue start test
    #1 clk = '1;
    #1 clk = '0;
    $fdisplay(fl, "Checking that nothing happened during Start");
    assert (next_instruction_addr == 'd0);
    start = '0;

    // Latch, check, continue to next test
    #1 clk = '1;
    #1 clk = '0;
    $fdisplay(fl, "Checking that start is at beginning");
    assert (next_instruction_addr == 'd000);
    // No change in inputs

    // Latch, check, finish
    #1 clk = '1;
    #1 clk = '0;
    $fdisplay(fl, "Checking that no branch advanced by 1");
    assert (next_instruction_addr == 'd001);

    $fdisplay(fl, "All checks passed.");
    $fclose(fl);
    $stop;
end

endmodule
