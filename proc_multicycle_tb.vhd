	Library IEEE;
Library work;
Use IEEE.Std_Logic_1164.all;
Use work.mypkg.all;

Entity proc_multicycle_tb Is
End Entity proc_multicycle_tb;

Architecture testbench Of proc_multicycle_tb Is
Signal clock,resetn:Std_Logic:='1';
Signal debug_cw:Std_Logic_Vector(28 Downto 0);
Signal debug_state: Std_Logic_Vector(3 Downto 0);
Signal debug_status_signals:Std_Logic_Vector(4 Downto 0);
Signal debug_reg_bus: reg_bus;
Begin
	uut:Entity work.proc_multicycle Port Map(clock,resetn,debug_state,debug_cw,debug_status_signals,debug_reg_bus);
	clk_process: Process Begin
	For i In 1 To 10000 Loop
	Wait For 10 ns;
	clock<=Not(clock);	
	End Loop;
	Wait;
	End Process clk_process;
	resetn<='0' After 19 ns,'1' After 21 ns;
End Architecture testbench;	
