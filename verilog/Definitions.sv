//This file defines the parameters used in the alu
// CSE141L
package definitions;
    
// Instruction map
  // const logic [2:0]mcADD  = 3'b000;
  // const logic [2:0]mcSUB  = 3'b001;
  // const logic [2:0]mcAND  = 3'b010;
  // const logic [2:0]mcOR   = 3'b011;
  // const logic [2:0]mcXOR  = 3'b100;
	// const logic [2:0]mcRXR  = 3'b101;
	// const logic [2:0]mcLSL  = 3'b110;
	// const logic [2:0]mcLSR  = 3'b111;

// Control Unit
  typedef enum {
    I_Type = 0,
    M_Type = 1,
    R_Type = 2,
    B_Type = 3
  } Instr_Type;

  typedef enum {  
    mcADD = 0,
    mcSUB = 1,
    mcAND = 2,
    mcORR = 3,
    mcXOR = 4,
    mcRXR = 5,
    mcLSL = 6,
    mcLSR = 7
  } R_opcodes;
  
  typedef enum {
    mcLDR = 0,
    mcSTR = 1,
    mcMVA = 2,
    mcMVS = 3
  } M_opcodes;

  typedef enum {
    mcBAL = 0,
    mcBEQ = 1,
    mcBNE = 2,
    mcBLT = 3,
    mcBLE = 4,
    mcBGT = 5,
    mcBGE = 6,
    mcFML = 7
  } B_opcodes;

// enum names will appear in timing diagram
  typedef enum logic[2:0] {
      ADD, SUB, AND, OR,
      XOR, RXR, LSL, LSR } op_mne;
// note: kADD is of type logic[2:0] (3-bit binary)
//   ADD is of type enum -- equiv., but watch casting
//   see ALU.sv for how to handle this   
endpackage // definitions
