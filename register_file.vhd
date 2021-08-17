Library IEEE;
Use IEEE.Std_Logic_1164.all;
Use IEEE.Numeric_Std.all;
Use work.mypkg.all;
Entity register_file Is
		Port(	
				clk,resetn,Load:In Std_Logic;
				rf_add_out_1,rf_add_out_2,rf_add_in:In Std_Logic_Vector(2 Downto 0);
				data_inp:In Std_Logic_Vector(15 Downto 0);
				data_out1,data_out2:Out Std_Logic_vector(15 Downto 0);
				debug_reg_bus:Out reg_bus;
				PC_In_Signals:In Std_Logic_Vector(16 Downto 0);
				pc_out: Inout Std_Logic_Vector(15 Downto 0)
			);
End Entity register_file;

Architecture arch Of register_file Is
		Signal data_out,data_in: reg_bus;
		Signal PC_Load,l:Std_Logic;
		Signal load_Nreg:Std_Logic_Vector(7 Downto 0);
		Signal PC_Input:Std_Logic_Vector(15 Downto 0);
Begin
		gen_reg: For i In 0 To 6 Generate
				reg_16bit: Entity work.reg_Nbit Generic Map(16) Port Map(clk,resetn,(load_Nreg(i) And Load),data_inp,data_out(i));
		End Generate gen_reg;
		
		PC : ENTITY work.reg_Nbit GENERIC MAP(16) PORT MAP(clk, resetn,PC_In_Signals(16), PC_Input, pc_out);
		With  rf_add_in Select
			PC_Input<=data_inp When "111",
						 PC_In_Signals(15 Downto 0) When Others;	
						
		With rf_add_out_1 Select
		data_out1<=data_out(0) When "000",
					  data_out(1) When "001",
					  data_out(2) When "010",
					  data_out(3) When "011",
					  data_out(4) When "100",
					  data_out(5) When "101",
					  data_out(6) When "110",
					  pc_out When Others; 
					  
		With rf_add_out_2 Select
		data_out2<=data_out(0) When "000",
					  data_out(1) When "001",
					  data_out(2) When "010",
					  data_out(3) When "011",
					  data_out(4) When "100",
					  data_out(5) When "101",
					  data_out(6) When "110",
					  pc_out When Others; 
		
		With rf_add_in Select
		load_Nreg<="00000001" When "000",
					  "00000010" When "001",
					  "00000100" When "010",
					  "00001000" When "011",
					  "00010000" When "100",
					  "00100000" When "101",
					  "01000000" When "110",
					  "10000000" When Others;
					  
		debug_reg_bus<=data_out(0 To 6) & pc_out;
End Architecture arch;
