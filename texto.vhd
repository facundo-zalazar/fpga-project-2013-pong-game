library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Entidad
entity texto is
	port (clk, reset, multiplayer : in std_logic;
			e0,e1,e2,e3,e4,e5,e6,e7 : in integer range 0 to 10; --salidas en entero del puntaje, ahora son entradas para mostrarlos en pantalla
			p_max0, p_max1, p_max2, p_max3 : in integer range 0 to 10;
			pixel_x, pixel_y : in std_logic_vector (9 downto 0);
			bandera_1 : in std_logic;										--1 El juego ha terminado, 0 Juego (1 jugador)
			bandera_2 : in integer range 0 to 10;						--0 Juego, 1 GANO P1, 2 GANO P2
			text_rgb : out std_logic_vector (2 downto 0));
			
end texto;

--Arquitectura
architecture arch of texto is
	signal pix_x, pix_y : unsigned (9 downto 0); 		--Coordenadas X e Y
	signal rom_addr : std_logic_vector (10 downto 0);
	 
	signal char_addr, char_addr_titulo1: std_logic_vector (6 downto 0); --Signals para mostrar el titulo
	signal row_addr, row_addr_titulo1 : std_logic_vector (3 downto 0);
	signal bit_addr, bit_addr_titulo1 : std_logic_vector (2 downto 0);
	
	signal char_addr_titulo2: std_logic_vector (6 downto 0); --Signals para mostrar el titulo
	signal row_addr_titulo2 : std_logic_vector (3 downto 0);
	signal bit_addr_titulo2 : std_logic_vector (2 downto 0);
	
	signal char_addr_logo: std_logic_vector (6 downto 0); --Signals para mostrar el logo
	signal row_addr_logo : std_logic_vector (3 downto 0);
	signal bit_addr_logo : std_logic_vector (2 downto 0);
	
	signal char_addr_over: std_logic_vector (6 downto 0); --Signals para mostrar el fin de juego (1 jugador)
	signal row_addr_over : std_logic_vector (3 downto 0);
	signal bit_addr_over: std_logic_vector (2 downto 0);
	
	signal char_addr_puntaje_player1: std_logic_vector (6 downto 0); --Signals para mostrar el puntaje del jugador 1
	signal row_addr_puntaje_player1: std_logic_vector (3 downto 0);
	signal bit_addr_puntaje_player1 : std_logic_vector (2 downto 0);
	
	signal char_addr_puntaje_player2: std_logic_vector (6 downto 0); --Signals para mostrar el puntaje del jugador 2
	signal row_addr_puntaje_player2: std_logic_vector (3 downto 0);
	signal bit_addr_puntaje_player2 : std_logic_vector (2 downto 0);
	
	signal char_addr_over_player: std_logic_vector (6 downto 0); --Signals para mostrar el fin de juego (2 jugadores)
	signal row_addr_over_player: std_logic_vector (3 downto 0);
	signal bit_addr_over_player : std_logic_vector (2 downto 0);
	
	signal char_addr_puntaje_max: std_logic_vector (6 downto 0); --Signals para mostrar el puntaje maximo (1 jugador)
	signal row_addr_puntaje_max: std_logic_vector (3 downto 0);
	signal bit_addr_puntaje_max : std_logic_vector (2 downto 0);
	
	signal char_addr_nombre1: std_logic_vector (6 downto 0); --Signals para mostrar el puntaje maximo (1 jugador)
	signal row_addr_nombre1: std_logic_vector (3 downto 0);
	signal bit_addr_nombre1 : std_logic_vector (2 downto 0);
	
	signal char_addr_nombre2: std_logic_vector (6 downto 0); --Signals para mostrar el puntaje maximo (1 jugador)
	signal row_addr_nombre2: std_logic_vector (3 downto 0);
	signal bit_addr_nombre2 : std_logic_vector (2 downto 0);
	
	signal char_addr_nombre3: std_logic_vector (6 downto 0); --Signals para mostrar el puntaje maximo (1 jugador)
	signal row_addr_nombre3: std_logic_vector (3 downto 0);
	signal bit_addr_nombre3 : std_logic_vector (2 downto 0);

	signal font_word : std_logic_vector (7 downto 0);
	signal font_bit, titulo, logo_on, titulo2, puntaje_max,
			 puntaje_player1, puntaje_player2, over_player, over_on, nombre1, nombre2, nombre3 : std_logic;
	signal rule_rom_addr : unsigned (5 downto 0);
	
	signal temp0, temp1, temp2, temp3, temp4, 
			 temp5, temp6, temp7, temp8, temp9,
			 temp10, temp11, temp12 : std_logic_vector (6 downto 0);
	signal band_2 : integer range 0 to 10;
	signal band_1 : std_logic;
	signal mult : std_logic := '0';
	
	begin 
		pix_x <= unsigned(pixel_x);
		pix_y <= unsigned(pixel_y);
		band_2 <= bandera_2;
		band_1 <= bandera_1;
		mult <= multiplayer;
		
		--Instanciacion de la font ROM
		font_unit : entity work.font_rom
			port map (clk => clk, addr => rom_addr, data => font_word);
			
			-------------------------------- TEXTO SUPERIOR, PRIMER RENGLON -----------------------------------
			
			titulo <= -- 
				'1' when (pix_y (9 downto 4) = 0)   and 											--9 downto 5 significa 2^(n-1) = 2^(9-4 - 1)= BLOQUE DE 16 PIXELES
																												--Quiero que salga entre y = 0 e y = 8 (si pongo y=16 se imprime 2 veces)
							(pix_x (9 downto 4) >= 16) and (pix_x (9 downto 4) < 32) else	--9 downto 4 significa 2^(9-4 - 1) = BLOQUE DE 16 pixeles
																												--Entre el bloque 8 y el 16
				'0';
				
			row_addr_titulo1 <= std_logic_vector(pix_y(3 downto 0));  -- escala : (4 downto 1), mas grande (3 downto 0) mas chica
			bit_addr_titulo1 <= std_logic_vector(pix_x(2 downto 0));
			
	
			with pix_x (7 downto 3) select 
				char_addr_titulo1 <= 
					
					"1010100" when "00000",--T
					"1100101" when "00001",--e
					"1100011" when "00010",--c
					"1101110" when "00011",--n
					"1101001" when "00100",--i
					"1100011" when "00101",--c
					"1100001" when "00110",--a
					"1110011" when "00111",--s
					
					"0000000" when "01000",--
					
					"1000100" when "01001",--D
					"1101001" when "01010",--i
					"1100111" when "01011",--g
					"1101001" when "01100",--i
					"1110100" when "01101",--t
					"1100001" when "01110",--a
					"1101100" when "01111",--l
					"1100101" when "10000",--e
					"1110011" when "10001",--s
					
					"0000000" when "10010",--
					
					"0110001" when "10011",--1	
					
					"0000000" when others;
					
				-------------------------------- TEXTO SUPERIOR, SEGUNDO RENGLON -----------------------------------
					
				titulo2 <= 
				'1' when (pix_y (9 downto 4) = 1)   and 											--9 downto 5 significa 2^(n-1) = 2^(9-4 - 1)= BLOQUE DE 16 PIXELES
																												--Quiero que salga entre y = 0 e y = 8 (si pongo y=16 se imprime 2 veces)
							(pix_x (9 downto 4) >= 16) and (pix_x (9 downto 4) < 32) else	--9 downto 4 significa 2^(9-4 - 1) = BLOQUE DE 16 pixeles
																												--Entre el bloque 8 y el 16
				'0';
				
			row_addr_titulo2 <= std_logic_vector(pix_y(3 downto 0));  -- escala : (4 downto 1), mas grande (3 downto 0) mas chica
			bit_addr_titulo2 <= std_logic_vector(pix_x(2 downto 0));
			
	
			with pix_x (7 downto 3) select 
				char_addr_titulo2 <= 
					
					"1010000" when "00000",--P
					"1110010" when "00001",--r
					"1101111" when "00010",--o
					"1111001" when "00011",--y
					"1100101" when "00100",--e
					"1100011" when "00101",--c
					"1110100" when "00110",--t
					"1101111" when "00111",--o
					
					"0000000" when "01000",--
					
					"1000110" when "01001",--F
					"1101001" when "01010",--i
					"1101110" when "01011",--n
					"1100001" when "01100",--a
					"1101100" when "01101",--l
					
					"0000000" when others;
					
								-------------------------------PUNTAJE MAXIMO ----------------------------------
			
					puntaje_max <= 
						'1' when (pix_y (9 downto 4) = 1)   and 											--9 downto 5 significa 2^(n-1) = 2^(9-4 - 1)= BLOQUE DE 16 PIXELES
																														--Quiero que salga entre y = 0 e y = 8 (si pongo y=16 se imprime 2 veces)
									(pix_x (9 downto 4) >= 0) and (pix_x (9 downto 4) < 16) else	--9 downto 4 significa 2^(9-4 - 1) = BLOQUE DE 16 pixeles
																														--Entre el bloque 8 y el 16
						'0';
						
					row_addr_puntaje_max <= std_logic_vector(pix_y(3 downto 0));  -- escala : (4 downto 1), mas grande (3 downto 0) mas chica
					bit_addr_puntaje_max  <= std_logic_vector(pix_x(2 downto 0));
					
					
					with p_max0 select 
						temp9  <= 
							
							"0110000" when 0,
							"0110001" when 1,
							"0110010" when 2,
							"0110011" when 3,
							"0110100" when 4,
							"0110101" when 5,
							"0110110" when 6,
							"0110111" when 7,
							"0111000" when 8,
							"0111001" when others;
							
					with p_max1 select 
						temp10  <= 
							
							"0110000" when 0,
							"0110001" when 1,
							"0110010" when 2,
							"0110011" when 3,
							"0110100" when 4,
							"0110101" when 5,
							"0110110" when 6,
							"0110111" when 7,
							"0111000" when 8,
							"0111001" when others;
					
					with p_max2 select 
						temp11  <= 
							
							"0110000" when 0,
							"0110001" when 1,
							"0110010" when 2,
							"0110011" when 3,
							"0110100" when 4,
							"0110101" when 5,
							"0110110" when 6,
							"0110111" when 7,
							"0111000" when 8,
							"0111001" when others;
							
					with p_max3 select 
						temp12  <= 
							
							"0110000" when 0,
							"0110001" when 1,
							"0110010" when 2,
							"0110011" when 3,
							"0110100" when 4,
							"0110101" when 5,
							"0110110" when 6,
							"0110111" when 7,
							"0111000" when 8,
							"0111001" when others;
					
					
					with pix_x (7 downto 3) select 
						char_addr_puntaje_max <= 
							
							"1010000" when "00000",--P
							"1110101" when "00001",--u
							"1101110" when "00010",--n
							"1110100" when "00011",--t
							"1100001" when "00100",--a
							"1101010" when "00101",--j
							"1100101" when "00110",--e
							
							"0000000" when "00111",--
							
							"1001101" when "01000",--M
							"1100001" when "01001",--a
							"1111000" when "01010",--x
							"1101001" when "01011",--i
							"1101101" when "01100",--m
							"1101111" when "01101",--o
							"0000000" when "01110",--:
							
							"0000000" when "01111",--
							
								temp12 when "10000",
								temp11 when "10001",
								temp10 when "10010",
								temp9 when "10011",
							
							"0000000" when others;
					
				-------------------------------- LOGO DE PONG EN EL CENTRO -----------------------------------	
					
					
				logo_on <= 
					'1' when pix_y (9 downto 7)= 1 and 
						 (3<= pix_x (9 downto 6) and pix_x (9 downto 6)<=6) else
				   '0';
					
			row_addr_logo <= std_logic_vector(pix_y(6 downto 3));
			bit_addr_logo <= std_logic_vector(pix_x(5 downto 3));
			
			with pix_x(8 downto 6) select 
				char_addr_logo <=
						"1010000" when "011", --P
						"1001111" when "100", --O
						"1001110" when "101", --N
						"1000111" when others; --G
				
				
			-------------------------------- PUNTAJE DEL JUGADOR 1 -----------------------------------
			
			
			
			
					
				puntaje_player1 <= 
				'1' when (pix_y (9 downto 4) = 1)   and 											--9 downto 5 significa 2^(n-1) = 2^(9-4 - 1)= BLOQUE DE 16 PIXELES
																												--Quiero que salga entre y = 0 e y = 8 (si pongo y=16 se imprime 2 veces)
							(pix_x (9 downto 4) >= 0) and (pix_x (9 downto 4) < 16) else	--9 downto 4 significa 2^(9-4 - 1) = BLOQUE DE 16 pixeles
																												--Entre el bloque 8 y el 16
				'0';
				
			row_addr_puntaje_player1 <= std_logic_vector(pix_y(3 downto 0));  -- escala : (4 downto 1), mas grande (3 downto 0) mas chica
			bit_addr_puntaje_player1  <= std_logic_vector(pix_x(2 downto 0));
			
			
			with e0 select 
				temp0  <= 
					
					"0110000" when 0,
					"0110001" when 1,
					"0110010" when 2,
					"0110011" when 3,
					"0110100" when 4,
					"0110101" when 5,
					"0110110" when 6,
					"0110111" when 7,
					"0111000" when 8,
					"0111001" when others;
					
			with e1 select 
				temp1  <= 
					
					"0110000" when 0,
					"0110001" when 1,
					"0110010" when 2,
					"0110011" when 3,
					"0110100" when 4,
					"0110101" when 5,
					"0110110" when 6,
					"0110111" when 7,
					"0111000" when 8,
					"0111001" when others;
			
			with e2 select 
				temp2  <= 
					
					"0110000" when 0,
					"0110001" when 1,
					"0110010" when 2,
					"0110011" when 3,
					"0110100" when 4,
					"0110101" when 5,
					"0110110" when 6,
					"0110111" when 7,
					"0111000" when 8,
					"0111001" when others;
					
			with e3 select 
				temp3  <= 
					
					"0110000" when 0,
					"0110001" when 1,
					"0110010" when 2,
					"0110011" when 3,
					"0110100" when 4,
					"0110101" when 5,
					"0110110" when 6,
					"0110111" when 7,
					"0111000" when 8,
					"0111001" when others;
			
			
			with pix_x (7 downto 3) select 
				char_addr_puntaje_player1  <= 
					
					"1001010" when "00000",--J
					"1110101" when "00001",--u
					"1100111" when "00010",--g
					"1100001" when "00011",--a
					"1100100" when "00100",--d
					"1101111" when "00101",--o
					"1110010" when "00110",--r
					
					"0000000" when "00111",--
					
					"0110001" when "01000",--1
					
					"0000000" when "01001",--
					
					temp3 when "01010",
					temp2 when "01011",
					temp1 when "01100",
					temp0 when "01101",
					
					"0000000" when others;
						
			-------------------------------- PUNTAJE DEL JUGADOR 2 -----------------------------------
			
			
			
			
					
				puntaje_player2 <= 
				'1' when (pix_y (9 downto 4) = 1)   and 											--9 downto 5 significa 2^(n-1) = 2^(9-4 - 1)= BLOQUE DE 16 PIXELES
																												--Quiero que salga entre y = 0 e y = 8 (si pongo y=16 se imprime 2 veces)
							(pix_x (9 downto 4) >= 32) and (pix_x (9 downto 4) < 48) else	--9 downto 4 significa 2^(9-4 - 1) = BLOQUE DE 16 pixeles
																												--Entre el bloque 8 y el 16
				'0';
				
			row_addr_puntaje_player2 <= std_logic_vector(pix_y(3 downto 0));  -- escala : (4 downto 1), mas grande (3 downto 0) mas chica
			bit_addr_puntaje_player2  <= std_logic_vector(pix_x(2 downto 0));
			
			
			with e4 select 
				temp4  <= 
					
					"0110000" when 0,
					"0110001" when 1,
					"0110010" when 2,
					"0110011" when 3,
					"0110100" when 4,
					"0110101" when 5,
					"0110110" when 6,
					"0110111" when 7,
					"0111000" when 8,
					"0111001" when others;
					
			with e5 select 
				temp5  <= 
					
					"0110000" when 0,
					"0110001" when 1,
					"0110010" when 2,
					"0110011" when 3,
					"0110100" when 4,
					"0110101" when 5,
					"0110110" when 6,
					"0110111" when 7,
					"0111000" when 8,
					"0111001" when others;
			
			with e6 select 
				temp6  <= 
					
					"0110000" when 0,
					"0110001" when 1,
					"0110010" when 2,
					"0110011" when 3,
					"0110100" when 4,
					"0110101" when 5,
					"0110110" when 6,
					"0110111" when 7,
					"0111000" when 8,
					"0111001" when others;
					
			with e7 select 
				temp7  <= 
					
					"0110000" when 0,
					"0110001" when 1,
					"0110010" when 2,
					"0110011" when 3,
					"0110100" when 4,
					"0110101" when 5,
					"0110110" when 6,
					"0110111" when 7,
					"0111000" when 8,
					"0111001" when others;
			
			
			with pix_x (7 downto 3) select 
				char_addr_puntaje_player2  <= 
					
					"1001010" when "00000",--J
					"1110101" when "00001",--u
					"1100111" when "00010",--g
					"1100001" when "00011",--a
					"1100100" when "00100",--d
					"1101111" when "00101",--o
					"1110010" when "00110",--r
					
					"0000000" when "00111",--
					
					"0110010" when "01000",--2
					
					"0000000" when "01001",--
					
					temp7 when "01010",
					temp6 when "01011",
					temp5 when "01100",
					temp4 when "01101",
					
					"0000000" when others;
					
					-------------------------------FIN DEL JUEGO (1 JUGADOR)----------------------------------
			
			over_on <=
							'1' when pix_y(9 downto 6)= 3 and
										5 <= pix_x(9 downto 5) and pix_x (9 downto 5) <= 13 else
							'0';
							
			row_addr_over <= std_logic_vector(pix_y(5 downto 2));
			bit_addr_over <= std_logic_vector(pix_x(4 downto 2));
			
			with pix_x (8 downto 5) select
				char_addr_over <=
					"1000111" when "0101", --G
					"1100001" when "0110", --a
					"1101101" when "0111", --m
					"1100101" when "1000", --e
					"0000000" when "1001", --
					"1001111" when "1010", --O
					"1110110" when "1011", --v
					"1100101" when "1100", --e
					"1110010" when others; --r
					
					-------------------------------FIN DEL JUEGO (2 JUGADORES)----------------------------------
			
			over_player <=
							'1' when pix_y(9 downto 6)= 3 and
										0 <= pix_x(9 downto 5) and pix_x (9 downto 5) <= 16 else
							'0';
							
			row_addr_over_player <= std_logic_vector(pix_y(5 downto 2));
			bit_addr_over_player <= std_logic_vector(pix_x(4 downto 2));
			
			with band_2 select 
			temp8 <=
					"0110001" when 1,
					"0110010" when 2,
					"0110000" when others;
			
			with pix_x (8 downto 5) select
				char_addr_over_player <=
					"0000000" when "0000", --
					"1001010" when "0001", --J
					"1110101" when "0010", --u
					"1100111" when "0011", --g
					"1100001" when "0100", --a
					"1100100" when "0101", --d
					"1101111" when "0110", --o
					"1110010" when "0111", --r
					"0000000" when "1000", --
						temp8  when "1001", --1 o 2
					"0000000" when "1010", --
					"1100111" when "1011", --g
					"1100001" when "1100", --a
					"1101110" when "1101", --n
					"1100001" when "1110", --a
					"0100001" when others; --!
					
					
			------------------------------------NOMBRE1-------------------------------------------
	
			nombre1 <= -- 
				'1' when (pix_y (9 downto 4) = 18) and										--9 downto 5 significa 2^(n-1) = 2^(9-4 - 1)= BLOQUE DE 16 PIXELES
																												--Quiero que salga entre y = 0 e y = 8 (si pongo y=16 se imprime 2 veces)
							(pix_x (9 downto 4) >= 16) and (pix_x (9 downto 4) < 32) else	--9 downto 4 significa 2^(9-4 - 1) = BLOQUE DE 16 pixeles
																												--Entre el bloque 8 y el 16
				'0';
				
			row_addr_nombre1 <= std_logic_vector(pix_y(3 downto 0));  -- escala : (4 downto 1), mas grande (3 downto 0) mas chica
			bit_addr_nombre1 <= std_logic_vector(pix_x(2 downto 0));
			
	
			with pix_x (7 downto 3) select 
				char_addr_nombre1 <= 
					
					"1000011" when "00000",--C
					"1000001" when "00001",--A
					"1010011" when "00010",--S
					"1010100" when "00011",--T
					"1010010" when "00100",--R
					"1001111" when "00101",--O
					"0101100" when "00110",--,
					
					"0000000" when "00111",--
					
					"1000011" when "01000",--C
					"1110010" when "01001",--r
					"1101001" when "01010",--i
					"1110011" when "01011",--s
					"1110100" when "01100",--t
					"1101001" when "01101",--i
					"1100001" when "01110",--a
					"1101110" when "01111",--n
					
					"0000000" when others;
					
				
			-------------------------------------NOMBRE2-----------------------------------------------
		nombre2 <= -- 
				'1' when (pix_y (9 downto 4) = 19)   and 											--9 downto 5 significa 2^(n-1) = 2^(9-4 - 1)= BLOQUE DE 16 PIXELES
																												--Quiero que salga entre y = 0 e y = 8 (si pongo y=16 se imprime 2 veces)
							(pix_x (9 downto 4) >= 16) and (pix_x (9 downto 4) < 32) else	--9 downto 4 significa 2^(9-4 - 1) = BLOQUE DE 16 pixeles
																												--Entre el bloque 8 y el 16
				'0';
				
			row_addr_nombre2 <= std_logic_vector(pix_y(3 downto 0));  -- escala : (4 downto 1), mas grande (3 downto 0) mas chica
			bit_addr_nombre2 <= std_logic_vector(pix_x(2 downto 0));
			
	
			with pix_x (7 downto 3) select 
				char_addr_nombre2 <= 
					
					"1001100" when "00000",--L
					"1001001" when "00001",--I
					"1010000" when "00010",--P
					"1000001" when "00011",--A
					"1010010" when "00100",--R
					"1001001" when "00101",--I
					"0101100" when "00110",--,
					
					"0000000" when "00111",--
					
					"1010011" when "01000",--S
					"1100101" when "01001",--e
					"1110010" when "01010",--r
					"1100111" when "01011",--g
					"1101001" when "01100",--i
					"1101111" when "01101",--o
					
					"0000000" when others;
					
				---------------------------------NOMBRE3------------------------------------
			
		nombre3 <= -- 
				'1' when (pix_y (9 downto 4) = 20)   and 											--9 downto 5 significa 2^(n-1) = 2^(9-4 - 1)= BLOQUE DE 16 PIXELES
																												--Quiero que salga entre y = 0 e y = 8 (si pongo y=16 se imprime 2 veces)
							(pix_x (9 downto 4) >= 16) and (pix_x (9 downto 4) < 32) else	--9 downto 4 significa 2^(9-4 - 1) = BLOQUE DE 16 pixeles
																												--Entre el bloque 8 y el 16
				'0';
				
			row_addr_nombre3 <= std_logic_vector(pix_y(3 downto 0));  -- escala : (4 downto 1), mas grande (3 downto 0) mas chica
			bit_addr_nombre3 <= std_logic_vector(pix_x(2 downto 0));
			
	
			with pix_x (7 downto 3) select 
				char_addr_nombre3 <= 
					
					"1011010" when "00000",--Z
					"1000001" when "00001",--A
					"1001100" when "00010",--L
					"1000001" when "00011",--A
					"1011010" when "00100",--Z
					"1000001" when "00101",--A
					"1010010" when "00110",--R
					"0101100" when "00111",--,
					
					"0000000" when "01000",--
					
					"1000110" when "01001",--F
					"1100001" when "01010",--a
					"1100011" when "01011",--c
					"1110101" when "01100",--u
					"1101110" when "01101",--n
					"1100100" when "01110",--d
					"1101111" when "01111",--o

					"0000000" when others;
						

			--------------------------------------------------
			--Mux para las direcciones de la font ROM y el RGB
			--------------------------------------------------
			
			process (titulo, titulo2, logo_on, puntaje_player1, puntaje_player2, 
						pix_x, pix_y, font_bit, over_player, band_2, band_1, over_on, mult,
						puntaje_max, reset,
						
						
						char_addr_titulo1, row_addr_titulo1, bit_addr_titulo1, 
						char_addr_titulo2, row_addr_titulo2, bit_addr_titulo2, 
						nombre1, nombre2, nombre3,
						
						char_addr_logo, row_addr_logo, bit_addr_logo,
						
						char_addr_puntaje_player1, row_addr_puntaje_player1, bit_addr_puntaje_player1,
						char_addr_puntaje_player2, row_addr_puntaje_player2, bit_addr_puntaje_player2,
						
						char_addr_over_player, row_addr_over_player, bit_addr_over_player, 
						char_addr_over, row_addr_over, bit_addr_over,
						char_addr_puntaje_max, row_addr_puntaje_max, bit_addr_puntaje_max,
						
						char_addr_nombre1, row_addr_nombre1, bit_addr_nombre1,
						char_addr_nombre2, row_addr_nombre2, bit_addr_nombre2,
						char_addr_nombre3, row_addr_nombre3, bit_addr_nombre3)
						
			begin
				text_rgb <= "000"; --Fondo negro
				
				if titulo = '1' and band_2 = 0 and band_1 = '0' then --Titulo 1
					char_addr <= char_addr_titulo1;
					row_addr <= row_addr_titulo1;
					bit_addr <= bit_addr_titulo1;
					if font_bit = '1' then
						text_rgb <= "111";
					end if;
				
				elsif titulo2 = '1' and band_2 = 0 and band_1 = '0' then --Titulo 2
					char_addr <= char_addr_titulo2;
					row_addr <= row_addr_titulo2;
					bit_addr <= bit_addr_titulo2;
					if font_bit = '1' then
						text_rgb <= "111";
					end if;
					
				elsif logo_on = '1' and band_2 = 0 and band_1 = '0' then --Logo PONG
					char_addr <= char_addr_logo;
					row_addr <= row_addr_logo;
					bit_addr <= bit_addr_logo;
					if font_bit = '1' then
						text_rgb <= "111";
					end if;
					
				elsif puntaje_player1 = '1' and band_2 = 0  and mult = '1' and reset = '0' then -- Puntaje 1
					char_addr <= char_addr_puntaje_player1;
					row_addr <= row_addr_puntaje_player1;
					bit_addr <= bit_addr_puntaje_player1;
					if font_bit = '1' then
						text_rgb <= "111";
					end if;
					
				elsif puntaje_player2 = '1' and band_2 = 0 and mult = '1'  and reset = '0' then -- Puntaje 2 
					char_addr <= char_addr_puntaje_player2;
					row_addr <= row_addr_puntaje_player2;
					bit_addr <= bit_addr_puntaje_player2;
					if font_bit = '1' then
						text_rgb <= "111";
					end if;
					
				 elsif puntaje_max = '1' and band_1 = '0' and mult = '0'  and reset = '0' then  -- Maximo Puntaje
					char_addr <= char_addr_puntaje_max;
					row_addr <= row_addr_puntaje_max;
					bit_addr <= bit_addr_puntaje_max;
					if font_bit = '1' then
						text_rgb <= "110";
					end if;
				
				elsif over_player = '1' and band_2 = 1 and mult = '1' and reset = '0' then  -- game over, jugador 1 gano
					char_addr <= char_addr_over_player;
					row_addr <= row_addr_over_player;
					bit_addr <= bit_addr_over_player;
					if font_bit = '1' then
						text_rgb <= "100";
					end if;
					
				elsif over_player = '1' and band_2 = 2 and mult = '1' and reset = '0' then -- game over, jugador 2 gano
					char_addr <= char_addr_over_player;
					row_addr <= row_addr_over_player;
					bit_addr <= bit_addr_over_player;
					if font_bit = '1' then
						text_rgb <= "100";
					end if;
				 
				 elsif over_on = '1' and band_1 = '1' and mult = '0' and reset = '0' then  -- game over (1 jugador)
					char_addr <= char_addr_over;
					row_addr <= row_addr_over;
					bit_addr <= bit_addr_over;
					if font_bit = '1' then
						text_rgb <= "100";
					end if;
					
				 elsif nombre1 = '1' and reset = '1' then  -- Nombre1
					char_addr <= char_addr_nombre1;
					row_addr <= row_addr_nombre1;
					bit_addr <= bit_addr_nombre1;
					if font_bit = '1' then
						text_rgb <= "111";
					end if; 
				
				 elsif nombre2 = '1' and reset = '1' then  -- Nombre2
					char_addr <= char_addr_nombre2;
					row_addr <= row_addr_nombre2;
					bit_addr <= bit_addr_nombre2;
					if font_bit = '1' then
						text_rgb <= "111";
					end if; 
				   
				  elsif nombre3 = '1' and reset = '1' then  -- Nombre3
					char_addr <= char_addr_nombre3;
					row_addr <= row_addr_nombre3;
					bit_addr <= bit_addr_nombre3;
					if font_bit = '1' then
						text_rgb <= "111";
					end if; 
					
				
				end if;

			end process;
			
			
			-------------------------------------
			-- Interfaz de la font ROM
			-------------------------------------
			
			rom_addr <= char_addr & row_addr;
			font_bit <= font_word(to_integer(unsigned(not bit_addr)));
			end arch;
			
						