--CODIGO QUE CONTROLA LA ANIMACION Y EL PUNTAJE QUE SALE A TRAVES DE LOS DISPLAYS
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

--Entidad
entity animacion is
   port(
	   
        clk, on_off, reset, multiplayer : in std_logic; 
		  btn_left, btn_right:	in std_logic_vector(1 downto 0);
        pixel_x:   in std_logic_vector(9 downto 0);
		  pixel_y:   in std_logic_vector(9 downto 0);
        graph_rgb: out std_logic_vector(2 downto 0);
		  bandera_1 : out std_logic;
		  bandera_2 :  out integer range 0 to 10;
		  
		  salida_un_jugador_0, salida_un_jugador_1, salida_un_jugador_2,
		  salida_un_jugador_3, salida_un_jugador_4, salida_un_jugador_5,
		  salida_un_jugador_6, salida_un_jugador_7,
		  salida_dos_jugadores_0, salida_dos_jugadores_1, salida_dos_jugadores_2,
		  salida_dos_jugadores_3, salida_dos_jugadores_4, salida_dos_jugadores_5,
		  salida_dos_jugadores_6, salida_dos_jugadores_7 : out integer range 0 to 10; --salidas contador
		  vidas : out std_logic_vector (4 downto 0);
		  enable : out std_logic
   );
end animacion;


