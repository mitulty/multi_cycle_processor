Library IEEE;
Use IEEE.Std_Logic_1164.all;
Use IEEE.Numeric_Std.all;


Entity pcplusone Is
		Port( 
				pc_out:In Std_Logic_Vector(15 Downto 0);
				pc_plus_one:Out Std_Logic_Vector(15 Downto 0)
			);
End Entity pcplusone;

Architecture arch Of pcplusone Is
Signal one:Std_Logic_Vector(15 Downto 0):=(0=>'1',Others=>'0');
Begin
		pc_plus_one<=Std_Logic_Vector(To_Unsigned((To_Integer(Unsigned(pc_out))+To_Integer(Unsigned(one))),16));
End Architecture arch;
