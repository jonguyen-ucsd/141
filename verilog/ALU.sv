// Module Name:    ALU 
// Project Name:   CSE141L
// Revision 2018.01.27
// Additional Comments: 
//   combinational (unclocked) ALU
import definitions::*;			         // includes package "definitions"
module ALU(
  input        [7:0] InputA,             // data inputs
                     InputB,
  input        [2:0] OP,		         // ALU opcode, part of microcode
  output logic [7:0] Out,		         // or:  output reg [7:0] OUT,
  output logic       ALU_EQUALS,           // output = Equals flag
  output logic       ALU_LT              // Less than Flag
  );								    
	 
  op_mne op_mnemonic;			         // type enum: used for convenient waveform viewing
	
  always_comb begin
    Out = 0;                             // No Op = default
    case(OP)
      mcADD: Out = InputA + InputB;
      mcSUB: Out = InputA - InputB; //Should be dual purpose
      mcAND: Out = InputA & InputB;
      mcORR: Out = InputA | InputB;
      mcXOR: Out = InputA ^ InputB;
      mcRXR: Out = ^(InputA);
      mcLSL: Out = InputA << InputB;
      mcLSR: Out = InputA >> InputB:
    endcase
  end

  always_comb							  // assign Zero = !Out;
    ALU_EQUALS = 1'b0;
    ALU_LT = 1'b0;
    if (Out == 'b0)
      ALU_EQUALS = 1'b1;
    else if (Out < 'b0)
      ALU_LT = 1'b1;

  always_comb
    op_mnemonic = op_mne'(OP);			 // displays operation name in waveform viewer

endmodule