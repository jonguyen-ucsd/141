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

	wire [2:0] ALU_op;
	wire [ 9:0] PgmCtr,        // program counter
							PCTarg;
	wire [ 8:0] Instruction;   // our 9-bit opcode
	wire [ 3:0] reg_A_addr, reg_B_addr, reg_write_addr;
	wire [ 7:0] reg_A_value, reg_B_value, reg_write_value;
	wire [ 7:0] mem_addr;
	// wire [ 7:0] InA, InB, 	   // ALU operand inputs
	wire [7:0]  ALU_out;       // ALU result
	wire [ 7:0] mem_write_value, // data in to data_memory
							mem_read_value;  // data out from data_memory
	wire        RegWrite,    // reg_file write enable
							MemWrite,	   // data_memory write enable
							ALU_equals,		     // ALU output = 0 flag
							ALU_lt,						 // ALU output less than flag
							Jump,	       // to program counter: jump 
							BranchEn;	   // to program counter: branch enable
	logic[15:0] CycleCt;	   // standalone; NOT PC!

	// Fetch = Program Counter + Instruction ROM
	// Program Counter
  InstFetch IF1 (
		.Reset       (Reset   ) , 
		.Start       (Start   ) ,  // SystemVerilg shorthand for .halt(halt), 
		.Clk         (Clk     ) ,  // (Clk) is required in Verilog, optional in SystemVerilog
		.BranchAbs   (Jump    ) ,  // jump enable
		.BranchRelEn (BranchEn) ,  // branch enable
		.ALU_equals	 	 (ALU_equals    ) ,
		.ALU_lt    (ALU_lt) ,
		.Target      (PCTarg  ) ,
		.ProgCtr     (PgmCtr  )	   // program count = index to instruction memory
	);					  

	// Control decoder
  Ctrl Ctrl1 (
		.Instruction  		(Instruction), // from instr_ROM
		.ALU_equals   		(ALU_equals),
		.ALU_lt       		(ALU_lt),
		.mem_read_value 	(mem_read_value),
		.mem_addr 			(mem_addr),
		.mem_write_value 	(mem_write_value),
		.ALU_op 			(ALU_op),
		.reg_A_addr   		(reg_A_addr),
		.reg_B_addr   		(reg_B_addr),
		.reg_write_addr   	(reg_write_addr),
		.reg_A_value  		(reg_A_value),
		.reg_B_value 		(reg_B_value),
		.reg_write_value    (reg_write_value),
		.Jump         		(Jump),		     // to PC
		.BranchEn     		(BranchEn),		 // to PC
		.BranchAccept 		(BranchAccept),
		.RegWrite 			(RegWrite),
		.MemWrite 			(MemWrite)
  );
	// instruction ROM
  InstROM #(.W(9)) IR1(
		.InstAddress   (PgmCtr), 
		.InstOut       (Instruction)
	);

  // assign LoadInst = Instruction[8:6]==3'b110;  // calls out load specially

  assign Ack = &Instruction;
	// reg file
	RegFile #(.W(8),.D(3)) RF1 (
		.Clk    				  ,
		.WriteEn   (RegWrite), 
		.RaddrA    (reg_A_addr),         //concatenate with 0 to give us 4 bits
		.RaddrB    (reg_B_addr), 
		.Waddr     (reg_write_addr), 	       // mux above
		.DataIn    (reg_write_value), 
		.DataOutA  (reg_A_value), 
		.DataOutB  (reg_B_value)
	);

	// one pointer, two adjacent read accesses: (optional approach)
	//	.raddrA ({Instruction[5:3],1'b0});
	//	.raddrB ({Instruction[5:3],1'b1});

	// Bottom two lines are unnecessary if using reg_A_value, reg_B_value for both RF output and ALU in
	// assign InA = ReadA;						          // connect RF out to ALU in
	// assign InB = ReadB;
	// assign MemWrite = (Instruction == 9'h111);       // mem_store command

	// Needed???
	// assign RegWriteValue = LoadInst? MemReadValue : ALU_out;  // 2:1 switch into reg_file

  ALU ALU1  (
	  .InputA     (reg_A_value),
	  .InputB     (reg_B_value), 
	  .OP         (ALU_op),
	  .Out        (ALU_out),
	  .ALU_equals (ALU_equals),
		.ALU_lt     (ALU_lt)
	);
  
	DataMem DM1(
		.DataAddress  (mem_addr), 
		.MemWrite      (MemWrite), 
		.DataIn       (mem_write_value), 
		.DataOut      (mem_read_value), 
		.Clk 		  		     ,
		.Reset		    (Reset)
	);
	
	// count number of instructions executed
	always_ff @(posedge Clk)
		if (Start == 1)	   // if(start)
			CycleCt <= 0;
		else if(Ack == 0)   // if(!halt)
			CycleCt <= CycleCt+16'b1;

endmodule