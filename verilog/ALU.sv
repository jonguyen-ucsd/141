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
  input              En,
  output logic signed [7:0] Out		         // or:  output reg [7:0] OUT,
  // output logic       ALU_equals,           // output = Equals flag
  // output logic       ALU_lt,             // Less than Flag
  );								    
	 
  op_mne op_mnemonic;			         // type enum: used for convenient waveform viewing
	
  always_comb begin
    if (En) begin
      case(OP)
        mcADD: Out = InputA + InputB;
        mcSUB: Out = InputA - InputB; //Should be dual purpose
        mcAND: Out = InputA & InputB;
        mcORR: Out = InputA | InputB;
        mcXOR: Out = InputA ^ InputB;
        mcRXR: Out = ^(InputA);
        mcLSL: Out = InputA << InputB;
        mcLSR: Out = InputA >> InputB;
      endcase
    end
  end

  // always_comb begin				  // assign Zero = !Out;
  //   ALU_equals = 1'b0;
  //   ALU_lt = 1'b0;
  //   if (Out == 0)
  //     ALU_equals = 1'b1;
  //   if (Out < 0)
  //     ALU_lt = 1'b1;
  // end

  always_comb
    op_mnemonic = op_mne'(OP);			 // displays operation name in waveform viewer

endmodule