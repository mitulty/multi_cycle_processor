Library IEEE;
Use IEEE.Std_Logic_1164.all;
Use work.mypkg.all;
Entity cpu Is
		Port(
			 clk,resetn: In Std_Logic;
			 ram_data_out,rom_data:In Std_Logic_Vector(15 Downto 0);
			 debug_cw:Out Std_Logic_Vector(28 Downto 0);
			 debug_state:Out Std_Logic_vector(3 Downto 0);
			 ram_data_in,rom_address, ram_address:Out Std_Logic_Vector(15 DOWNTO 0);
			 DMem_wr:Out Std_Logic;
			 debug_status_signals:Out Std_Logic_Vector(4 Downto 0);
          debug_reg_bus:Out reg_bus
		    );
End Entity cpu;

Architecture struc Of cpu Is
Signal status_signals: Std_Logic_Vector(4 Downto 0);
Signal control_word: Std_Logic_Vector(28 Downto 0);
Signal IR_Out:Std_Logic_Vector(15 Downto 0);
Component controller Is
		Port(
				instruction:In Std_Logic_Vector(15 Downto 0);
				resetn,clk: In Std_Logic;
				status_signals:In Std_Logic_Vector(4 Downto 0);
				ctrlWord:Out Std_Logic_Vector(28 Downto 0);
				DMem_wr:Out Std_Logic;
				debug_state:Out Std_Logic_Vector(3 Downto 0)
				);
End Component controller;				
					
Begin
	 debug_cw<=control_word;
	 debug_status_signals<=status_signals;
	 Datapath: Entity work.datapath Port Map(clk,resetn,control_word,ram_data_out,rom_data,ram_address,rom_address,ram_data_in,IR_Out,status_signals,debug_reg_bus);
	 k:controller Port map(IR_Out,resetn,clk,status_signals,control_word,DMem_wr,debug_state);
End Architecture struc;	
