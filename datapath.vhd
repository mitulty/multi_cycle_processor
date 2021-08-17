LIBRARY IEEE;
USE IEEE.Std_Logic_1164.ALL;
USE work.mypkg.all; 

ENTITY datapath IS
PORT   (
		clock, resetn : IN Std_Logic;
		control_word : IN Std_Logic_Vector(28 DOWNTO 0);
		ram_data_out, rom_data : IN Std_Logic_Vector(15 DOWNTO 0);
		ram_address, rom_address, ram_data_in,Instruction : OUT Std_Logic_Vector(15 DOWNTO 0);
		status_signals : OUT Std_Logic_Vector(4 DOWNTO 0);
		debug_reg_bus:Out reg_bus
	    );
END ENTITY datapath;

ARCHITECTURE struct OF datapath IS
	SIGNAL pc_in, mux_pc_incr, T1_out,IR_input,pc_out,pc_plus_one: Std_Logic_Vector(15 DOWNTO 0);
	SIGNAL IR_Out : Std_Logic_Vector(15 DOWNTO 0);
	SIGNAL rf_add_out_1, rf_add_out_2, rf_add_in, pe_out : Std_Logic_Vector(2 DOWNTO 0);
	SIGNAL data_inp, data_out1, data_out2,dmemout,d: Std_Logic_vector(15 DOWNTO 0);
	SIGNAL comp_out,SM_Reg_Out : Std_Logic;
	SIGNAL is_valid_out : std_logic_vector(0 downto 0);
	SIGNAL flags_in, flags: Std_Logic_Vector(1 DOWNTO 0);
	SIGNAL alu_reg_1,alu_reg_2,alu_1, alu_2 : Std_Logic_Vector(15 DOWNTO 0);
	SIGNAL alu_out : Std_Logic_Vector(16 DOWNTO 0);
	SIGNAL mux_pc_reg : Std_Logic_Vector(15 DOWNTO 0);
	SIGNAL PC_In_Signals:Std_Logic_Vector(16 DOWNTO 0);
	ALIAS sel_MuxPCIn Is control_word(1 DOWNTO 0);
	ALIAS sel_MuxPCIncr Is control_word(2);
	ALIAS sel_RegFileInp Is control_word(4 DOWNTO 3);
	ALIAS sel_RegFileAddrInp Is control_word(6 DOWNTO 5);
	ALIAS sel_ALUInp2 Is control_word(8 DOWNTO 7);
	ALIAS sel_ALUInp1 Is control_word(9);
	ALIAS alu_operation_bit  Is control_word(10);
	ALIAS sel_RegFileAddrOut:Std_Logic_Vector(1 DOWNTO 0) Is control_word(12 DOWNTO 11);
	ALIAS Load_RegFile Is control_word(13);
	ALIAS Load_Z_Flag Is control_word(14);
	ALIAS Load_C_Flag Is control_word(15);
	ALIAS Load_PC Is control_word(16);
	ALIAS Load_IR Is control_word(17);
	ALIAS sel_MuxIR Is control_word(18);
	ALIAS Load_DMem_out_reg Is control_word(19);
	ALIAS Load_alu_reg Is control_word(20);
	ALIAS Load_T1 Is control_word(21);
	ALIAS Load_DMem_in_reg Is control_word(22);
	ALIAS Load_comp Is control_word(23);
	ALIAS Clear_SM_Reg IS control_word(24);
	ALIAS Set_SM_Reg IS control_word(25);
	ALIAS is_valid IS control_word(26 downto 26);
	ALIAS Load_LW IS control_word(27);
	ALIAS clear_comp IS control_word(28);
