--ARCHIVO PRINCIPAL

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.pckg.all; --CABECERA

--Entidad
entity cabecera is
   port (
	   ------------------------------------------------------------
      -- clock & reset input signals
		-----------------------------------------------------------
		clk:   in std_logic; -- 50MHHz 
	   reset: in std_logic;	
		multiplayer, on_off: in std_logic;
      ------------------------------------------------------------		
		--- Control VGA 
		------------------------------------------------------------
		
      hsync: out  std_logic;  -- sincronismo horizontal -- 
	   vsync: out  std_logic; 	-- sincronismo vertical -- 
		
		-- control de paleta -- 
		btn_left, btn_right:	in std_logic_vector(1 downto 0); -- btn_left y btn_right son los controles para 2 jugadores
																				-- btn_right es el control para el modo un jugador
		-- control colores 
		red, green, blue:  out std_logic_vector (3 downto 0);
		
		--salida del contador de score
		seg_output_d0, seg_output_d1 ,seg_output_d2, 
		seg_output_d3 : out unsigned (6 downto 0); --Entrada del contador de score
		vidas : out std_logic_vector (4 downto 0);
		pwm_out   : out std_logic_vector(1 DOWNTO 0)  

   );
end cabecera;

--Arquitectura
architecture arch of cabecera is

   --Señales
	signal input_signal_d0, input_signal_d1, 
			 input_signal_d2, input_signal_d3 : integer range 0 to 10; --Entrada del contador de score
   signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
   signal pixel_tick: std_logic;
   signal rgb_reg, rgb_next, text_rgb: std_logic_vector(2 downto 0);
	signal p_max0, p_max1, p_max2, p_max3 : integer range 0 to 10; --Entrada en enteros de puntuaje max
	signal band_1 : std_logic;
	signal band_2 : integer range 0 to 10;
   signal rgb: std_logic_vector(2 downto 0);
	signal s_0,s_1,s_2,s_3, s_4,s_5,s_6,s_7 : integer range 0 to 10; --salidas contador
	signal mult : std_logic := '0';
	signal enable : std_logic;

-- Empieza el codigo
begin
	mult <= multiplayer;
   
   -- Instanciar la sincronizacion VGA
   sinc : entity work.sincronismo_vga   
	         port map(
		       fpga_50mhz_clk=> clk, 
		       fpga_reset    => not on_off,
           --  video_on      => video_on, 
		       en_tick       => pixel_tick,
             h_sync        => hsync, 
	          v_sync        => vsync,
             pixel_x       => pixel_x, 
		       pixel_y       => pixel_y);
		
		
   -- Instanciar el generador de graficos
   graficos :  entity work.animacion
           port map (
			   clk      => clk, 
			   reset    => reset,
            btn_left   => not btn_left,
				btn_right  => not btn_right,
			   on_off => on_off,
            pixel_x  => pixel_x, 
			   pixel_y  => pixel_y,
            graph_rgb => rgb_next,
				
				salida_un_jugador_0 => input_signal_d0, --Salida para display de 7
				salida_un_jugador_1 => input_signal_d1,
				salida_un_jugador_2 => input_signal_d2,
				salida_un_jugador_3 => input_signal_d3,
				salida_un_jugador_4 => p_max0,				--Puntaje maximo
				salida_un_jugador_5 => p_max1,
				salida_un_jugador_6 => p_max2,
				salida_un_jugador_7 => p_max3,
				
				bandera_1 => band_1,
				vidas => vidas,
				multiplayer => multiplayer,
				enable => enable,
				
				bandera_2 => band_2,
				salida_dos_jugadores_0 => s_0, -- salidas para los puntajes 
														  --de los 2 jugadores
				salida_dos_jugadores_1 => s_1,
				salida_dos_jugadores_2 => s_2,
				salida_dos_jugadores_3 => s_3,
				salida_dos_jugadores_4 => s_4,
				salida_dos_jugadores_5 => s_5,
				salida_dos_jugadores_6 => s_6,
				salida_dos_jugadores_7 => s_7);
				
		 -- Instanciar contador de puntaje (display HEX0)
	contador_puntaje_d0 : entity work.siete_segmentos
			port map (
			input => input_signal_d0,
			seg_output => seg_output_d0);
			
	-- Instanciar contador de puntaje (display HEX1)
	contador_puntaje_d1 :  entity work.siete_segmentos
			port map (
			input => input_signal_d1,
			seg_output => seg_output_d1); 
			
	-- Instanciar contador de puntaje (display HEX2)
	contador_puntaje_d2 :  entity work.siete_segmentos
			port map (
			input => input_signal_d2,
			seg_output => seg_output_d2);
			
	-- Instanciar contador de puntaje (display HEX3)
	contador_puntaje_d3 : entity work.siete_segmentos
			port map (
			input => input_signal_d3,
			seg_output => seg_output_d3);		
			
	-- Instanciar texto en pantalla
	texto_en_pantalla : texto
			port map (clk => clk, reset => reset, pixel_x => pixel_x,
			pixel_y => pixel_y, text_rgb => text_rgb, bandera_1 => band_1, bandera_2 => band_2, multiplayer => multiplayer,
			e0 => s_0, e1 => s_1, 
			e2 => s_2, e3 => s_3, 
			e4 => s_4, e5 => s_5, 
			e6 => s_6, e7 => s_7, 
			p_max0 => p_max0, p_max1 => p_max1, p_max2 => p_max2, p_max3 => p_max3
			);
	
	sonidos : sonidos_pwm
			port map (clk => clk, --reset_n => reset, 
			ena => enable, pwm_out => pwm_out);
	
   -- Buffer RGB
   process (clk, pixel_tick, text_rgb, mult)
   begin
      if (clk'event and clk='1' and pixel_tick = '1') then
						if (band_1 = '0' and mult = '0') then
						
						rgb_reg <= rgb_next or text_rgb;
					   elsif (band_1 = '1' and mult = '0') then
						
						rgb_reg <= text_rgb;
						elsif (band_2 = 0 and mult = '1') then
						
						rgb_reg <= rgb_next or text_rgb;
						
					   elsif (band_2 /= 0 and mult = '1') then
						rgb_reg <= text_rgb;
        
				end if;
		end if;
   end process;
	
   rgb <= rgb_reg;
	
	red <= (rgb(2),rgb(2),rgb(2),rgb(2));
	green <= (rgb(1),rgb(1),rgb(1),rgb(1));
	blue <= (rgb(0),rgb(0),rgb(0),rgb(0));
	
end arch;
