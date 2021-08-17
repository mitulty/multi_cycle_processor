LIBRARY IEEE;
USE IEEE.Std_Logic_1164.ALL;

ENTITY reg_1bit IS
	PORT (
		clk, clear, set : IN Std_Logic;
		data_out : OUT Std_Logic
	);
END ENTITY reg_1bit;

ARCHITECTURE arch OF reg_1bit IS
BEGIN
	PROCESS
	BEGIN
		WAIT UNTIL clk'Event AND clk = '1';
		IF (clear = '1') THEN
			data_out <= '0';
		ELSIF (set = '1') THEN
			data_out <= '1';
		END IF;
	END PROCESS;
END ARCHITECTURE arch;