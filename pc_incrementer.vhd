Library IEEE;
Use IEEE.Std_Logic_1164.all;
Use IEEE.Numeric_Std.all;


Entity pc_incrementer Is
		Port( 
				pc_out,mux_out:In Std_Logic_Vector(15 Downto 0);
				pc_in:Out Std_Logic_Vector(15 Downto 0)
			);
End Entity pc_incrementer;

Architecture arch Of pc_incrementer Is
Begin
		pc_in<=Std_Logic_Vector(To_Unsigned((To_Integer(Unsigned(pc_out))+To_Integer(Unsigned(mux_out))),16));
End Architecture arch;
