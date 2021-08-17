Library IEEE;
Use IEEE.Std_Logic_1164.all;

Entity MUX_PE Is
	Port(
			pe_out: In Std_Logic_Vector(2 Downto 0);
			IR_Out: In Std_Logic_Vector(15 Downto 0);
			d: Out Std_Logic_Vector(15 Downto 0)
		 );
End Entity MUX_PE;

Architecture arch Of MUX_PE Is
Signal d_out:Std_Logic_Vector(7 Downto 0);
Begin
			
	With pe_out Select
	d_out<="11111110" When "000",
	   "11111101" When "001",
		"11111011" When "010",
		"11110111" When "011",
		"11101111" When "100",
		"11011111" When "101",
		"10111111" When "110",
		"01111111" When Others;
	d<=(IR_Out(15 Downto 8) & d_out) And IR_Out;
End Architecture arch;						 