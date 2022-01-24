--CODIGO QUE CONTROLA LA ANIMACION Y EL PUNTAJE QUE SALE A TRAVES DE LOS DISPLAYS
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

--Entidad
entity pong_graph_animate is
   port(
	   
        clk:       in std_logic; 
		  reset:     in std_logic;
		  btn_test : in std_logic;
		  velocity : in std_logic_vector (1 downto 0);

        btn:       in std_logic_vector(1 downto 0);
        video_on:  in std_logic;
        pixel_x:   in std_logic_vector(9 downto 0);
		  pixel_y:   in std_logic_vector(9 downto 0);
        graph_rgb: out std_logic_vector(2 downto 0);
		  bandera : out std_logic;
		  s0,s1,s2,s3 ,s4,s5,s6,s7: out integer range 0 to 10; --s0, s1, s2, s3 salidas del contador de la partida
																				 --s4, s5, s6, s7 salidas del puntaje maximo, que puede o no
																				 --actualizarse.
		  vidas : out std_logic_vector (4 downto 0)
   );
end pong_graph_animate;


--Arquitectura
architecture arch of pong_graph_animate is

	----------------------------------------------------------------------------
   -- Signal declarations 
   ----------------------------------------------------------------------------
	-- refr_tick: 1-clock tick asserted at start of v-sync
   --       i.e., when the screen is refreshed (60 Hz)
   signal refr_tick: std_logic;
	signal result, result_max : unsigned (15 downto 0); --Resultado del contador de puntaje
	signal bandera_signal : std_logic;
	
   -- x, y coordinates (0,0) to (639,479)
   signal pix_x, pix_y: unsigned(9 downto 0);
   
	---------------------------------------------------------------------------
   -- Constant declarations
	---------------------------------------------------------------------------
	constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;
   
   ----------------------------------------------
   -- vertical strip as a wall
   ----------------------------------------------
   -- wall left, right boundary
   constant WALL_X_L: integer:=32;
   constant WALL_X_R: integer:=42;
   
   ----------------------------------------------
   -- right paddle bar
   ----------------------------------------------
   -- bar left, right boundary
   constant BAR_X_L: integer:=600;
   constant BAR_X_R: integer:=610;	
   -- bar top, bottom boundary
   signal bar_y_top, bar_y_btn: unsigned(9 downto 0);
   constant BAR_Y_SIZE: integer:=72;
   -- reg to track top boundary  (x position is fixed)
   signal bar_y_position, bar_y_next: unsigned(9 downto 0);
   -- bar moving velocity when the button are pressed
   constant BAR_Move: integer:=4;
   
   ----------------------------------------------
   -- square ball
   ----------------------------------------------
   constant BALL_SIZE: integer:= 8; 
   -- ball left, right boundary
   signal ball_x_lft, ball_x_rgt: unsigned(9 downto 0);
   -- ball top, bottom boundary
   signal ball_y_top, ball_y_btn: unsigned(9 downto 0);
   -- reg to track left, top boundary
   signal ball_x_position, ball_x_next: unsigned(9 downto 0);
   signal ball_y_position, ball_y_next: unsigned(9 downto 0);
   -- reg to track ball speed
   signal x_delta: unsigned(9 downto 0);
   signal y_delta: unsigned(9 downto 0);
   -- ball velocity can be pos or neg)
   constant BALL_V_P: unsigned(9 downto 0):= to_unsigned(2,10);
   constant BALL_V_N: unsigned(9 downto 0):= unsigned(to_signed(-2,10));
	
	shared variable puntaje_max: integer range 0 to 9999 := 0;
			
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
   
   ----------------------------------------------
   -- object output signals
   ----------------------------------------------
   signal wall_on, bar_on, sq_ball_on, rd_ball_on: std_logic;
   signal wall_rgb, bar_rgb, ball_rgb: std_logic_vector(2 downto 0);
	
	
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
   
   ----------------------------------------------
   -- refr_tick: 1-clock tick asserted at start of v-sync
   --       i.e., when the screen is refreshed (60 Hz)
   ----------------------------------------------
    refr_tick <= '1' when (pix_y=481) and (pix_x=0) else
                '0';
   
   ----------------------------------------------
   -- (wall) left vertical strip
   ----------------------------------------------
   -- pixel within wall
   wall_on <=
      '1' when (WALL_X_L<=pix_x) and (pix_x<=WALL_X_R) else
      '0';
   -- wall rgb output
   wall_rgb <= "001"; -- blue
   
   ---------------------------------------------------------------
   -- right vertical bar
   ---------------------------------------------------------------
   -- boundary
   bar_y_top <= bar_y_position;
   bar_y_btn <= bar_y_top + BAR_Y_SIZE - 1;
   -- pixel within bar
   bar_on <=
      '1' when (BAR_X_L<=pix_x) and (pix_x<=BAR_X_R) and
               (bar_y_top<=pix_y) and (pix_y<=bar_y_btn) else
      '0';
   -- bar rgb output
   bar_rgb <= "010"; --green
	
	-------------------------------------------------------------
   -- new bar y-position depending on the pressed button
	-------------------------------------------------------------
   process(clk, reset)
   begin
	if (reset= '1') then 
		bar_y_position <= (others=>'0');
	elsif(rising_edge(clk)) then 
	
		if(refr_tick = '1') then -- Mientras se refresca la pantalla a 60Hz
		
			if(btn(1)='1' and bar_y_btn <(MAX_Y-BAR_Move)) then 
				bar_y_position <= bar_y_position + BAR_Move; -- bar move down
				
			elsif(btn(0)='1' and bar_y_top > BAR_Move) then 
				bar_y_position <= bar_y_position - BAR_Move; -- bar move up
			end if;
			
		else
			bar_y_position <= bar_y_position; -- no move
		end if;
	end if; 
   end process;  

   -------------------------------------------------------------------
   -- square ball
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
   
   -- ------------------------------------------------- --
	-- process to determine whether x_delta and y_delta
	-- will be positive or negative, depending where the 
	-- ball is
	-- ------------------------------------------------- --   
	
	process(reset, clk, result, refr_tick, velocity, bandera_signal)
		-- contador de Score (mod)
	variable contador: integer range 0 to 9999 := 0;
	variable velocity_res : integer range 0 to 10 := 1;
	variable vidas_contador : integer range 0 to 10 := 5;
	
	begin
	
	case velocity is
		when "00" => velocity_res := 1;
		when "01" => velocity_res := 2;
		when "10" => velocity_res := 3;
		when "11" => velocity_res := 4;
	end case;
		
	case vidas_contador is
		when 5 => vidas <= "11111";
		when 4 => vidas <= "01111";
		when 3 => vidas <= "00111";
		when 2 => vidas <= "00011";
		when 1 => vidas <= "00001";
		when others => vidas <= "00000";
	 end case;
		
		
	 if (contador > puntaje_max) then
		puntaje_max := contador;
	 else
		puntaje_max := puntaje_max;
	 end if;
	 
	 if(reset = '1') then
	     x_delta <= ("0000000100");
        y_delta <= ("0000000100");
		  contador := 0;
		  vidas_contador := 5;

	 elsif( rising_edge(clk)) then
	 
		if(ball_y_top < 1) then            -- reach top
			y_delta <= BALL_V_P + velocity_res;
			
		elsif (ball_y_btn > (MAX_Y-1)) then  -- reach bottom
			y_delta <= BALL_V_N - velocity_res;
			
		elsif (ball_x_lft <= WALL_X_R)  then   -- reach wall
			x_delta <= BALL_V_P + velocity_res;    -- bounce back
			
		elsif ((BAR_X_L<=ball_x_rgt) and (ball_x_rgt<=BAR_X_R) and bandera_signal = '0') then	-- reach x of right bar
			
			if (bar_y_top<=ball_y_btn) and (ball_y_top<=bar_y_btn) then
				x_delta <= BALL_V_N - velocity_res; --hit, bounce back
				
				if (refr_tick = '1') then
				contador := contador + 10; --cuenta el puntaje
				end if;
				
			end if;
			
		elsif (ball_x_lft = (MAX_X-1))and (refr_tick = '1') and (vidas_contador > 0) then
				vidas_contador := vidas_contador - 1;
		elsif (ball_x_rgt = (MAX_X-1))and (refr_tick = '1') and (vidas_contador > 0) then
				vidas_contador := vidas_contador - 1;
		elsif (ball_x_lft = (MAX_X)) and (refr_tick = '1') and (vidas_contador > 0) then
				vidas_contador := vidas_contador - 1;
		end if;		
		
				if (vidas_contador = 0) then
					bandera_signal <= '1';
					
				else
					bandera_signal <= '0';
				end if;
				
		
	
	 end if; 
												
result<= to_bcd(to_unsigned(contador, 16));
result_max<= to_bcd(to_unsigned(puntaje_max, 16));
bandera <= bandera_signal;

   end process;
	
s0 <= to_integer(result(3 downto 0));
s1 <= to_integer(result(7 downto 4));
s2 <= to_integer(result(11 downto 8));
s3 <= to_integer(result(15 downto 12));   

s4 <= to_integer(result_max(3 downto 0));
s5 <= to_integer(result_max(7 downto 4));
s6 <= to_integer(result_max(11 downto 8));
s7 <= to_integer(result_max(15 downto 12));   


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
   process(video_on,wall_on,bar_on,rd_ball_on,
           wall_rgb, bar_rgb, ball_rgb)
   begin
      if video_on='0' then
          graph_rgb <= "000"; --blank
      else
         if wall_on='1' then
            graph_rgb <= wall_rgb;
         elsif bar_on='1' then
            graph_rgb <= bar_rgb;
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