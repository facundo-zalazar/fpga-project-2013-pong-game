library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entidad
entity pong_text is
	port (clk, reset, bandera : in std_logic;
			pixel_x, pixel_y : in std_logic_vector (9 downto 0);
			e0, e1, e2, e3 : in integer range 0 to 10; --Entrada en enteros de puntuaje max
			text_rgb : out std_logic_vector (2 downto 0));
end pong_text;

--Arquitectura
architecture arch of pong_text is
	signal pix_x, pix_y : unsigned (9 downto 0); 						--Coordenadas X e Y
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
	
	signal char_addr_over: std_logic_vector (6 downto 0); --Signals para mostrar el logo
	signal row_addr_over : std_logic_vector (3 downto 0);
	signal bit_addr_over: std_logic_vector (2 downto 0);
	
	signal char_addr_puntaje_player1: std_logic_vector (6 downto 0); --Signals para mostrar el logo
	signal row_addr_puntaje_player1 : std_logic_vector (3 downto 0);
	signal bit_addr_puntaje_player1: std_logic_vector (2 downto 0);

	signal font_word : std_logic_vector (7 downto 0);
	signal font_bit, titulo, logo_on, titulo2, over_on, puntaje_player1 : std_logic;
	signal rule_rom_addr : unsigned (5 downto 0);
	
	signal temp0, temp1, temp2, temp3 : std_logic_vector (6 downto 0);
	
	begin 
		pix_x <= unsigned(pixel_x);
		pix_y <= unsigned(pixel_y);
		
		--Instanciacion de la font ROM
		font_unit : entity work.font_rom
			port map (clk => clk, addr => rom_addr, data => font_word);
			
			
			-------------------------------TITULO SUPERIOR : PRIMER RENGLON ----------------------------------
			titulo <= 
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
					
				-------------------------------TITULO SUPERIOR : SEGUNDO RENGLON ----------------------------------	
				
				titulo2 <= -- Texto superior
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
					
						temp3 when "10000",
						temp2 when "10001",
						temp1 when "10010",
						temp0 when "10011",
					
					"0000000" when others;
					
					
				-------------------------------LOGO DE PONG ----------------------------------
			
		
			logo_on <=
					'1' when pix_y (9 downto 7) = 1 and 
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
				
			-------------------------------FIN DEL JUEGO ----------------------------------
			
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
					
					
					
			--------------------------------------------------
			--Mux para las direcciones de la font ROM y el RGB
			--------------------------------------------------
			
			process (titulo, titulo2, logo_on, pix_x, pix_y, font_bit, over_on, puntaje_player1,
						char_addr_titulo1, row_addr_titulo1, bit_addr_titulo1, 
						char_addr_titulo2, row_addr_titulo2, bit_addr_titulo2, 
						char_addr_logo, row_addr_logo, bit_addr_logo,
						char_addr_over, row_addr_over, bit_addr_over,
						char_addr_puntaje_player1, row_addr_puntaje_player1, bit_addr_puntaje_player1
						)
			begin
				text_rgb <= "000"; --Fondo negro
				
				if titulo = '1' and bandera = '0' then
					char_addr <= char_addr_titulo1;
					row_addr <= row_addr_titulo1;
					bit_addr <= bit_addr_titulo1;
					if font_bit = '1' then
						text_rgb <= "111";
					end if;
				
				elsif titulo2 = '1' and bandera = '0' then
					char_addr <= char_addr_titulo2;
					row_addr <= row_addr_titulo2;
					bit_addr <= bit_addr_titulo2;
					if font_bit = '1' then
						text_rgb <= "111";
					end if;
					
				elsif logo_on = '1' and bandera = '0' then
					char_addr <= char_addr_logo;
					row_addr <= row_addr_logo;
					bit_addr <= bit_addr_logo;
					if font_bit = '1' then
						text_rgb <= "111";
					end if;
				
				elsif puntaje_player1 = '1' and bandera = '0' then 
					char_addr <= char_addr_puntaje_player1;
					row_addr <= row_addr_puntaje_player1;
					bit_addr <= bit_addr_puntaje_player1;
					if font_bit = '1' then
						text_rgb <= "110";
					end if;	
				
				elsif over_on = '1' and bandera = '1' then 
					char_addr <= char_addr_over;
					row_addr <= row_addr_over;
					bit_addr <= bit_addr_over;
					if font_bit = '1' then
						text_rgb <= "100";
					end if;
			
				end if;
			
			end process;
			
			-------------------------------------
			-- Interfaz de la font ROM
			-------------------------------------
			
			rom_addr <= char_addr & row_addr;
			font_bit <= font_word(to_integer(unsigned(not bit_addr)));
			end arch;
			
						