BEGIN
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	status_signals <= is_valid_out & SM_Reg_Out & flags & comp_out;
	Instruction<=IR_Out;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	Reg_File : ENTITY work.register_file PORT MAP(clock, resetn, Load_RegFile, rf_add_out_1, rf_add_out_2, rf_add_in, data_inp, data_out1, data_out2,debug_reg_bus,PC_In_Signals,pc_out);
	ALU : ENTITY work.alu PORT MAP(alu_operation_bit, alu_1, alu_2, alu_out);
	ALU_INP1_REG: ENTITY work.reg_Nbit GENERIC MAP(16) PORT MAP(clock, resetn,Load_alu_reg,alu_reg_1,alu_1);
	ALU_INP2_REG: ENTITY work.reg_Nbit GENERIC MAP(16) PORT MAP(clock, resetn,Load_alu_reg,alu_reg_2,alu_2);
	DMEM_OUT_REG: ENTITY work.reg_Nbit GENERIC MAP(16) PORT MAP(clock, resetn,Load_DMem_out_reg,ram_data_out ,dmemout );
	DMEM_IN_REG:  ENTITY work.reg_Nbit GENERIC MAP(16) PORT MAP(clock, resetn,Load_DMem_in_reg,data_out2,ram_data_in);	
	T1 : ENTITY work.reg_Nbit GENERIC MAP(16) PORT MAP(clock, resetn, Load_T1, alu_out(15 DOWNTO 0), T1_out);
	PC_Incr : ENTITY work.pc_incrementer PORT MAP(pc_out, mux_pc_incr, pc_in);
	IR : ENTITY work.reg_Nbit GENERIC MAP(16) PORT MAP(clock, resetn, Load_IR, IR_input, IR_Out);

	C_Flags : ENTITY work.reg_Nbit GENERIC MAP(1) PORT MAP(clock, resetn, Load_C_Flag, flags_in(1 downto 1), flags(1 downto 1));
	Z_Flags : ENTITY work.reg_Nbit GENERIC MAP(1) PORT MAP(clock, resetn, Load_Z_Flag, flags_in(0 downto 0), flags(0 downto 0));
	valid_reg: ENTITY work.reg_Nbit GENERIC MAP(1) PORT MAP(clock, resetn, '1', is_valid, is_valid_out);

	Comparator : ENTITY work.comp PORT MAP(data_out1, data_out2,clock,clear_comp,Load_comp,comp_out);
	PC_Incr_One: ENTITY work.pcplusone PORT MAP(pc_out,pc_plus_one);
	Priority_Encoder : ENTITY work.priority_encoder PORT MAP(IR_Out(7 DOWNTO 0), pe_out);
	SM_Flag_Reg: ENTITY work.reg_1bit PORT MAP(clock,Clear_SM_Reg,Set_SM_Reg,SM_Reg_Out);
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	PC_In_Signals<=Load_PC & mux_pc_reg;
	ram_address <= T1_out;
	rom_address <= mux_pc_reg;

	--flags: store the current flags
	--prev_flags: store the flags of last executed instruction

	---Z Flag
	flags_in(0) <= '1' WHEN (alu_out = "00000000000000000" OR (ram_data_out = "0000000000000000" And Load_LW='1')) ELSE '0';

	---C Flag
	flags_in(1) <= alu_out(16);

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	-- *** MuxPCIncr
	WITH sel_MuxPCIncr SELECT
	mux_pc_incr <= ("0000000000" & IR_Out(5 DOWNTO 0)) WHEN '1',
		       ("0000000" & IR_Out(8 DOWNTO 0)) WHEN OTHERS;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- *** MuxPC
	mux_sel_MuxPCIn:ENTITY work.Big_MUX GENERIC MAP(16) PORT MAP(sel_MuxPCIn,data_out1,pc_in,pc_plus_one,pc_in,mux_pc_reg);
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- *** Connect IR_Out(11:9) and IR_Out(8:6) to different addr inputs. connect pe_out with 8:6
	WITH sel_RegFileAddrOut(1) SELECT
	rf_add_out_1 <= IR_Out(11 DOWNTO 9) WHEN '1',
						 IR_Out(8 DOWNTO 6) WHEN OTHERS;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

	mux_sel_RegFileAddrOut:ENTITY work.Big_MUX GENERIC MAP(3) PORT MAP(sel_RegFileAddrOut,IR_Out(8 DOWNTO 6),pe_out,IR_Out(11 DOWNTO 9),IR_Out(11 DOWNTO 9),rf_add_out_2);	 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

	
	-- *** ALU Input 1
	WITH sel_ALUInp1 SELECT
	alu_reg_1 <= alu_out(15 Downto 0) WHEN '1',
					 data_out1 WHEN OTHERS;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- *** ALU Input 2
	mux_sel_ALUInp2: ENTITY work.Big_MUX GENERIC MAP(16) PORT MAP(sel_ALUInp2,"0000000000" & IR_Out(5 DOWNTO 0),(0 => '1', OTHERS => '0'),(Others=>'0'),data_out2,alu_reg_2);				 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
					 
	-- *** Register File address(for data in) Input			 
   mux_rf_add_in: ENTITY work.Big_MUX GENERIC MAP(3) PORT MAP(sel_RegFileAddrInp,IR_Out(5 DOWNTO 3),IR_Out(11 DOWNTO 9),pe_out,IR_Out(8 DOWNTO 6),rf_add_in);
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- *** Register File Data input
  mux_sel_RegFileInp: ENTITY work.Big_MUX GENERIC MAP(16) PORT MAP(sel_RegFileInp,T1_out,pc_plus_one,dmemout,IR_Out(8 DOWNTO 0) & "0000000",data_inp);					
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- ** All the addresses
	--*****For Memories
	-- *** IR logic --Sel_Mux_IR
	Mmux_pe: ENTITY work.MUX_PE PORT MAP(pe_out,IR_Out,d);	
	
	With sel_MuxIR Select
		IR_input<= d When '1',
		           rom_data When Others;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
					
	-- give priority encoder's output to a decoder
	-- invert the bits of decoder's output
	-- AND it with lower 8 bits of IR_Out
	
END ARCHITECTURE struct;