--Arquitectura
architecture arch of animacion is

		----------------------------------------------------------------------------
		-- Signal declarations 
		----------------------------------------------------------------------------
		-- refr_tick: 1-clock tick asserted at start of v-sync
		--       i.e., when the screen is refreshed (60 Hz)
		signal refr_tick, game_on: std_logic;
		signal result_player1, result_player2  : unsigned (15 downto 0); --Resultado del contador de puntaje	
		signal result_max : unsigned (15 downto 0); --Resultado del contador de puntaje
		signal band_2 : integer range 0 to 10 :=0;
		signal band_1 : std_logic := '0';
		signal mult : std_logic := '0';
		signal en : std_logic := '0';
		-- x, y coordinates (0,0) to (639,479)
		signal pix_x, pix_y: unsigned(9 downto 0);
		
		---------------------------------------------------------------------------
		-- Constant declarations
		---------------------------------------------------------------------------
		constant MAX_X: integer:=640;
		constant MAX_Y: integer:=480;
		
		   ----------------------------------------------
			-- vertical strip as a wall (SOLO 1 JUGADOR)
			----------------------------------------------
			-- wall left, right boundary
			constant WALL_X_L: integer:=32;
			constant WALL_X_R: integer:=42;
   
		
		----------------------------------------------
		-- paleta izquierda
		----------------------------------------------
		-- bar left, right boundary
		constant BAR1_X_L: integer:=40;
		constant BAR1_X_R: integer:=50;	
		-- bar top, bottom boundary
		signal bar1_y_top, bar1_y_btn: unsigned(9 downto 0);
		constant BAR1_Y_SIZE: integer:=72;
		-- reg to track top boundary  (x position is fixed)
		signal bar1_y_position, bar1_y_next: unsigned(9 downto 0);
		-- bar moving velocity when the button are pressed
		constant BAR1_Move: integer:=4;
		
		
		----------------------------------------------
		-- paleta derecha
		----------------------------------------------
		-- bar left, right boundary
		constant BAR2_X_L: integer:=600;
		constant BAR2_X_R: integer:=610;	
		-- bar top, bottom boundary
		signal bar2_y_top, bar2_y_btn: unsigned(9 downto 0);
		constant BAR2_Y_SIZE: integer:=72;
		-- reg to track top boundary  (x position is fixed)
		signal bar2_y_position, bar2_y_next: unsigned(9 downto 0);
		-- bar moving velocity when the button are pressed
		constant BAR2_Move: integer:=4;
		
		----------------------------------------------
		----------------------------------------------
		-- square ball
		----------------------------------------------
		constant BALL_SIZE: integer:= 8; 
		-- ball left, right boundary
		signal ball_x_lft, ball_x_rgt: unsigned(9 downto 0);
		-- ball top, bottom boundary
		signal ball_y_top, ball_y_btn: unsigned(9 downto 0);
		-- reg to track left, top boundary
		signal ball_x_position, ball_y_position: unsigned(9 downto 0);
		signal ball_x_next, ball_y_next: unsigned(9 downto 0);
		-- reg to track ball speed
		signal x_delta: unsigned(9 downto 0);
		signal y_delta: unsigned(9 downto 0);
		-- ball velocity can be pos or neg)
		constant BALL_V_P: unsigned(9 downto 0):= to_unsigned(2,10);
		constant BALL_V_N: unsigned(9 downto 0):= unsigned(to_signed(-2,10));
	
				
		----------------------------------------------
		-- round ball image ROM
		----------------------------------------------
		type rom_type is array (0 to 7) of std_logic_vector (0 to 7);
		-- ROM definition
		constant BALL_ROM: rom_type :=
		(
			"00111100", --   ****
			"01111110", --  ******
			"11111111", -- ********
			"11111111", -- ********
			"11111111", -- ********
			"11111111", -- ********
			"01111110", --  ******
			"00111100"  --   ****
		);
		
		signal rom_addr, rom_col: unsigned(2 downto 0);
		signal rom_data: std_logic_vector(7 downto 0);
		signal rom_bit: std_logic;
		
		-------------------------------------------------------------
		-------------------------------------------------------------
		
		
		constant LOGOUTN_SIZE_W : integer := 250;
		constant LOGOUTN_SIZE_H : integer := 38; -- TAMAÑO
		signal logoutn_x_l, logoutn_x_r, logoutn_y_top, logoutn_y_bottom : unsigned (9 downto 0);
		signal logoutn_x_reg, logoutn_y_reg: unsigned (9 downto 0) := "0000000000";
		signal logoutn_rgb : std_logic_vector (2 downto 0);
		signal rom_addr_logoutn, rom_col_logoutn : unsigned (9 downto 0);
		signal rom_data_logoutn : std_logic_vector ((LOGOUTN_SIZE_W - 1) downto 0);
		signal rom_bit_logoutn, logoutn_on : std_logic;
		
		------------------------------y------------------------------x---
		type rom_type_2 is array (0 to LOGOUTN_SIZE_H - 1) of std_logic_vector (0 to LOGOUTN_SIZE_W -1);

	
		constant mario_rom : rom_type_2 :=

		(		NOT "1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111",
				NOT "1100000000000000000111111111111111111111000000000000000000111111110000000000000000000000000000000000000000000000000000000111111110000000000000000001111111111111111111100000000000000000011111111111100000000001111111111000000000001111111111000000000001",
				NOT "1100000000000000000111111111111111111110000000000000000000111111110000000000000000000000000000000000000000000000000000000111111110000000000000000001111111111111111111100000000000000000011111111111100000000001111111111000000000001111111111000000000001",
				NOT "1100000000000000000111111111111111111100000000000000000000111111110000000000000000000000000000000000000000000000000000000111111110000000000000000001111111111111111111100000000000000000011111111111100000000000111111111000000000001111111110000000000011",
				NOT "1100000000000000000111111111111111111000000000000000000000111111110000000000000000000000000000000000000000000000000000000111111110000000000000000001111111111111111111100000000000000000011111111111100000000000111111111000000000001111111110000000000011",
				NOT "1100000000000000000111111111111111110000000000000000000000111111110000000000000000000000000000000000000000000000000000000111111110000000000000000001111111111111111111100000000000000000011111111111110000000000011111111000000000001111111100000000000011",
				NOT "1100000000000000000111111111111111100000000000000000000000111111110000000000000000000000000000000000000000000000000000000111111110000000000000000001111111111111111111100000000000000000011111111111111000000000000111111000000000001111111000000000000111",
				NOT "1100000000000000000111111111111110000000000000000000000000111111110000000000000000000000000000000000000000000000000000000111111110000000000000000001111111111111111111100000000000000000011111111111111000000000000011111000000000001111100000000000001111",
				NOT "1100000000000000000111111111111100000000000000000000000000111111110000000000000000000000000000000000000000000000000000000111111110000000000000000001111111111111111111100000000000000000011111111111111100000000000000111000000000001110000000000000011111",
				NOT "1100000000000000000111111111111000000000000000000000000000111111111000000000000000000000000000000000000000000000000000000111111110000000000000000001111111111111111111100000000000000000011111111111111110000000000000000000000000000000000000000000111111",
				NOT "1100000000000000000111111111110000000000000000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111111111100000000000000000000000000000000000000001111111",
				NOT "1100000000000000000111111111100000000000000000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111111111110000000000000000000000000000000000000111111111",
				NOT "1100000000000000000111111111000000000000000000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111111111111100000000000000000000000000000000001111111111",
				NOT "1100000000000000000111111110000000000000000000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111111111111111000000000000000000000000000001111111111111",
				NOT "1100000000000000000111111100000000000000000000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111111111111111111100000000000000000000001111111111111111",
				NOT "1100000000000000000111111000000000000000000000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111100000000000000000000000000000000000000000000000000001",
				NOT "1100000000000000000111110000000000000000000000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111100000000000000000000000000000000000000000000000000001",
				NOT "1100000000000000000111000000000000000000100000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111100000000000000000000000000000000000000000000000000001",
				NOT "1100000000000000000110000000000000000001100000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111100000000000000000000000000000000000000000000000000001",
				NOT "1100000000000000000100000000000000000011100000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111100000000000000000000000000000000000000000000000000001",
				NOT "1100000000000000000000000000000000000111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111100000000000000000000000000000000000000000000000000001",
				NOT "1100000000000000000000000000000000001111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111100000000000000000000000000000000000000000000000000001",
				NOT "1100000000000000000000000000000000011111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111111111111111111000000000000000000000001111111111111111",
				NOT "1100000000000000000000000000000000111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000001111111111111111111100000000000000000011111111111111111111111000000000000000000000000000001111111111111",
				NOT "1100000000000000000000000000000001111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111110000000000000000000111111111111111111100000000000000000011111111111111111111000000000000000000000000000000000001111111111",
				NOT "1100000000000000000000000000000111111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111111000000000000000000111111111111111111000000000000000000011111111111111111110000000000000000000000000000000000000011111111",
				NOT "1100000000000000000000000000001111111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111111000000000000000000011111111111111110000000000000000000111111111111111111000000000000000000000000000000000000000001111111",
				NOT "1100000000000000000000000000011111111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111111000000000000000000001111111111111100000000000000000000111111111111111110000000000000000000000000000000000000000000011111",
				NOT "1100000000000000000000000000111111111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111111100000000000000000000001111111100000000000000000000001111111111111111100000000000000111000000000001111000000000000011111",
				NOT "1100000000000000000000000001111111111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111111110000000000000000000000000000000000000000000000000001111111111111111000000000000011111000000000001111100000000000001111",
				NOT "1100000000000000000000000011111111111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111111111000000000000000000000000000000000000000000000000011111111111111110000000000001111111000000000001111111000000000000111",
				NOT "1100000000000000000000000111111111111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111111111100000000000000000000000000000000000000000000000111111111111111110000000000011111111000000000001111111100000000000011",
				NOT "1100000000000000000000001111111111111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111111111110000000000000000000000000000000000000000000011111111111111111100000000000011111111000000000001111111110000000000011",
				NOT "1100000000000000000000011111111111111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111111111111100000000000000000000000000000000000000000111111111111111111100000000000111111111000000000001111111111000000000001",
				NOT "1100000000000000000001111111111111111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111111111111110000000000000000000000000000000000000011111111111111111111100000000001111111111000000000001111111111000000000001",
				NOT "1100000000000000000011111111111111111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111111111111111110000000000000000000000000000000011111111111111111111111100000000001111111111000000000001111111111000000000001",
				NOT "1100000000000000000111111111111111111111100000000000000000111111111111111111111111111000000000000000000111111111111111111111111111111111111111111000000000000000000000000111111111111111111111111111100000000001111111111000000000001111111111100000000001",
				NOT "1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111"
		);

		

		
	
		---------------------------------------------------------------
		--------------------------------------------------------------
		

		----------------------------------------------
		-- object output signals
		----------------------------------------------
		signal bar1_on, bar2_on, sq_ball_on, rd_ball_on: std_logic;
		signal bar1_rgb, bar2_rgb: std_logic_vector(2 downto 0) := "111";
		signal ball_rgb: std_logic_vector(2 downto 0);
		
		signal wall_on : std_logic; 							--SOLO 1 JUGADOR
		signal wall_rgb : std_logic_vector(2 downto 0);
		
			---------------------------- Funcion de conteo ----------------------------

			function to_bcd ( bin : unsigned(15 downto 0) ) return unsigned is
				variable i : integer:=0;
				variable bcd : unsigned(15 downto 0) := (others => '0');
				variable bint : unsigned(15 downto 0) := bin;

				begin
					for i in 0 to 15 loop  -- repeating 8 times.
					bcd(15 downto 1) := bcd(14 downto 0);  --shifting the bits.
					bcd(0) := bint(15);
					bint(15 downto 1) := bint(14 downto 0);
					bint(0) :='0';


					if(i < 15 and bcd(3 downto 0) > "0100") then --add 3 if BCD digit is greater than 4.
					bcd(3 downto 0) := bcd(3 downto 0) + "0011";
					end if;

					if(i < 15 and bcd(7 downto 4) > "0100") then --add 3 if BCD digit is greater than 4.
					bcd(7 downto 4) := bcd(7 downto 4) + "0011";
					end if;

					if(i < 15 and bcd(11 downto 8) > "0100") then  --add 3 if BCD digit is greater than 4.
					bcd(11 downto 8) := bcd(11 downto 8) + "0011";
					end if;

					if(i < 15 and bcd(15 downto 12) > "0100") then  --add 3 if BCD digit is greater than 4.
					bcd(15 downto 12) := bcd(15 downto 12) + "0011";
					end if;


					end loop;
				return bcd;
			end to_bcd;
			-------------------------------------------	 
						
																		--Empieza el codigo
	begin
	  
		pix_x <= unsigned(pixel_x);
		pix_y <= unsigned(pixel_y);
		bandera_2 <= band_2;
		bandera_1 <= band_1;
		mult <= multiplayer;
		game_on <= on_off;
		enable <= en;
		----------------------------------------------
		-- refr_tick: 1-clock tick asserted at start of v-sync
		--       i.e., when the screen is refreshed (60 Hz)
		----------------------------------------------
		 refr_tick <= '1' when (pix_y=481) and (pix_x=0) else
						 '0';
		

		   ----------------------------------------------
			-- (wall) left vertical strip (1 JUGADOR)
			----------------------------------------------
			-- pixel within wall
			wall_on <=
				'1' when (WALL_X_L<=pix_x) and (pix_x<=WALL_X_R) else
				'0';
			-- wall rgb output
			wall_rgb <= "001"; -- blue
		
		
		 ---------------------------------------------------------------
		-- paleta izquierda
		---------------------------------------------------------------
		-- boundary
		bar1_y_top <= bar1_y_position;
		bar1_y_btn <= bar1_y_top + BAR1_Y_SIZE - 1;
		-- pixel within bar
		bar1_on <=
			'1' when (BAR1_X_L<=pix_x) and (pix_x<=BAR1_X_R) and
						(bar1_y_top<=pix_y) and (pix_y<=bar1_y_btn) else
			'0';
		-- bar rgb output
		
		---------------------------------------------------------------
		-- paleta derecha
		---------------------------------------------------------------
		-- boundary
		bar2_y_top <= bar2_y_position;
		bar2_y_btn <= bar2_y_top + BAR2_Y_SIZE - 1;
		-- pixel within bar
		bar2_on <=
			'1' when (BAR2_X_L<=pix_x) and (pix_x<=BAR2_X_R) and
						(bar2_y_top<=pix_y) and (pix_y<=bar2_y_btn) else
			'0';
		
		-------------------------------------------------------------
		-- Posicion de la paleta 1 al tocar los controles
		-------------------------------------------------------------
		process(clk, reset, mult)
			begin
				if (reset= '1') then 
					bar1_y_position <= (others=>'0');
				elsif(rising_edge(clk) and mult = '1') then 
				
					if(refr_tick = '1') then -- Mientras se refresca la pantalla a 60Hz y esta en modo multiplayer
					
						if(btn_left(1)='1' and bar1_y_btn < (MAX_Y-BAR1_Move)) then  --Si toco el btn_left(1) y no esta en el tope superior
							bar1_y_position <= bar1_y_position + BAR1_Move; -- bar move down
							
						elsif(btn_left(0)='1' and bar1_y_top > BAR1_Move) then 	--Si toco el btn_left(0) y no esta en el tope inferior
							bar1_y_position <= bar1_y_position - BAR1_Move; -- bar move up
						end if;
						
					else
						bar1_y_position <= bar1_y_position; -- no move
					end if;
				end if; 
		end process;  
		
		-------------------------------------------------------------
		-- Posicion de la paleta 2 al tocar los controles
		-------------------------------------------------------------
		
		process(clk, reset)
			begin
				if (reset= '1') then 
					bar2_y_position <= (others=>'0');
				elsif(rising_edge(clk)) then 
				
					if(refr_tick = '1') then -- Mientras se refresca la pantalla a 60Hz
					
						if(btn_right(1)='1' and bar2_y_btn <(MAX_Y-BAR2_Move)) then 
							bar2_y_position <= bar2_y_position + BAR2_Move; -- bar move down
							
						elsif(btn_right(0)='1' and bar2_y_top > BAR2_Move) then 
							bar2_y_position <= bar2_y_position - BAR2_Move; -- bar move up
						end if;
						
					else
						bar2_y_position <= bar2_y_position; -- no move
					end if;
				end if; 
		end process;  


		-------------------------------------------------------------------
		-- BOLA
		-------------------------------------------------------------------
		-- boundary
		ball_x_lft <= ball_x_position;
		ball_y_top <= ball_y_position;
		ball_x_rgt <= ball_x_lft + BALL_SIZE - 1;
		ball_y_btn <= ball_y_top + BALL_SIZE - 1;
		-- pixel within ball
		
		sq_ball_on <=
			'1' when (ball_x_lft<=pix_x) and (pix_x<=ball_x_rgt) and
						(ball_y_top<=pix_y) and (pix_y<=ball_y_btn) else
			'0';
		-- map current pixel location to ROM addr/col
		
		rom_addr <= pix_y(2 downto 0) - ball_y_top(2 downto 0);
		rom_col <= pix_x(2 downto 0) - ball_x_lft(2 downto 0);
		rom_data <= BALL_ROM(to_integer(rom_addr));
		rom_bit <= rom_data(to_integer(rom_col));
		
		-- pixel within ball
		rd_ball_on <=
			'1' when (sq_ball_on='1') and (rom_bit='1') else
			'0';
			
		-- ball rgb output
		ball_rgb <= "100";   -- red
		
		
		
		---------------------------------------------------
		--LOGO UTN
		---------------------------------------------------
		logoutn_x_l <= logoutn_x_reg + 350; --280
		logoutn_y_top <= logoutn_y_reg + 420; --400
		logoutn_x_r <= logoutn_x_l + LOGOUTN_SIZE_W - 1;
		logoutn_y_bottom <= logoutn_y_top + LOGOUTN_SIZE_H - 1;
		
		--pixel within square ball
		
		
		rom_addr_logoutn <= pix_y(9 downto 0) - logoutn_y_top (9 downto 0);
		rom_col_logoutn <= pix_x(9 downto 0) - logoutn_x_l(9	downto 0);
		rom_data_logoutn <= mario_rom(to_integer(rom_addr_logoutn));
		rom_bit_logoutn <= rom_data_logoutn(to_integer(rom_col_logoutn));
		
		logoutn_on <=
						'1' when (logoutn_x_l <= pix_x) and (pix_x <= logoutn_x_r) and (rom_bit_logoutn = '1') and
									(logoutn_y_top <= pix_y) and (pix_y <= logoutn_y_bottom) else
						'0';
		logoutn_rgb <= "111";
		
		-- ------------------------------------------------- --
		-- process to determine whether x_delta and y_delta
		-- will be positive or negative, depending where the 
		-- ball is
		-- ------------------------------------------------- --   
		
		process(x_delta, y_delta, reset, clk, mult, refr_tick, en, game_on, result_player1, result_player2, result_max)
			-- contador de Score (mod)
		variable contador_player1, contador_player2: integer range 0 to 9999 := 0;
		variable velocity_res : integer range 0 to 10 := 1;
		variable vidas_contador : integer range 0 to 10 := 5;
		variable puntaje_max: integer range 0 to 9999 := 0;
		
		begin
		
			

			-------PUNTAJE MAXIMO Y VIDAS (1 jugador)------------
			
				case vidas_contador is
				when 5 => vidas <= "11111";
				when 4 => vidas <= "01111";
				when 3 => vidas <= "00111";
				when 2 => vidas <= "00011";
				when 1 => vidas <= "00001";
				when others => vidas <= "00000";
					end case;
				
				
			 if (contador_player2 > puntaje_max and mult = '0') then
				puntaje_max := contador_player2;
			 else
				puntaje_max := puntaje_max;
			 end if;
			
			-------VALOR BANDERA, QUE GOBIERNA LO QUE APARECE EN LA PANTALLA: 0 JUEGO, 1 GANO P1, 2 GANO P2---------
			
				if (mult = '1') then
					if (contador_player1 >= 100) then
						band_2 <= 1;
					elsif (contador_player2 >= 100) then
						band_2 <= 2;
					else
						band_2 <= 0;
					end if;
				end if;
				
			--------ANIMACION DE ACUERDO A LO QUE VA SUCEDIENDO--------	
			
				 if(reset = '1') then
					  x_delta <= ("0000000100");
					  y_delta <= ("0000000100");
					  contador_player1 := 0;
					  contador_player2 := 0;
					  band_1 <= '0';
					  band_2 <= 0;
					  vidas_contador := 5;
					
					if (reset = '1' and game_on = '1') then
					  en <= '1';
					else
					  en <= '0';
					  end if;
					  

				 elsif(rising_edge(clk)) then
				 en <= '0';
			
				 			--------VELOCIDAD VARIABLE A MEDIDA QUE AVANZAN LOS PUNTOS--------
							
						if (contador_player1 > 250 and contador_player1 < 500) then
								velocity_res := 2;
						elsif (contador_player2 > 250 and contador_player2 < 500) then
								velocity_res := 2;
						elsif (contador_player1 > 500 and contador_player1 < 750) then
								velocity_res := 3;
						elsif (contador_player2 > 500 and contador_player2 < 750) then
								velocity_res := 3;
						elsif (contador_player1 > 750) then
								velocity_res := 4;
						elsif (contador_player2 > 750) then
								velocity_res := 4;
						else
								velocity_res := 1;
						end if;
				 
				 ------------------------------------------------------------------------------
				 
					if(ball_y_top = 0) then            -- reach top (QUEDA IGUAL CON RESPECTO A VERSION 1 PLAYER)
						y_delta <= BALL_V_P + velocity_res;
						en <= '1';
						
						elsif (ball_y_btn > (MAX_Y)) then  -- reach bottom (QUEDA IGUAL CON RESPECTO A VERSION 1 PLAYER)
						y_delta <= BALL_V_N - velocity_res;
					   en <= '1';
					
					--- PARED IZQUIERDA (1 JUGADOR)
	
			
						elsif (ball_x_lft <= WALL_X_R and mult = '0')  then   -- reach wall
						x_delta <= BALL_V_P + velocity_res;    -- bounce back
					   en <= '1';
					
					---------- paleta izquierda ----------	
						elsif ((BAR1_X_L <= ball_x_lft) and (ball_x_lft <= BAR1_X_R) and (band_2 = 0) and mult = '1') then	-- reach x of right bar
						
							if (bar1_y_top<=ball_y_btn) and (ball_y_top<=bar1_y_btn) then
								x_delta <= BALL_V_P + velocity_res; --hit, bounce back
						    	en <= '1';
								
								if (refr_tick = '1') then
								
									contador_player1 := contador_player1  + 10; --cuenta el puntaje
									
								
									if (bar1_rgb < "111") then
										bar1_rgb <= bar1_rgb + 1;
										else 
										bar1_rgb <= "001";
									end if;
								
							end if;
							
						end if;
					
				--------- paleta derecha -----------	
					elsif ((BAR2_X_L <= ball_x_rgt) and (ball_x_rgt <= BAR2_X_R) and (band_2 = 0)) then	-- reach x of right bar
					
						if (bar2_y_top<=ball_y_btn) and (ball_y_top<=bar2_y_btn) then
							x_delta <= BALL_V_N - velocity_res; --hit, bounce back
							en <= '1';
							
							if (refr_tick = '1') then
							contador_player2  := contador_player2  + 10; --cuenta el puntaje
							
							
								if (bar2_rgb < "111") then
								bar2_rgb <= bar2_rgb + 1;
								else 
								bar2_rgb <= "001";
								end if;
							
							end if;
							
						end if;	
						
					  	
						elsif (ball_x_lft = (MAX_X-1))and (refr_tick = '1') and (vidas_contador > 0) and (mult='0')then
								vidas_contador := vidas_contador - 1;
						elsif (ball_x_rgt = (MAX_X-1))and (refr_tick = '1') and (vidas_contador > 0) and (mult='0')then
								vidas_contador := vidas_contador - 1;
						elsif (ball_x_lft = (MAX_X)) and (refr_tick = '1') and (vidas_contador > 0) and (mult='0')then
								vidas_contador := vidas_contador - 1;
								
				-----------------------------------

				end if; 
				
					
								if (vidas_contador = 0) then
									band_1 <= '1';
									
								else
									band_1 <= '0';
								end if;
								
								if (band_1 = '1') then
									en <= '0';
								end if;
								if (band_2 /= 0) then
									en <= '0';
								end if;
								
								if (game_on = '0') then
								en <= '0';
								end if;
					  
			end if;	
											
		result_player1<= to_bcd(to_unsigned(contador_player1, 16));
		result_player2<= to_bcd(to_unsigned(contador_player2, 16));
		
		result_max<= to_bcd(to_unsigned(puntaje_max, 16));

	end process;
		
		salida_un_jugador_0 <= to_integer(result_player2(3 downto 0));
			salida_un_jugador_1 <= to_integer(result_player2(7 downto 4));
			salida_un_jugador_2 <= to_integer(result_player2(11 downto 8));
			salida_un_jugador_3 <= to_integer(result_player2(15 downto 12));  
			
			salida_un_jugador_4 <= to_integer(result_max(3 downto 0));
			salida_un_jugador_5 <= to_integer(result_max(7 downto 4));
			salida_un_jugador_6 <= to_integer(result_max(11 downto 8));
			salida_un_jugador_7 <= to_integer(result_max(15 downto 12));   

			

				
			salida_dos_jugadores_0 <= to_integer(result_player1(3 downto 0));
			salida_dos_jugadores_1 <= to_integer(result_player1(7 downto 4));
			salida_dos_jugadores_2 <= to_integer(result_player1(11 downto 8));
			salida_dos_jugadores_3 <= to_integer(result_player1(15 downto 12));  
			
			salida_dos_jugadores_4 <= to_integer(result_player2(3 downto 0));
			salida_dos_jugadores_5 <= to_integer(result_player2(7 downto 4));
			salida_dos_jugadores_6 <= to_integer(result_player2(11 downto 8));
			salida_dos_jugadores_7 <= to_integer(result_player2(15 downto 12));
	

		-- ---------------------------------------------------- --
		-- process that set the new ball x,y position
		-- updated with x_delta and y_delta
		-- ---------------------------------------------------- -- 
		process(reset, clk)
		begin
			if(reset = '1') then 
				ball_x_position <= (others=>'0');
				ball_y_position <= (others=>'0');
			elsif (rising_edge(clk)) then
				if(refr_tick = '1') then
					ball_x_position <= ball_x_position + x_delta;
					ball_y_position <= ball_y_position + y_delta;
				end if;
			end if;
		end process;
			
		 
		----------------------------------------------
		-- rgb multiplexing circuit
		----------------------------------------------
		process(game_on, mult, reset, bar1_on, rd_ball_on, 
				  bar1_rgb, ball_rgb, bar2_on, bar2_rgb, wall_on, wall_rgb, logoutn_on, logoutn_rgb)
			begin
			
				if game_on = '1' and reset = '1' and logoutn_on = '1' then
					 graph_rgb <= logoutn_rgb;
				elsif game_on = '1' and reset = '0' then
				
				   
					if wall_on='1' and mult = '0' then
						graph_rgb <= wall_rgb;
					elsif bar1_on='1' and mult = '1' then 
						graph_rgb <= bar1_rgb;
					elsif bar2_on='1' then
						graph_rgb <= bar2_rgb;
					elsif rd_ball_on='1' then
						graph_rgb <= ball_rgb;
					else
						graph_rgb <= "000"; -- black background
					end if;
					
				end if;
		end process;
	 
		
end arch;


-----------------------------------------------------------
-- End of file