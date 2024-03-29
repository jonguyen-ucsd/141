// CSE141L
import definitions::*;
// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
  input [8:0] Instruction,	   // machine code
  // input ALU_equals, ALU_lt,
  input signed [7:0] ALU_out,

  input [7:0] mem_read_value,
  output logic[7:0] mem_addr,
  output logic[7:0] mem_write_value,

  output logic[2:0] ALU_op,
  output logic      ALU_en,

  output logic[3:0] reg_A_addr,
                    reg_B_addr,
                    reg_write_addr,
  
  input [7:0] reg_A_value,
              reg_B_value,
  
  output logic [7:0] reg_write_value,
  
  output logic [3:0] label_index,

  output logic BranchEn,
               RegWrite,
               MemWrite,
               Halt
  );

Instr_Type instr_type;
M_opcodes m_opcode;
R_opcodes r_opcode;
B_opcodes b_opcode;

/*
TODO:
- Control signals output, hook them up to components in datapath
- Reading from memory
- Reading result from ALU to write to the write register
- Look up table for branching addresses?
*/

// jump on right shift that generates a zero
always_comb begin
  // opcodes
  m_opcode = M_opcodes'(0);
  r_opcode = R_opcodes'(0);
  b_opcode = B_opcodes'(0);

  // ALU Values
  ALU_op = 0;
  ALU_en = 0;

  // Decode Instruction
  instr_type = Instr_Type'(Instruction[8:7]);
  case (instr_type)
    M_Type:
      m_opcode = M_opcodes'(Instruction[6:5]);
    R_Type:
      begin
        r_opcode = R_opcodes'(Instruction[6:4]);
        ALU_op = r_opcode;
        ALU_en = 1;
      end
    B_Type:
      begin
        b_opcode = B_opcodes'(Instruction[6:4]);
        // ALU_op = R_opcodes'(1);
        // ALU_en = 1;
      end
  endcase
end
  
always_comb begin
  // Reg File Values
  reg_A_addr = 0;
  reg_B_addr = 1;
  reg_write_addr = 0;
  reg_write_value = 0;

  RegWrite = 0;

  // Reg File Logic
  case (instr_type)
    I_Type: begin
      RegWrite = 1; // control signal for register writing
      reg_write_addr = Instruction[6]; // either r0 or r1
      reg_write_value = Instruction[5:0]; // imm6
    end

    M_Type: begin
      case (m_opcode)
        mcLDR: begin
          // Fetch operands from reg file
          reg_A_addr = Instruction[3:0]; // r0-15

          // Write back to reg file
          RegWrite = 1; // control signal for register writing
          reg_write_addr = Instruction[4]; // either r0 or r1
          reg_write_value = mem_read_value;
        end
        mcSTR: begin
          RegWrite = 0;
          reg_A_addr = Instruction[4]; // either r0 or r1
          reg_B_addr = Instruction[3:0]; // r0-15
        end
        mcMVA: begin
          RegWrite = 1;
          reg_A_addr = Instruction[3:0]; // r0-15
          reg_write_addr = Instruction[4]; // either r0 or r1
          reg_write_value = reg_A_value;
        end
        mcMVS: begin
          RegWrite = 1;
          reg_A_addr = Instruction[4]; // either r0 or r1
          reg_write_addr = Instruction[3:0]; // r0-15
          reg_write_value = reg_A_value;
        end
      endcase
    end
    
    R_Type: begin
      // set operands to be r0 and r1
      reg_A_addr = 0;
      reg_B_addr = 1;

      // Write value back to reg file
      RegWrite = 1;
      reg_write_addr = Instruction[3:0];
      reg_write_value = ALU_out;
    end

    // B_Type: begin
    //   // set operands to be r0 and r1
    //   reg_A_addr = 0;
    //   reg_B_addr = 1;
    // end
  endcase
end

always_comb begin
  // Memory Values
  MemWrite = 0;
  mem_write_value = 0;
  mem_addr = 0;

  // Memory Logic
  if (instr_type == M_Type && m_opcode == mcLDR) begin
    MemWrite = 0;
    mem_addr = reg_A_value; // VALUE of r0-15
  end else if (instr_type == M_Type && m_opcode == mcSTR) begin
    MemWrite = 1;
    mem_addr = reg_B_value;
    mem_write_value = reg_A_value;
  end
end

// branch every time ALU result LSB = 0 (even)
always_comb begin
  // Branch Values
  BranchEn = 0;
  label_index = 0;
  Halt = 0;

  if (instr_type == B_Type) begin
    label_index = Instruction[3:0];
    case (b_opcode)
      mcBAL:
        BranchEn = 1;
      mcBEQ: 
        begin
          if (ALU_out == 0)
            BranchEn = 1;
        end
      mcBNE: 
        begin
          if (ALU_out != 0)
            BranchEn = 1;
        end
      mcBLT:
        begin
          if (ALU_out < 0)
            BranchEn = 1;
        end
      mcBLE:
        begin
          if (ALU_out <= 0)
            BranchEn = 1;
        end
      mcBGT:
        begin
          if (ALU_out > 0)
            BranchEn = 1;
        end
      mcBGE: 
        begin
          if (ALU_out >= 0)
            BranchEn = 1;
        end
      mcFML:
        begin
          Halt = 1;
        end
    endcase
  end
end

endmodule