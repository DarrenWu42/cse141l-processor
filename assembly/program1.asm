// r1 stores source address to encode
SET d1
MOV r1, r0

// r2 stores encoded destination address
SET d31
MOV r2, r0

// for 1 to 29 skipping by 2
.LOOP:
    // load bytes from memory
    LOD r1      // load high byte from address in r1 into r0
    MOV r4, r0  // move high byte from r0 to r4

        // sub 1 from r1
    SET d1
    SUB r1
    MOV r1, r0

    LOD r1      // load low byte from address in r1 into r0
    MOV r3, r0  // move low byte from r0 to r3

        // add 3 to r1
    SET d3
    ADD r1
    MOV r1, r0

    // calculate parities
        // calculate p0 start
    PAR r4      // calculate parity of high byte 11:9
    MOV r5, r0  // move high byte parity into r5
    PAR r3      // calculate parity of low byte 8:1
    XOR r5      // calculate parity of both bytes 11:1
    MOV r6, r0  // store into r6 for later

        // build new high byte
    MOV r0, r4  // move high byte into r0
    LSH d5      // left shift by 5
    MOV r7, r0  // move r0 into r7 (new high byte)
    
    SET b11110000   // create mask for low byte 8:5
    AND r3  // apply mask to low byte
    RSH d3  // right shift by 3
    ORR r7  // add onto new high byte
    MOV r7, r0  // update new high byte

        // calculate p8
    PAR r4      // calculate parity of high byte 11:9
    MOV r5, r0  // move high byte parity into r5

    SET b11110000   // create mask for low byte 8:5
    AND r3  // apply mask to low byte
    PAR r0  // calculate parity of masked low byte
    XOR r5  // XOR against r5 for parity of 11:5 = p8
            
        // update p0
    MOV r5, r0  // move r0 (p8) into r5
    XOR r6      // XOR against r6 (p0)
    MOV r6, r0  // move back into r6
    MOV r0, r5  // move r5 (p8) into r0

        // update new high byte
    ORR r7  // add onto new high byte
            // new high byte now done and in r0
    
    STR r2  // store high byte into memory address at r2

        // sub 1 from r2
    SET d1
    SUB r2
    MOV r2, r0

        // build new low byte
    SET b00001110   // create mask for low byte 4:2
    AND r3  // apply mask to low byte
    LSH d4  // left shift by 4
    MOV r7, r0  // move r0 into r7 (new low byte)

    SET b00000001   // create mask for low byte 1
    AND r3  // apply mask to low byte
    LSH d3  // left shift by 3
    ORR r7  // add onto new low byte
    MOV r7, r0  // update new low byte

        // calculate p4
    PAR r4      // calculate parity of high byte 11:9
    MOV r5, r0  // move parity into r5

    SET b10001110   // create mask for low byte 8, 4:2
    AND r3  // apply mask to low byte
    PAR r0  // calculate parity of masked low byte
    XOR r5  // XOR against r5 for parity of 11:8, 4:2 = p4
            
        // update p0
    MOV r5, r0  // move r0 (p4) into r5
    XOR r6      // XOR against r6 (p0)  
    MOV r6, r0  // move back into r6
    MOV r0, r5  // move r5 (p4) into r0

        // update new low byte
    LSH d4  // left shift r0 (p4) by 4
    ORR r7  // add onto new low byte
    MOV r7, r0  // update new low byte

        // calculate p2
    SET b00000110   // create mask for high byte 11:10
    AND r4  // apply mask to high byte
    PAR r0  // calculate parity of masked high byte
    MOV r5, r0  // move parity into r5

    SET b01101101   // create mask for low byte 7:6, 4:3, 1
    AND r3  // apply mask to low byte
    PAR r0  // calculate parity of masked low byte
    XOR r5  // xor against r5 for parity of 11:10, 7:6, 4:3, 1

        // update p0
    MOV r5, r0  // move r0 (p2) into r5
    XOR r6      // XOR against r6 (p0)  
    MOV r6, r0  // move back into r6
    MOV r0, r5  // move r5 (p2) into r0

        // update new low byte
    LSH d2  // left shift r0 (p2) by 2
    ORR r7  // add onto new low byte
    MOV r7, r0  // update new low byte

        // calculate p1
    SET b00000101   // create mask for high byte 11, 9
    AND r4  // apply mask to high byte
    PAR r0  // calculate parity of masked high byte
    MOV r5, r0  // move parity into r5

    SET b01011011   // create mask for low byte 7, 5:4, 2:1
    AND r3  // apply mask to low byte
    PAR r0  // calculate parity of masked low byte
    XOR r5  // xor against r5 for parity of 11, 9, 7, 5:4, 2:1

        // update p0
    MOV r5, r0  // move r0 (p1) into r5
    XOR r6  // XOR against r6 (p0)  
            // p0 now done
        
        // update new low byte
    ORR r7  // add onto new low byte
    MOV r7, r0  // update new low byte
    MOV r0, r5  // move r5 (p1) into r0
    LSH d1  // left shift r0 (p1) by 1
    ORR r7  // add onto new low byte
            // new low byte now done and in r0
    
    STR r2  // store low byte into memory address at r2

        // add 3 to r2
    SET d3
    ADD r2
    MOV r2, r0

    SET d31 // set r0 to 31
    CMP r0, r1  // compare r1 to 31
    BNE .LOOP   // break if not equal to beginning of LOOP
