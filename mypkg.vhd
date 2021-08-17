Library IEEE;
Use IEEE.Std_Logic_1164.all;

Package mypkg Is
	type reg_bus Is Array(0 To 7) Of Std_Logic_Vector(15 Downto 0);
End Package mypkg;	
