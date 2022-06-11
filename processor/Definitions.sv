// Package Name:   Definitions
// Project Name:   CSE141L
// Created:        2020.5.27
// Revised:        2022.1.13
//
// This file defines the parameters used in the ALU.
// `import` the package into each module that needs it.
// Packages are very useful for declaring global variables.

package Definitions;
    // Modern SystemVerilog lets you define types. The advantage
    // of doing this is that tools can preserve type metadata,
    // e.g. enum names will appear in timing diagrams
    // some of these ops don't actually do anything in ALU
    // and are here solely for padding
    typedef enum logic [3:0] {
        ADD,
        SUB,
        LSH,
        RSH,
        XOR,
        AND,
        ORR,
        PAR,
        BEQ,
        BNE,
        BLT,
        BRK,
        STR,
        LOD,
        TGB,
        ASR
    } op_mne;

    typedef enum logic {
        RTYPE,
        CMP
    } op_cmp_mne;

endpackage // Definitions
