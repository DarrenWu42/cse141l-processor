// r1 stores source address to decode
SET d31
MOV r1, r0

// r2 stores decoded destination address
SET d1
MOV r2, r0

// for 31 to 60 skipping by 2
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

    // calculate calculated parities
        // calculate p8
    SET b11111110   // create mask for high byte 11:5
    AND r4  // apply mask to high byte
    PAR r0  // calculate parity of high byte 11:9 = p8

        // update calculated parities
    LSH d4  // left shift by 4 to put into place
    MOV r7, r0  // move p8 into r7 (calculated parities)

        // calculate p4
    SET b11110000   // create mask for high byte 11:8
    AND r4  // apply mask to high byte
    PAR r0  // calculate parity of high byte 11:8
    MOV r5, r0  // move parity into r5 temporarily

    SET b11100000   // create mask for low byte 4:2
    AND r3  // apply mask to low byte
    PAR r0  // calculate parity of masked low byte
    XOR r5  // XOR against r5 for parity of 11:8, 4:2 = p4

        // update calculated parities
    LSH d3  // left shift by 3 to put into place
    ORR r7  // add onto calculated parities
    MOV r7, r0  // update calculated parities

        // calculate p2
    SET b11001100   // create mask for high byte 11:10, 7:6
    AND r4  // apply mask to high byte
    PAR r0  // calculate parity of high byte 11:10, 7:6
    MOV r5, r0  // move parity into r5 temporarily

    SET b11001000  // create mask for low byte 4:3, 1
    AND r3  // apply mask to low byte
    PAR r0  // calculate parity of low byte 4:3, 1
    XOR r5  // XOR against r5 for parity of 11:10, 7:6, 4:3, 1 = p2

        // update calculated parities
    LSH d2  // left shift by 2 to put into place
    ORR r7  // add onto calculated parities
    MOV r7, r0  // update calculated parities

        // calculate p1
    SET b10101010   // create mask for high byte 11, 9, 7, 5
    AND r4  // apply mask to high byte
    PAR r0  // calculate parity of high byte 11, 9, 7, 5
    MOV r5, r0  // move parity into r5 temporarily

    SET b10101000  // create mask for low byte 4, 2, 1
    AND r3  // apply mask to low byte
    PAR r0  // calculate parity of low byte 4, 2, 1
    XOR r5  // XOR against r5 for parity of 11, 9, 7, 5, 4, 2, 1 = p1

        // update calculated parities
    LSH d1  // left shift by 1 to put into place
    ORR r7  // add onto calculated parities
    MOV r7, r0  // update calculated parities

        // calculate p0
    SET b11111110   // create mask for high byte 11:5
    AND r4  // apply mask to high byte
    PAR r0  // calculate parity of high byte 11:5
    MOV r5, r0  // move parity into r5 temporarily

    SET b11101000  // create mask for low byte 4:2, 1
    AND r3  // apply mask to low byte
    PAR r0  // calculate parity of low byte 4:2, 1
    XOR r5  // XOR against r5 for parity of 11:1
    MOV r5, r0  // move parity back into r5 temporarily

    PAR r7  // calculate parity of calculated parities so far
    XOR r5  // XOR against r5 for parity of 11:1, p1, p2, p4, p8

        // update calculated parities
    ORR r7  // add onto calculated parities
    MOV r7, r0  // update calculated parities

    // r3 contains low byte
    // r4 contains high byte
    // r7 contains calculated parities

    // retrieve given parities
    SET b00000001 // create mask for high byte p8
    AND r4  // apply mask to high byte
    LSH d4  // shift left by 4
    MOV r6, r0  // move p8 to r6 (given parities)

    SET b00010000   // create mask for low byte p4
    AND r3  // apply mask to low byte
    RSH d1  // shift right by 1
    ORR r6  // add onto given parities
    MOV r6, r0  // update given parities

    SET b00000111   // create mask for low byte p2:p0
    AND r3  // apply mask to low byte
    ORR r6  // add onto given parities
    MOV r6, r0  // update give parities

    // r3 contains low byte
    // r4 contains high byte
    // r6 contains given parities
    // r7 contains calculated parities

    // calculate parity of entire message
    PAR r3  // calculate parity of low byte
    MOV r5, r0  // temporarily store into r5
    PAR r4  // calculate parity of high byte
    XOR r5  // xor against r5 for parity of entire message
    MOV r5, r0  // store parity of message into r5

    // check and fix message
    SET d1  // set r0 to d1
    CMP r0, r5  // compare r0 to r5
    BNE .COMPARE_PARITIES   // if parity of entire message does not equal 1 compare parities

    // parity of entire message does equal 1, 1 error
        // set status bits to 01000
    SET b01000000   // set r0 to status byte
    MOV r5, r0  // store into r5 to use later

        // find error position
    MOV r0, r6  // move given parities into r0
    RSH d1  // shift right by one to remove p0
    MOV r6, r0  // move back into given parities
    MOV r0, r7  // move calculated parities into r0
    RSH d1  // shift right by one to remove p0
    XOR r6  // XOR with r6 to get error position
    MOV r6, r0  // move error position to r6

        // correct error at position
    SET d8  // set r0 to 8
    CMP r6, r0  // compare r6 to r0
    BLT .LOW_BYTE_ERR   // break to low_byte_err if r6 < 8

        .HIGH_BYTE_ERR:
        // error is in high byte
            // subtract 8 from r6
        SET d8
        SUB r6
        MOV r6, r0

            // toggle bit of high byte that is incorrect
        MOV r0, r4  // move high byte into r0
        TGB r6  // toggle bit of r0 at position r6 (error position)
        MOV r4, r0  // return corrected high byte to r4

        BRK .BUILD_ORIGINAL

        .LOW_BYTE_ERR:
        // error is in low byte
            // toggle bit of low byte that is incorrect
        MOV r0, r3  // move low byte into r0
        TGB r6  // toggle bit of r0 at position r6 (error position)
        MOV r3, r0  // return corrected low byte to r3

        BRK .BUILD_ORIGINAL
    
    .COMPARE_PARITIES:
    // either 0 or 2 errors
        // compare the supposed and given parities together
    CMP r6, r7
    BNE .TWO_ERRORS

        .ZERO_ERRORS:
        // 0 error detected, set status bits accordingly
        SET b00000000   // set r0 to status byte
        MOV r5, r0  // store into r5 to use later

        BRK .BUILD_ORIGINAL

        .TWO_ERRORS:
        // 0 error detected, give up and set status bits accordingly
        SET b10000000   // set r0 to status byte
        MOV r5, r0  // store into r5 to use later

    .BUILD_ORIGINAL:
    // r3 contains (corrected) low byte
    // r4 contains (corrected) high byte
    // r5 contains the status bits

    // build original message
        // build original high byte
    MOV r0, r4  // move high byte into r0
    RSH d5      // right shift by 5
    ORR r5      // add status bits onto high byte
                // original high byte now done and in r0
    
    STR r2  // store original high byte into memory address at r2

        // sub 1 from r2
    SET d1
    SUB r2
    MOV r2, r0

        // build original low byte
    SET b00011110   // create mask for high byte 8:5
    AND r4  // apply mask to high byte
    LSH d3  // left shift by 3
    MOV r5, r0  // move r0 into r5 (original low byte)
    
    SET b11100000   // create mask for low byte 4:2
    AND r3  // apply mask to low byte
    RSH d4  // right shift by 4
    ORR r5  // add onto original low byte
    MOV r5, r0  // update original low byte

    SET b00001000   // create mask for low byte 1
    AND r3  // apply mask to low byte
    RSH d3  // right shift by 3
    ORR r5  // add onto original low byte
            // original low byte now in r0

    STR r2 // store original low byte into memory address at r2

        // add 3 to r2
    SET d3
    ADD r2
    MOV r2, r0

    // loop conditional
    SET d61 // set r0 to 61
    CMP r0, r1  // compare r1 to 61
    BNE .LOOP   // break if not equal to beginning of LOOP