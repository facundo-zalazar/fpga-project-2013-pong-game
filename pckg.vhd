--CABECERA DEL CODIGO PRINCIPAL(TOP), SE DECLARAN LAS COMPONENT ACA PARA NO DESVIRTUAR EL MISMO
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package pckg is

component sincronismo_vga is
   port(
      fpga_50mhz_clk:      in std_logic;
	   fpga_reset:    in std_logic;
      h_sync:    out std_logic;
	   v_sync:    out std_logic;
    --  video_on: out std_logic;
	   en_tick:   out std_logic;
      pixel_x:  out std_logic_vector (9 downto 0);
	   pixel_y:  out std_logic_vector (9 downto 0)
    );
end component;

component sonidos_pwm IS
  GENERIC(
      sys_clk         : INTEGER := 50000000;
      pwm_freq        : INTEGER := 140;       
      bits_resolution : INTEGER := 8;          
      phases          : INTEGER := 2);        
  PORT(
      clk       : IN  STD_LOGIC;                                  		
    --  reset_n   : IN  STD_LOGIC;                                  		  
      ena       : IN  STD_LOGIC;                                
    --  duty      : IN  STD_LOGIC_VECTOR(bits_resolution-1 DOWNTO 0); 	  
      pwm_out   : OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0)       			  
	 );         --pwm inverse outputs
end component;

component animacion is
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
end component;

component texto is
	port (clk, reset, multiplayer : in std_logic;
			e0,e1,e2,e3,e4,e5,e6,e7 : in integer range 0 to 10; --salidas en entero del puntaje, ahora son entradas para mostrarlos en pantalla
			p_max0, p_max1, p_max2, p_max3 : in integer range 0 to 10;
			pixel_x, pixel_y : in std_logic_vector (9 downto 0);
			bandera_1 : in std_logic;	
			bandera_2 : in integer range 0 to 10;						--0 Juego, 1 GANO P1, 2 GANO P2
			text_rgb : out std_logic_vector (2 downto 0));
			
end component;
-- texto en pantalla


component debounce is
   port(
      clk, reset: in std_logic;
      sw: in std_logic;
      db_level, db_tick: out std_logic
   );
end component ;

component bitmap_gen is
   port(
        clk, reset: std_logic;
        btn: std_logic_vector(1 downto 0);
        sw: std_logic_vector(2 downto 0);
        video_on: in std_logic;
        pixel_x,pixel_y: in std_logic_vector(9 downto 0);
        bit_rgb: out std_logic_vector(2 downto 0)
   );
end component;

component xilinx_dual_port_ram_sync is
   generic(
      ADDR_WIDTH: integer:=6;
      DATA_WIDTH:integer:=8
   );
   port(
      clk: in std_logic;
      we: in std_logic;
      addr_a: in std_logic_vector(ADDR_WIDTH-1 downto 0);
      addr_b: in std_logic_vector(ADDR_WIDTH-1 downto 0);
      din_a: in std_logic_vector(DATA_WIDTH-1 downto 0);
      dout_a: out std_logic_vector(DATA_WIDTH-1 downto 0);
      dout_b: out std_logic_vector(DATA_WIDTH-1 downto 0)
   );
end component;

end pckg; 