// Create Date:    2018.04.05
// Design Name:    BasicProcessor
// Module Name:    TopLevel 
// CSE141L
// partial only										   
module TopLevel(		   // you will have the same 3 ports
    input     Reset,	   // init/reset, active high
			     		Start,    // start next program
	            Clk,	   // clock -- posedge used inside design
    output logic Ack	   // done flag from DUT
		);

	wire [ 2:0] ALU_op;
	wire				ALU_en;
	wire [ 9:0] PgmCtr,        // program counter
							PCTarg;
	wire [ 8:0] Instruction;   // our 9-bit opcode
	wire [ 3:0] reg_A_addr, reg_B_addr, reg_write_addr;
	wire [ 7:0] reg_A_value, reg_B_value, reg_write_value;
	wire [ 7:0] mem_addr;
	// wire [ 7:0] InA, InB, 	   // ALU operand inputs
	wire signed [ 7:0] ALU_out;       // ALU result
	wire [ 7:0] mem_write_value, // data in to data_memory
							mem_read_value;  // data out from data_memory
	wire        RegWrite,    // reg_file write enable
							MemWrite,	   // data_memory write enable
							// ALU_equals,		     // ALU output = 0 flag
							// ALU_lt,						 // ALU output less than flag
							BranchEn,	   // to program counter: branch enable
							Halt;
	logic[15:0] CycleCt;	   // standalone; NOT PC!
  wire [3:0]  label_index;

	LUT L1 (
		.label_index (label_index),
		.Target (PCTarg)
	);

	// Fetch = Program Counter + Instruction ROM
	// Program Counter
  InstFetch IF1 (
		.Reset       (Reset   ) , 
		.Start       (Start   ) ,  // SystemVerilg shorthand for .halt(halt), 
		.Clk         (Clk     ) ,  // (Clk) is required in Verilog, optional in SystemVerilog
		.BranchEn    (BranchEn    ) ,  // branch enable
		.Target      (PCTarg  ) ,
		.ProgCtr     (PgmCtr  )	   // program count = index to instruction memory
	);					  

	// Control decoder
  Ctrl Ctrl1 (
		.Instruction  		(Instruction), // from instr_ROM
		// .ALU_equals   		(ALU_equals),
		// .ALU_lt       		(ALU_lt),
		.ALU_out					(ALU_out),
		.ALU_en						(ALU_en),
		.mem_read_value 	(mem_read_value),
		.mem_addr 			  (mem_addr),
		.mem_write_value 	(mem_write_value),
		.ALU_op 			    (ALU_op),
		.reg_A_addr   		(reg_A_addr),
		.reg_B_addr   		(reg_B_addr),
		.reg_write_addr   (reg_write_addr),
		.reg_A_value  		(reg_A_value),
		.reg_B_value 		  (reg_B_value),
		.reg_write_value  (reg_write_value),
		.label_index			(label_index),
		.BranchEn     		(BranchEn),		 // to IF/PC
		.RegWrite 			  (RegWrite),
		.MemWrite 			  (MemWrite),
		.Halt							(Halt)
  );
	// instruction ROM
  InstROM #(.W(9)) IR1(
		.InstAddress   (PgmCtr), 
		.InstOut       (Instruction)
	);

  // assign LoadInst = Instruction[8:6]==3'b110;  // calls out load specially
	// reg file
	RegFile #(.W(8),.D(4)) RF1 (
		.Clk    				  ,
		.WriteEn   (RegWrite), 
		.RaddrA    (reg_A_addr),         //concatenate with 0 to give us 4 bits
		.RaddrB    (reg_B_addr), 
		.Waddr     (reg_write_addr), 	       // mux above
		.DataIn    (reg_write_value), 
		.DataOutA  (reg_A_value), 
		.DataOutB  (reg_B_value)
	);

  ALU ALU1  (
	  .InputA     (reg_A_value),
	  .InputB     (reg_B_value), 
		.En					(ALU_en),
	  .OP         (ALU_op),
	  .Out        (ALU_out)
	  // .ALU_equals (ALU_equals),
		// .ALU_lt     (ALU_lt)
	);
  
	DataMem DM1(
		.DataAddress  (mem_addr), 
		.MemWrite     (MemWrite),
		.DataIn       (mem_write_value), 
		.DataOut      (mem_read_value), 
		.Clk 		      (Clk)
	);

	always_ff @(posedge Clk)
		if (Start == 1)	   // if(start)
			CycleCt <= 0;
		else if(Ack == 0)   // if(!halt)
			CycleCt <= CycleCt+16'b1;

	always_comb begin
		Ack = Halt;
	end

endmodule