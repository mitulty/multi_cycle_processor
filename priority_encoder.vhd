Library IEEE;  
Use IEEE.Std_Logic_1164.all;  
 
Entity priority_encoder Is  
			Port ( 
					sel : In Std_Logic_Vector (7 Downto 0);  
					code :Out Std_Logic_Vector (2 Downto 0)
					);  
End priority_encoder;  
Architecture archi Of priority_encoder Is  
Begin  
  code <= "000" when sel(0) = '1' else  
          "001" when sel(1) = '1' else  
          "010" when sel(2) = '1' else  
          "011" when sel(3) = '1' else  
          "100" when sel(4) = '1' else  
          "101" when sel(5) = '1' else  
          "110" when sel(6) = '1' else  
          "111" when sel(7) = '1' else  
          "---";  
End archi; 