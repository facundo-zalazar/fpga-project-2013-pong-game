-- CODIGO QUE CONTROLA UN DISPLAY DE 7 SEGMENTOS

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Entidad

entity siete_segmentos is
	port(
			input : in integer range 0 to 10;
			seg_output : out unsigned(6 downto 0)
	);
end entity siete_segmentos;

-- Arquitectura

architecture decodificador of siete_segmentos is
signal salida : unsigned (6 downto 0); -- señal temporal
begin
					  --0123456
	salida <= (NOT "1111110") when input = 0 else 
				 (NOT "0110000") when input = 1 else
				 (NOT "1101101") when input = 2 else
				 (NOT "1111001") when input = 3 else
				 (NOT "0110011") when input = 4 else
				 (NOT "1011011") when input = 5 else
				 (NOT "1011111") when input = 6 else
				 (NOT "1110000") when input = 7 else
				 (NOT "1111111") when input = 8 else
				 (NOT "1110011") when input = 9 else
				 salida;
	
	seg_output <= salida;
	
end decodificador;