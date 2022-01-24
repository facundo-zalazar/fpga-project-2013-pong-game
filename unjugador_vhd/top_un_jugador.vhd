--ARCHIVO PRINCIPAL

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.vga_pckg.all; --CABECERA

--Entidad
entity pong_top is
   port (
	   ------------------------------------------------------------
      -- clock & reset input signals
		-----------------------------------------------------------
		clk:   in std_logic; -- 50MHHz 
	   reset: in std_logic; 
		velocity : in std_logic_vector (1 downto 0); --Velocidad variable 

      ------------------------------------------------------------		
		--- Control VGA 
		------------------------------------------------------------
		-- sincronismo horizontal -- 
      hsync: out  std_logic; 
		-- sincronismo vertical -- 
	   vsync: out  std_logic; 	
		
		-- control de paleta -- 
		btn:   in std_logic_vector (1 downto 0); -- Key 3/0.  Active Low
		--btn_test : in std_logic;
   
		-- control colores 
		red, green, blue:  out std_logic_vector (3 downto 0);

		--salida del contador de score
		seg_output_d0, seg_output_d1 ,seg_output_d2 , 
		seg_output_d3 : out unsigned (6 downto 0); --Entrada del contador de score
		vidas : out std_logic_vector (4 downto 0)
   );
end pong_top;

--Arquitectura
architecture arch of pong_top is

   --Señales
	signal input_signal_d0, input_signal_d1, 
			 input_signal_d2, input_signal_d3 : integer range 0 to 10; --Entrada del contador de score
   signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
   signal video_on, pixel_tick: std_logic;
   signal rgb_reg, rgb_next, text_rgb : std_logic_vector(2 downto 0);
	signal e_0, e_1, e_2, e_3 : integer range 0 to 10; --Entrada en enteros de puntuaje max
	signal bandera : std_logic;
   signal rgb: std_logic_vector(2 downto 0);

-- Empieza el codigo
begin
   
   -- Instanciar la sincronizacion VGA
   vga_sync_unit: vga_sync   
	         port map(
		       fpga_50mhz_clk=> clk, 
		       fpga_reset    => not reset,
             video_on      => video_on, 
		       en_tick       => pixel_tick,
             h_sync        => hsync, 
	          v_sync        => vsync,
             pixel_x       => pixel_x, 
		       pixel_y       => pixel_y);
		
		
   -- Instanciar el generador de graficos
   pong_graph_an_unit: pong_graph_animate
           port map (
			   clk      => clk, 
			   reset    => not reset,
            btn      => not btn,
				--btn_test => btn_test,
			   video_on => video_on,
            pixel_x  => pixel_x, 
			   pixel_y  => pixel_y,
            graph_rgb => rgb_next,
				
				s0 => input_signal_d0,
				s1 => input_signal_d1,
				s2 => input_signal_d2,
				s3 => input_signal_d3,
				s4 => e_0,
				s5 => e_1,
				s6 => e_2,
				s7 => e_3,
				bandera => bandera,
				velocity => velocity,
				vidas => vidas);
				
				
	 -- Instanciar contador de puntaje (display HEX0)
	pong_contador_score_d0 : seven_segment_cntrl
			port map (
			input => input_signal_d0,
			seg_output => seg_output_d0);
			
	-- Instanciar contador de puntaje (display HEX1)
	pong_contador_score_d1  : seven_segment_cntrl
			port map (
			input => input_signal_d1,
			seg_output => seg_output_d1); 
			
	-- Instanciar contador de puntaje (display HEX2)
	pong_contador_score_d2 : seven_segment_cntrl
			port map (
			input => input_signal_d2,
			seg_output => seg_output_d2);
			
	-- Instanciar contador de puntaje (display HEX3)
	pong_contador_score_d3  : seven_segment_cntrl
			port map (
			input => input_signal_d3,
			seg_output => seg_output_d3);		
			
	-- Instanciar texto en pantalla
	text_unit : entity work.pong_text 
			port map (clk => clk, reset => reset, bandera => bandera, pixel_x => pixel_x,
			pixel_y => pixel_y, text_rgb => text_rgb, e0 => e_0, e1 => e_1,
			e2 => e_2, e3 => e_3
			);
			
   -- Buffer RGB
   process (clk, text_rgb, reset, pixel_tick)
   begin
      if (clk'event and clk='1' and pixel_tick = '1') then
         
			if (bandera = '0') then
            rgb_reg <= rgb_next or text_rgb;
         else
				rgb_reg <= text_rgb;
			end if;	
			
      end if;
   end process;
	
  rgb <= rgb_reg;
	
	red <= (rgb(2),rgb(2),rgb(2),rgb(2));
	green <= (rgb(1),rgb(1),rgb(1),rgb(1));
	blue <= (rgb(0),rgb(0),rgb(0),rgb(0));
	
end arch;
