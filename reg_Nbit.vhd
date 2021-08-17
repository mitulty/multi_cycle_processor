Library IEEE;
Use IEEE.Std_Logic_1164.all;

Entity reg_Nbit Is
		Generic(N:Natural:=16);
		Port( 
				clk,resetn,Load: In Std_Logic;
				data_in: In Std_Logic_Vector(N-1 Downto 0);
				data_out: Out Std_Logic_Vector(N-1 Downto 0)
		    );
End Entity reg_Nbit;

Architecture arch Of reg_Nbit Is
Begin
		Process
		Begin
				Wait Until clk'Event And clk='1';
				If(resetn='0') Then
					data_out<=(Others=>'0');
				Elsif(Load='1') Then
					data_out<=data_in;
				End If;
		End Process;
End Architecture arch;
