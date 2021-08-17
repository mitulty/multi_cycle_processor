Library IEEE;
Use IEEE.Std_Logic_1164.all;
Use IEEE.Numeric_Std.all;

Entity alu Is
		Port( 
				op_bit:In Std_Logic;
				alu_1,alu_2:In Std_Logic_Vector(15 Downto 0);
				alu_out:Out Std_Logic_Vector(16 Downto 0)
			);
End Entity alu;

Architecture arch Of alu Is
Signal Sum: Integer;
Begin	
		Sum<=(To_Integer(Unsigned(alu_1))+To_Integer(Unsigned(alu_2)));
		With op_bit Select
		alu_out <= '0' & (alu_1 Nand alu_2) When '1',
						Std_Logic_Vector(To_Unsigned(Sum,17)) When Others;
End Architecture arch;
