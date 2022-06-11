// r1 stores current string address
SET d0
MOV r1, r0  // current_address

// r2 stores pattern in MSBs
SET d32
LOD r0
MOV r2, r0  // pattern

// load byte at r1 into r3
LOD r1
MOV r3, r0  // current_byte

// initialize counters to 0
SET d0
MOV r5, r0  // within_bounds_count
MOV r6, r0  // byte_count
MOV r7, r0  // without_bounds_count

// for 0 to 32
.LOOP:
    // prepare variables for loop
        // set r4 (within_bounds_counter) to 0
    SET d0
    MOV r4, r0

    // within bounds section
    .WITHIN_BOUNDS:
            // compare current_byte to pattern
        SET b11111000   // create mask for current_byte
        AND r3  // apply mask to current_byte
        CMP r0, r2  // compare to pattern
        BNE .WITHIN_BOUNDS_CONDITIONAL

            // add 1 to within_bounds_count
        SET d1
        ADD r5
        MOV r5, r0

            // add 1 to without_bounds_count
        SET d1
        ADD r7
        MOV r7, r0

            // add 1 to byte_count if flag bit not set
        SET b10000000   // set r0 to flag bit status
        CMP r0, r6  // compare r0 to r6
        BLT .WITHIN_BOUNDS_CONDITIONAL // if r0 < r6, that means flag bit has been set

            // add 1 to byte_count
        SET d1
        ADD r6
        MOV r6, r0

            // set flag bit status
        SET b10000000
        ORR r6
        MOV r6, r0

        .WITHIN_BOUNDS_CONDITIONAL:
            // add 1 to r4 (within_bounds_counter)
        SET d1
        ADD r4
        MOV r4, r0

            // left shift current_byte by 1
        MOV r0, r3
        LSH d1
        MOV r3, r0

            // compare r4 (within_bounds_counter) to 4
        SET d4
        CMP r0, r4
        BNE .WITHIN_BOUNDS  // if within_bounds_counter != 4, continue within bounds
    
    // r3 after this holds only the last 4 bits of data
    // r4 will now hold next_byte
    
    // without bounds section
    .WITHOUT_BOUNDS:
            // remove flag bit on byte_count
        SET b01111111   // set mask for byte_count
        AND r6  // apply mask
        MOV r6, r0  // update byte_count

            // add 1 to current_address
        SET d1
        ADD r1
        MOV r1, r0

            // compare current_address to 32
        SET d32
        CMP r0, r1
        BEQ .END    // if current_address = 32 go to end

            // load next_byte into r4
        LOD r1
        MOV r4, r0
    
        // comparison start
            // first comparison

            // build string to compare
        SET b10000000   // set mask for next_byte
        AND r4  // apply mask to next_byte
        RSH d4  // right shift by 4
        ORR r3  // add onto current_byte
        CMP r0, r2  // compare to pattern
        BNE .NEXT_2

        // add 1 to without_bounds_count
        SET d1
        ADD r7
        MOV r7, r0

            // second comparison
        .NEXT_2:
            // left shift current_byte by 1
        MOV r0, r3
        LSH d1
        MOV r3, r0

            // build string to compare
        SET b11000000   // set mask for next_byte
        AND r4  // apply mask to next_byte
        RSH d3  // right shift by 3
        ORR r3  // add onto current_byte
        CMP r0, r2  // compare to pattern
        BNE .NEXT_3

        // add 1 to without_bounds_count
        SET d1
        ADD r7
        MOV r7, r0

        .NEXT_3:
            // left shift current_byte by 1
        MOV r0, r3
        LSH d1
        MOV r3, r0

            // build string to compare
        SET b11100000   // set mask for next_byte
        AND r4  // apply mask to next_byte
        RSH d2  // right shift by 2
        ORR r3  // add onto current_byte
        CMP r0, r2  // compare to pattern
        BNE .NEXT_4

        // add 1 to without_bounds_count
        SET d1
        ADD r7
        MOV r7, r0

        .NEXT_4:
            // left shift current_byte by 1
        MOV r0, r3
        LSH d1
        MOV r3, r0

            // build string to compare
        SET b11110000   // set mask for next_byte
        AND r4  // apply mask to next_byte
        RSH d1  // right shift by 1
        ORR r3  // add onto current_byte
        CMP r0, r2  // compare to pattern
        BNE .LOOP_SETUP

        // add 1 to without_bounds_count
        SET d1
        ADD r7
        MOV r7, r0

    .LOOP_SETUP:
        // to prepare for next iteration, move next_byte into current_byte
    MOV r3, r4
    BRK .LOOP

.END:
// store all counters
    // store within_bounds_count
SET d33
MOV r1, r0
MOV r0, r5
STR r1

    // store byte_count
SET d34
MOV r1, r0
MOV r0, r6
STR r1

    // store without_bounds_count
SET d35
MOV r1, r0
MOV r0, r7
STR r1