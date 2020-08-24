// CSE141L
import definitions::*;
// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
  input[8:0] Instruction;	   // machine code
  input EQUALS, LT;

  output logic[2:0]

  output logic[3:0] reg_A_addr,
                    reg_B_addr,
                    reg_write_addr;
  
  output logic[7:0] reg_A_value,
                    reg_B_value,
                    reg_write_value;
               
  output logic Jump,
               BranchEn,
               BranchAccept,
               ctrl_regwrite,
               ctrl_memwrite
               ctrl_memread;

  );

""" 
TODO:
- Control signals output, hook them up to components in datapath
- Reading from memory
- Reading result from ALU to write to the write register
- Look up table for branching addresses?

"""
// jump on right shift that generates a zero
always_comb
  // Decode Instruction
  instr_type = Instr_Type'(instruction[8:7]);
  reg_A_addr = 0;
  reg_B_addr = 1;
  reg_A_value = 0;
  reg_B_value = 0;
  reg_write_addr = 2;
  BranchEn = 0;
  BranchAccept = 0;

  case (instr_type):
    I_type:
      begin
        reg_write_addr = instruction[6];
        reg_write_value = instruction[5:0];
      end
    M_Type:
      begin
        opcode = M_Type'(instruction[6:5])
        case (opcode):
          mcLDR:
            begin
              
            end
          mcSTR:
            begin
              
            end
          mcMVA:
            begin
              
            end
          mcMVS:
            begin

            end
      end
    R_Type:
      begin
        opcode = R_Type'(instruction[6:4])
        ALU_OP = opcode;
        reg_A_addr = 0;
        reg_B_addr = 1;
        reg_write_addr = instruction[3:0];
      end
    B_Type:
      begin
        opcode = B_Type'(instruction[6:5])
        BranchEn = 1;
        case (opcode):
          mcBAL: BranchAccept = 1;
          mcBEQ: BranchAccept = EQUALS;
          mcBLT: BranchAccept = LT;
          mcBLE: BranchAccept = LT & EQUALS;
        endcase
      end
  endcase

// branch every time ALU result LSB = 0 (even)
assign BranchEn = &Instruction[3:0];

endmodule

