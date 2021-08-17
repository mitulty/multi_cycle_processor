library IEEE ;
use IEEE.Std_Logic_1164.all ; 
use IEEE.Std_Logic_Unsigned.all ;
use IEEE.Numeric_Std.all;
Entity comp Is
  Port ( A, B : In Std_Logic_Vector(15 Downto 0) ;
			clk,clear,Load : In Std_Logic;
         AeqB: Out Std_Logic
		 );
End Entity comp ;
Architecture a1 Of comp Is
Signal Op: Std_Logic;
Begin
	
	Process(clk)
	Begin
		If (clk'Event And clk='1') Then
		If(clear='1') Then AeqB<='0';
		Elsif(Load='1') Then AeqB<=Op;
		End If;
		End If;
	End Process;	
	Op<= '1' When A=B Else '0' ;
End Architecture a1 ;
