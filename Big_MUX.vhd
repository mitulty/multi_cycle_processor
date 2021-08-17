Library IEEE;
Use IEEE.Std_Logic_1164.all;

Entity Big_MUX Is
	Generic(N:Integer:=4);
	Port(
			sel_Line: In Std_Logic_Vector(1 Downto 0);
			data1,data2,data3,data4:In Std_Logic_Vector(N-1 Downto 0);
			data_out:Out Std_Logic_Vector(N-1 Downto 0)
		 );
End Entity Big_MUX;

Architecture arch Of Big_MUX Is
Begin
			With sel_Line Select
			data_out<=data1 When "11",
						 data2 When "10",
						 data3 When "01",
						 data4 When Others;
End Architecture arch;						 