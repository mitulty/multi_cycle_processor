Library IEEE;
Use IEEE.Std_Logic_1164.all;
Use work.mypkg.all;

Entity proc_multicycle Is
		Port(
			 clk,resetn: In Std_Logic;
			 debug_state:Out Std_Logic_vector(3 Downto 0);
			 debug_cw: Out Std_Logic_Vector(28 Downto 0);
			 debug_status_signals:Out Std_Logic_Vector(4 Downto 0);
			 debug_reg_bus:Out reg_bus
		    );
End Entity proc_multicycle;

Architecture struc Of proc_multicycle Is
Signal rom_data,ram_data_in,ram_data_out: Std_Logic_Vector(15 Downto 0);
Signal rom_address, ram_address: Std_Logic_Vector(15 DOWNTO 0);
Signal DMem_wr: Std_Logic;
Component ram Is 
					port (inp:In Std_Logic_Vector(15 Downto 0);
					address: In Std_logic_vector(15 Downto 0);
					load,clk:In Std_logic;
					outp:Out Std_Logic_Vector(15 Downto 0)
					);
End Component ram;

Component rom Is 
					port (clk:In Std_logic;
					address: In Std_logic_vector(15 Downto 0);
					outp:Out Std_Logic_Vector(15 Downto 0)
					);
End Component rom;
					
Begin
	 CPU: Entity work.cpu Port Map(clk,resetn,ram_data_out,rom_data,debug_cw,debug_state,ram_data_in,rom_address,ram_address,DMem_wr,debug_status_signals,debug_reg_bus);
    i:ram Port Map(inp=>ram_data_in,address=>ram_address,load=>DMem_wr,clk=>clk,outp=>ram_data_out);
    j:rom Port Map(clk=>clk,address=>rom_address,outp=>rom_data);
End Architecture struc;	
