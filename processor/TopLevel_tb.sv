// Create Date:   2017.01.25
// Design Name:   TopLevel Test Bench
// Module Name:   TopLevel_tb.v
// CSE141L
module TopLevel_tb;

timeunit 1ns;
timeprecision 1ps;

// To DUT Inputs
bit Reset = 1'b1;
bit Req;
bit Clk;

// From DUT Outputs
wire Ack;   // done flag

// Instantiate the Device Under Test (DUT)
TopLevel DUT (
    .Reset  (Reset),
    .Start  (Req ),
    .Clk    (Clk ),
    .Ack    (Ack )
);

// This is the important part of the testbench, where logic might be added
initial begin
    int i;
    int e;
    logic[8:0] parity;
    logic[8:0] given_parity;
    logic[3:0] error_pos;
    
    logic[11:1] c;
    logic[16:1] expected_encoding, calculated_encoding;

    logic[16:1] c2;
    logic[16:1] expected_message, calculated_message;
    
    // to comment out a program testing section remove the first / of
    // each section so that it shows (/*) instead of (//*)
    
    //* PROGRAM 1 TESTING //////////////////////////////////////////////////////
    // Includes:
    // - base case testing
    // - full coverage testing
    
    // BASE CASE TESTING
    // reset low to begin memory preparation
    #10 Reset = 'b0;

    // load memory in
    #10
    $readmemb("./program1", DUT.IR.ROM);
    $readmemb("./data_mem_1", DUT.DM1.Core);
    
    // start program and wait
    #10 Req = 'b1;
    #10 Req = 'b0;
    wait (Ack);

    // display results
    #10
    for(i=30; i<60; i+=2) begin
        #10
        $displayb(DUT.DM1.Core[i],"_", DUT.DM1.Core[i+1]);
    end

    $stop;

    // FULL COVERAGE TESTING
    c = 11'b0;
    e = 0;
    parity = 9'b0;

    // for every possible message
    while(c < 11'b11111111111) begin
        // reset low to begin memory preparation
        #10 Reset = 'b1;
        #10 Reset = 'b0;

        // load memory in
        $readmemb("./program1", DUT.IR.ROM);
        for(i=0; i<30; i+=2) begin
            DUT.DM1.Core[i]   = c[8:1];
            DUT.DM1.Core[i+1] = {5'b0, c[11:9]};
            c += 'b1;
        end
        c -= 15;

        // start program and wait
        #10 Req = 'b1;
        #10 Req = 'b0;
        wait (Ack);

        // check all values
        for(i=30; i<60; i+=2) begin
            #10
            parity[8] = ^c[11:5];
            parity[4] = ^{c[11:8], c[4:2]}; 
            parity[2] = ^{c[11:10], c[7:6], c[4:3], c[1]};
            parity[1] = ^{c[11], c[9], c[7], c[5:4], c[2:1]};
            parity[0] = ^{c, parity[8], parity[4], parity[2], parity[1]};
            
            // assemble output (data with parity embedded)
            expected_encoding = {c[11:5], parity[8], c[4:2], parity[4], c[1], parity[2], parity[1], parity[0]};
            calculated_encoding = {DUT.DM1.Core[i+1], DUT.DM1.Core[i]};
            if(expected_encoding != calculated_encoding) begin
                $displayb("Calculated encoding: ", calculated_encoding,
                " does not equal expected encoding: ", expected_encoding,
                " for message: ", c,
                " Parities:", parity[8], parity[4], parity[2], parity[1], parity[0]);
                e+=1;
            end

            c+='b1;
        end
    end

    $display("Finished full coverage testing program 1 with: ", e, " errors.");

    $stop;
    // FINISH PROGRAM 1 TESTING
    /////////////////////////////////////////////////////////////////////////*/

    //* PROGRAM 2 TESTING //////////////////////////////////////////////////////
    // Includes:
    // - base case testing
    // - full coverage testing

    // BASE CASE TESTING
    // reset low to begin memory preparation
    #10 Reset = 'b0;

    // load memory in
    #10
    $readmemb("./program2", DUT.IR.ROM);
    $readmemb("./data_mem_2", DUT.DM1.Core);
    
    // start program and wait
    #10 Req = 'b1;
    #10 Req = 'b0;
    wait (Ack);

    // display results
    #10
    for(i=0; i<30; i+=2) begin
        #10
        $displayb(DUT.DM1.Core[i],"_", DUT.DM1.Core[i+1]);
    end

    $stop;

    // FULL COVERAGE TESTING
    c2 = 16'b0;
    e = 0;
    parity = 9'b0;
    given_parity = 9'b0;

    // for every possible message (yes, this takes a while, but it's thorough)
    while(c2 < 16'b1111111111111111) begin
        // reset low to begin memory preparation
        #10 Reset = 'b1;
        #10 Reset = 'b0;

        // load memory in
        $readmemb("./program2", DUT.IR.ROM);
        for(i=30; i<60; i+=2) begin
            DUT.DM1.Core[i]   = c2[8:1];
            DUT.DM1.Core[i+1] = c2[16:9];
            c2 += 'b1;
        end
        c2 -= 15;

        // start program and wait
        #10 Req = 'b1;
        #10 Req = 'b0;
        wait (Ack);

        // check all values
        for(i=0; i<30; i+=2) begin
            #10
            parity[8] = ^c2[16:10];
            parity[4] = ^{c2[16:13], c2[8:6]};
            parity[2] = ^{c2[16:15], c2[12:11], c2[8:7], c2[4]};
            parity[1] = ^{c2[16], c2[14], c2[12], c2[10], c2[8], c2[6], c2[4]};
            parity[0] = ^{c2[16:10], c2[8:6], c2[4], parity[8], parity[4], parity[2], parity[1]};

            given_parity = {c2[9], 3'b0, c2[5], 1'b0, c2[3:1]};
            error_pos = {parity[8]^given_parity[8], parity[4]^given_parity[4], parity[2]^given_parity[2], parity[1]^given_parity[1]};
            
            expected_encoding = c2;

            if(^expected_encoding) begin // if xor all bits of c2 gives 1, 1 error
                expected_message[16:12] = 5'b01000;
                expected_encoding[error_pos + 1] = !expected_encoding[error_pos + 1]; // invert error
            end
            else begin // else 0 or 2 errors
                if(parity == given_parity) expected_message[16:12] = 5'b0; // if parities are equal, no error
                else expected_message[16:12] = 5'b10000; // else, 2 errors and we give up
            end
            
            // assemble output (data with parity flags)
            expected_message[11:1] = {expected_encoding[16:10], expected_encoding[8:6], expected_encoding[4]};
            calculated_message = {DUT.DM1.Core[i+1], DUT.DM1.Core[i]};

            if(expected_message[16:12] == 5'b10000) begin
                if(calculated_message[16:12] != 5'b10000) begin
                    $displayb("Calculated message: ", calculated_message,
                    " does not equal expected message: ", expected_message,
                    " for message: ", c2,
                    " due to incorrect 2 bit error flagging",
                    " Given parities: ", given_parity[8], given_parity[4], given_parity[2], given_parity[1], given_parity[0],
                    " Expected parities: ", parity[8], parity[4], parity[2], parity[1], parity[0]);
                    e+=1;
                end
            end
            else if(expected_message != calculated_message) begin
                $displayb("Calculated message: ", calculated_message,
                " does not equal expected message: ", expected_message,
                " for encoded message: ", c2,
                " corrected to: ", expected_encoding,
                " Given parities: ", given_parity[8], given_parity[4], given_parity[2], given_parity[1], given_parity[0],
                " Expected parities: ", parity[8], parity[4], parity[2], parity[1], parity[0]);
                e+=1;
            end

            c2+='b1;
        end
    end

    $display("Finished full coverage testing program 2 with: ", e, " errors.");

    $stop;
    // FINISH PROGRAM 2 TESTING
    /////////////////////////////////////////////////////////////////////////*/
    
    //* PROGRAM 3 TESTING //////////////////////////////////////////////////////
    // Includes:
    // - 2 base case testing
    // - 2 more cases testing

    // BASE CASE TESTING
    // reset low to begin memory preparation
    #10 Reset = 'b0;

    // load memory in
    #10
    $readmemb("./program3", DUT.IR.ROM);
    $readmemb("./data_mem_3", DUT.DM1.Core);
    
    // start program and wait
    #10 Req = 'b1;
    #10 Req = 'b0;
    wait (Ack);

    // check values
    if(DUT.DM1.Core[33] != 128) $display("Within bounds count incorrect, expected 128 but got ", DUT.DM1.Core[33]);
    if(DUT.DM1.Core[34] != 32)  $display("Bytes count incorrect, expected 32 but got ", DUT.DM1.Core[34]);
    if(DUT.DM1.Core[35] != 252) $display("Without bounds count incorrect, expected 252 but got ", DUT.DM1.Core[35]);

    $display("Finished first base case testing program 3, Within bounds count: ", DUT.DM1.Core[33], " | Bytes Count: ", DUT.DM1.Core[34], " | Without bounds count: ", DUT.DM1.Core[35]);

    $stop;

    // BASE CASE v2 TESTING
    // reset low to begin memory preparation
    #10 Reset = 'b0;

    // load memory in
    #10
    $readmemb("./program3", DUT.IR.ROM);
    $readmemb("./data_mem_3a", DUT.DM1.Core);
    
    // start program and wait
    #10 Req = 'b1;
    #10 Req = 'b0;
    wait (Ack);

    // check values
    if(DUT.DM1.Core[33] != 0) $display("Within bounds count incorrect, expected 0 but got ", DUT.DM1.Core[33]);
    if(DUT.DM1.Core[34] != 0)  $display("Bytes count incorrect, expected 0 but got ", DUT.DM1.Core[34]);
    if(DUT.DM1.Core[35] != 0) $display("Without bounds count incorrect, expected 0 but got ", DUT.DM1.Core[35]);

    $display("Finished 2nd base case testing program 3, Within bounds count: ", DUT.DM1.Core[33], " | Bytes Count: ", DUT.DM1.Core[34], " | Without bounds count: ", DUT.DM1.Core[35]);

    $stop;

    // CASE 1 TESTING
    // reset low to begin memory preparation
    #10 Reset = 'b0;

    // load memory in
    #10
    $readmemb("./program3", DUT.IR.ROM);
    $readmemb("./data_mem_3b", DUT.DM1.Core);
    
    // start program and wait
    #10 Req = 'b1;
    #10 Req = 'b0;
    wait (Ack);

    // check values
    if(DUT.DM1.Core[33] != 32) $display("Within bounds count incorrect, expected 32 but got ", DUT.DM1.Core[33]);
    if(DUT.DM1.Core[34] != 32)  $display("Bytes count incorrect, expected 32 but got ", DUT.DM1.Core[34]);
    if(DUT.DM1.Core[35] != 32) $display("Without bounds count incorrect, expected 32 but got ", DUT.DM1.Core[35]);

    $display("Case 1 testing program 3, Within bounds count: ", DUT.DM1.Core[33], " | Bytes Count: ", DUT.DM1.Core[34], " | Without bounds count: ", DUT.DM1.Core[35]);

    $stop;

    // CASE 2 TESTING
    // reset low to begin memory preparation
    #10 Reset = 'b0;

    // load memory in
    #10
    $readmemb("./program3", DUT.IR.ROM);
    $readmemb("./data_mem_3c", DUT.DM1.Core);
    
    // start program and wait
    #10 Req = 'b1;
    #10 Req = 'b0;
    wait (Ack);

    // check values
    if(DUT.DM1.Core[33] != 16) $display("Within bounds count incorrect, expected 16 but got ", DUT.DM1.Core[33]);
    if(DUT.DM1.Core[34] != 16)  $display("Bytes count incorrect, expected 16 but got ", DUT.DM1.Core[34]);
    if(DUT.DM1.Core[35] != 32) $display("Without bounds count incorrect, expected 32 but got ", DUT.DM1.Core[35]);

    $display("Case 1 testing program 3, Within bounds count: ", DUT.DM1.Core[33], " | Bytes Count: ", DUT.DM1.Core[34], " | Without bounds count: ", DUT.DM1.Core[35]);

    $stop;
    // FINISH PROGRAM 3 TESTING
    /////////////////////////////////////////////////////////////////////////*/
end

// This generates the system clock
always begin   // clock period = 10 Verilog time units
    #5 Clk = 1'b1;
    #5 Clk = 1'b0;
end

endmodule
