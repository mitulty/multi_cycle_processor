`timescale 1ns / 1ps
module controller(input [15:0] instruction,
                  input resetn,clk,
                  input [4:0] status_signals,
                  output [28:0] ctrlWord,
                  output reg DMem_wr,
                  output [3:0] debug_state);

wire cflag,zflag,eq,SM_reg_out,is_valid_out;
reg [3:0] state;
reg sel_MuxIR, Load_PC, Load_IR, Load_C_Flag, Load_Z_Flag, Load_RegFile, alu_op_bit, sel_ALUInp1, sel_MuxPCIncr,load_alu_reg,Load_T1,Load_comp,Load_LW;
reg [1:0] sel_add, sel_ALUInp2, sel_RegFileAddrOut, sel_RegFileInp, sel_RegFileAddrInp, sel_MuxPCIn;
reg load_DMem_out_reg,load_DMem_in_reg,set_SM_reg,clear_SM_reg,is_valid,clear_comp;

reg is_one_hot_or_zero;

parameter S_RESET   = 0;
parameter S_FETCH   = 1;
parameter S_DECODE  = 2;
parameter S_R_READ  = 3;
parameter S_EXECUTE = 4;
parameter S_MEM_ACC = 5;
parameter S_WR_BACK = 6;

initial
    state <= S_RESET;

always @(posedge clk) begin   
    if (resetn==1'b0) begin //change
        state <= S_RESET;
        //$display ("RESET");
	end

    else begin
        case (state) 
            S_RESET: begin 
                        state <= S_FETCH;
                        //$display ("Reset 2");
                    end
            S_FETCH: begin
                        state <= S_DECODE;
                        // $display ("Fetch State");
                    end
            S_DECODE: begin
					 	state <= S_R_READ;
                        // $display ("Decode State");
                    end
            
            S_R_READ : begin
                        state <= S_EXECUTE;
                        // $display ("Register read State");
                    end
            
            S_EXECUTE : begin
                        if(instruction[15:12]==4'b0110 && instruction[7:0]==8'b0) //LM instruction
                            state <= S_WR_BACK; // no work left
                        else
                            state <= S_MEM_ACC;
                        // $display ("Execute State");
                    end
            
            S_MEM_ACC : begin   
                            state <= S_WR_BACK;
                       // $display ("Memory access State");
                    end
            
            S_WR_BACK : begin
                        if(instruction[15:12]==4'b0110 && is_one_hot_or_zero==0) // LM instruction and more work left
                            state <= S_EXECUTE;
                        else if(instruction[15:12]==4'b0111 && is_one_hot_or_zero==0) // SM instruction and more work left
                            state <= S_R_READ;
                        else     
							state <= S_FETCH;
                   //     $display ("Write back State");
                    end

            default: state <= S_RESET;
        endcase
    end
end

//combinational logic to check for one hot input

always @(instruction[7:0]) begin
    case(instruction[7:0])
        0,1,2,4,8,16,32,64,128:
            is_one_hot_or_zero<=1'b1;
        default:
            is_one_hot_or_zero<=1'b0;
    endcase
end

//control signals
always @(state,instruction,status_signals) begin

    {clear_comp,Load_LW,set_SM_reg,clear_SM_reg,Load_comp,load_DMem_in_reg,Load_T1,sel_MuxIR, Load_IR, Load_PC, Load_C_Flag, Load_Z_Flag, Load_RegFile, sel_RegFileAddrOut[1:0], alu_op_bit, sel_ALUInp1, sel_ALUInp2[1:0], sel_RegFileAddrInp[1:0], sel_RegFileInp[1:0], sel_MuxPCIncr, sel_MuxPCIn[1:0]} <=25'b0;
    
    // register load signals
    load_DMem_out_reg<=1'b0;
    load_alu_reg<=1'b0;
	 is_valid<=1'b1;
    DMem_wr<=1'b0;
    
    case(state)
        S_RESET : begin
            clear_SM_reg<=1'b1;
            is_valid<=1'b1;
        end
        
        S_FETCH : begin
//            $display ("Fetch stage");
            Load_IR <= 1'b1;
            is_valid<=1'b1;
				clear_comp<=1'b1;
        end

        S_R_READ : begin
			//$display ("Instruction In Read %b",instruction[15:12]);		  
            case(instruction[15:12])
                4'b0000: begin                  // ADD		  
                    sel_RegFileAddrOut<=2'b11;  // IR[11:9]->RF_addr1,IR[8:6]->RF_addr2
                    load_alu_reg<=1'b1;         // load alu input regs
				end
                4'b0010: begin                  // NAND	  
                    sel_RegFileAddrOut<=2'b11;  // IR[11:9]->RF_addr1,IR[8:6]->RF_addr2
                    load_alu_reg<=1'b1;         // load alu input regs
				end
                4'b0001: begin                  // ADI
                    sel_RegFileAddrOut[1]<=1'b1;// IR[11:9]->RF_addr1
                    sel_ALUInp2<=2'b11;         // Imm6->ALU_inp2
                    load_alu_reg<=1'b1;         // load alu input regs
				end
                4'b0110: begin                  // LM
                    sel_RegFileAddrOut[1]<=1'b1;// IR[11:9]->RF_addr1 
                                                // RF_out1->alu_reg_1 
                    sel_ALUInp2<=2'b01;        // 0-> alu_reg_2------------------------------------>>
                    load_alu_reg<=1'b1;         // load alu input regs
            end
                4'b0111: begin                  // SM
                    sel_RegFileAddrOut<=2'b10;  // pe_out->RF_addr1
                                                // data_out2->DMem_in_reg
                    load_DMem_in_reg<=1'b1;     // Load_DMem_in_reg<-1
                    set_SM_reg<=1'b1;           // SM_flag<-1
                                                // if(first time)-i.e. SM_reg_out==0
                    sel_ALUInp1<=SM_reg_out;    //     data_out1->alu_reg_1
                                                //     0->alu_reg_2
                    sel_ALUInp2<=SM_reg_out?2'b10:2'b01;
                                                // else
                                                //     alu_out->alu_reg_1
                                                //     +1->alu_reg_2
                    load_alu_reg<=1'b1;         // load alu input regs
				end
                4'b1100:                        // BEQ
                    sel_RegFileAddrOut<=2'b11;  // IR[11:9]->RF_addr1,IR[8:6]->RF_addr2
                4'b0101: begin                  // SW
					load_DMem_in_reg<=1'b1;
                    sel_ALUInp1<=1'b0;
					sel_ALUInp2<=2'b11;
					load_alu_reg<=1'b1;
				end
                4'b0100: begin                  //LW
                    load_alu_reg<=1'b1;
                    sel_ALUInp2<=2'b11;
                end
                default:                        // other instructions don't use R_READ
                    sel_RegFileAddrOut<=2'b00;
            endcase
            is_valid<=1'b1;
        end

        S_EXECUTE : begin
            //$display ("Instruction In Execute %b",instruction[15:12]);
            Load_T1<=1'b1;
            if(instruction[15:12]==4'b0000 || instruction[15:12]==4'b0001 || instruction[15:12]==4'b0010)
                Load_Z_Flag<=1'b1;
            if(instruction[15:12]==4'b0000 || instruction[15:12]==4'b0001)
                Load_C_Flag<=1'b1;	
            case(instruction[15:12])
                4'b0010:                        // NAND
                    alu_op_bit<=1'b1;
					 4'b1100:
						  Load_comp<=1'b1;
                4'b0110: begin                  // LM
                    sel_ALUInp1<=1'b1;          // T1_out -> alu_1
                    sel_ALUInp2<=2'b10;         // 1 -> alu_2
                    load_alu_reg<=1'b1;         // load alu input regs
                end
                4'b0111: begin                  // SM
                    Load_T1<=1'b1;              // load T1
                end
                default:
                    alu_op_bit<=1'b0;
            endcase
            is_valid<=1'b1;
            // if flag not set don't execute conditional instructions
            if(instruction[15:12]==4'b0000 || instruction[15:12]==4'b0010)
                if ((cflag==1'b0 && instruction[1]==1'b1) ||(instruction[0]==1'b1 && zflag==1'b0))  begin
                    Load_T1<=1'b0;
                    Load_C_Flag<=1'b0;
                    Load_Z_Flag<=1'b0;	
                    is_valid<=1'b0;             // disable mem access and write-back
                end
        end

        S_MEM_ACC : begin
			//$display ("Instruction In Mem_Acc %b",instruction[15:12]);
            case(instruction[15:12])
                4'b0100: begin                  // LW
                    load_DMem_out_reg<=1'b1;    // load mem_input register
                    Load_Z_Flag<=1'b1;	
						  Load_LW<=1'b1;
                end
                4'b0011,4'b0110:                // load
                    load_DMem_out_reg<=1'b1;    // load mem_input register
                4'b0101,4'b0111:                // store
                                                // send addresss
                    DMem_wr<=1'b1;
            endcase
            is_valid<=is_valid_out;             // save the valid bit
        end

        S_WR_BACK : begin
                                                // PC<- PC+1 by default
            sel_MuxPCIn<= 2'b01;                // Increment PC=========>
            Load_PC <=1'b1;
           // $display ("Instruction In Write Back %b",instruction[15:12]);
            case(instruction[15:12])
                4'b0000,4'b0010: begin          // ADD or NAND
                    sel_RegFileAddrInp<=2'b11;  // IR[5:3]->RF_addr_inp
                    sel_RegFileInp<=2'b11;      // ALU_out->RF_data_inp
                    Load_RegFile<=is_valid_out; // load only if 
                end
                4'b0001: begin				    // ADI	
                    sel_RegFileAddrInp<=2'b00;  // IR[8:6]->RF_addr_inp
                    sel_RegFileInp<=2'b11;      // ALU_out->RF_data_inp
                    Load_RegFile<=1'b1;
                end
                4'b0011: begin                  // LHI
                    sel_RegFileAddrInp<=2'b10;  // IR[11:9]->RF_addr_inp
                    sel_RegFileInp<=2'b0;       // {IR[8:0],7'b0}->RF_data_inp
                    Load_RegFile<=1'b1;
                end
                4'b0100: begin                  // LW
                    sel_RegFileInp<=2'b01;      // data_memory_reg->RF_data_inp
                    sel_RegFileAddrInp<=2'b10;  // IR[11:9]->RF_addr_inp
                    Load_RegFile<=1'b1;
                end
                4'b0110: begin                  // LM
                    sel_RegFileAddrInp<=2'b01;  // pe_out->RF_addr_inp
                    sel_RegFileInp<=2'b01;      // data_memory_reg->RF_data_inp
                    sel_MuxIR<=1'b1;            // IR[pe_out]<-0
                    Load_IR<=1'b1;
                    Load_PC<=is_one_hot_or_zero;// if not done stay on LM ins
                    Load_RegFile<=1'b1;
                end
                4'b0111: begin                  // SM
                    sel_MuxIR<=1'b1;            // IR[pe_out]<-0
                    Load_IR<=1'b1;
                    Load_PC<=is_one_hot_or_zero;// if not done stay on SM ins
                    clear_SM_reg<=is_one_hot_or_zero;
                end
                4'b1100: begin                  // BEQ
                    if(eq) begin
                        sel_MuxPCIn<=2'b00;
                        sel_MuxPCIncr<=1'b1;
                    end
                end	
                4'b1000: begin                  // JAL
                    sel_MuxPCIncr<=1'b0;
                    sel_MuxPCIn<=2'b00;
                    sel_RegFileAddrInp<=2'b10;  // IR[11:9]->RF_addr_inp
                    sel_RegFileInp<=2'b10;      // PC+1->RF_data_inp
                    Load_RegFile<=1'b1;
                end
                4'b1001: begin                  // JLR
                    sel_MuxPCIn<=2'b11;
                    sel_RegFileAddrInp<=2'b10;  // IR[11:9]->RF_addr_inp
                    sel_RegFileInp<=2'b10;      // PC+1->RF_data_inp
                    Load_RegFile<=1'b1;
                end
            endcase
            is_valid<=1'b1;                     // set to 1 for next instruction
        end
    endcase
end

assign debug_state = state;
assign ctrlWord = {clear_comp,Load_LW,is_valid,set_SM_reg,clear_SM_reg,Load_comp,load_DMem_in_reg,Load_T1,load_alu_reg, load_DMem_out_reg, sel_MuxIR, Load_IR, Load_PC, Load_C_Flag, Load_Z_Flag, Load_RegFile, sel_RegFileAddrOut[1:0], alu_op_bit, sel_ALUInp1, sel_ALUInp2[1:0], sel_RegFileAddrInp[1:0], sel_RegFileInp[1:0], sel_MuxPCIncr, sel_MuxPCIn[1:0]};
assign {is_valid_out,SM_reg_out,cflag,zflag,eq} = status_signals;
endmodule 