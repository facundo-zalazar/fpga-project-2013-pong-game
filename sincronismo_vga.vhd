
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Entidad
entity sincronismo_vga is
   port(
	  --------------------------------------------------
	  -- clock y reset
	  --------------------------------------------------
     fpga_50mhz_clk: in  std_logic;
	  fpga_reset    : in  std_logic;
	  --------------------------------------------------
	  -- Sync Horizontal y Vertical
	  --------------------------------------------------
     h_sync        : out std_logic;
	  v_sync        : out std_logic;
	  --------------------------------------------------
	  -- Habilitacion de Video
	  --------------------------------------------------
    -- video_on      : out std_logic;
	  en_tick       : out std_logic;
	  --------------------------------------------------
	  -- Pixels de Pantalla
	  --------------------------------------------------
     pixel_x       : out std_logic_vector (9 downto 0);
	  pixel_y       : out std_logic_vector (9 downto 0)
    );
end sincronismo_vga;


--Arquitectura
architecture arch of sincronismo_vga is

   ---------------------------------------------------------------------------
   -- Constant declarations
	-- VGA 640-by-480 sync parameters
	---------------------------------------------------------------------------
   constant HorizDply:    integer:=640; --Horizontal display area
   constant HorizRBorder: integer:=16 ; --Horizontal front porch
   constant HorizLBorder: integer:=48 ; --Horizontal back porch
   constant HorizRtrce:   integer:=96 ; --Horizontal retrace
   constant VertDply:     integer:=480; --Vertical display area
   constant VertRBorder:  integer:=10 ; --Vertical front porch
   constant VertLBorder:  integer:=33 ; --Vertical back porch
   constant VertRtrce:    integer:=2  ; --Vertical retrace
   ----------------------------------------------------------------------------
   -- Signal declarations 
   ----------------------------------------------------------------------------
   -- sync counters
   signal v_count: unsigned(9 downto 0);
   signal h_count: unsigned(9 downto 0);
   
   -- sync internal signals 
   signal h_sync_i: std_logic;
   signal v_sync_i: std_logic;
   
   -- status signal
   signal h_scan_end: std_logic; 
   signal v_scan_end: std_logic;

   -- 25MHz enable
   signal en_25mhz: std_logic;

-- Comienzo de Arch
		 begin
			
			--------------------------------------------------------
			-- Proceso: 25MHz clock enable pulse 
			-------------------------------------------------------- 
			en_25mhz_proc:process (fpga_50mhz_clk,fpga_reset)
			begin
				if (fpga_reset='1') then
				en_25mhz <= '0';
			  elsif (rising_edge(fpga_50mhz_clk)) then 
				en_25mhz <= not en_25mhz;
			  end if;
			end process en_25mhz_proc;
			--
			-------------------------------------------------------------------------
			-- ************************ Horizontal Sync ************************** --
			------------------------------------------------------------------------- 
			-- Proceso: mod-800 counter
			-- 
			mod_800_cnt_proc:process (fpga_50mhz_clk,fpga_reset)
			begin
				if (fpga_reset='1') then
				h_count <= (others =>'0');
			  elsif (rising_edge(fpga_50mhz_clk)) then 
				if(en_25mhz = '1') then 
					if(h_scan_end = '1') then 
						h_count <= (others =>'0');
					else
						h_count <= h_count + 1; 
					end if; 
				end if; 
			  end if;
			end process mod_800_cnt_proc;
			
			--------------------------------------------------------------------------
			-- horizontal scan status
			 h_scan_end <=                            -- end of horizontal counter 799 
				'1' when h_count=(HorizDply+HorizRBorder+HorizLBorder+HorizRtrce - 1) else 
				'0';
			
			-- horizontal and vertical sync, buffered to avoid glitch
			-- <= 656 and > 751
			-- -2 due to the fact output is registered -> 1 clock more to get out
			h_sync_i <=
				'1' when (h_count <= (HorizDply+HorizRBorder - 2)) or        
							(h_count >=  (HorizDply+HorizRBorder+HorizRtrce- 2)) else 
				'0';  
			  
			---------------------------------------------------------------------------
			-- Proceso: Sync Horizontal 
			h_sync_proc:process (fpga_50mhz_clk,fpga_reset)
			begin
				if (fpga_reset='1') then
				h_sync <= '0';
			  elsif (rising_edge(fpga_50mhz_clk)) then 
				if(en_25mhz = '1') then 
					h_sync <= h_sync_i; 			
				end if; 
			  end if;
			end process h_sync_proc;  
			
			
			-----------------------------------------------------------------------
			-- Proceso: Vertical  Sync 
			----------------------------------------------------------------------- 
			-- mod-525 counter
			-- 
			mod_525_cnt_proc:process (fpga_50mhz_clk,fpga_reset)
			begin
				if (fpga_reset='1') then
				v_count <= (others =>'0');
			  elsif (rising_edge(fpga_50mhz_clk)) then 
				if(en_25mhz = '1') then 
					if(v_scan_end = '1' and h_scan_end = '1') then 
						v_count <= (others =>'0');
					elsif (h_scan_end = '1') then 
						v_count <= v_count + 1; 
					end if; 
				end if; 
			  end if;
			end process mod_525_cnt_proc;
			
			-------------------------------------------------------------------------
			-- vertical scan status
			v_scan_end <=  								-- end of vertical counter 524
				'1' when v_count = (VertDply+VertRBorder+VertLBorder+VertRtrce - 1) else    
				'0';
			
			v_sync_i <=
				'1' when (v_count <= (VertDply+VertRBorder - 2)) or          --490
							(v_count >= (VertDply+VertRBorder+VertRtrce-2)) else --491
				'0';
			  
			v_sync_proc:process (fpga_50mhz_clk,fpga_reset)
			 begin
				if (fpga_reset='1') then
				v_sync <= '0';
			  elsif (rising_edge(fpga_50mhz_clk)) then 
				if(en_25mhz = '1') then 
					v_sync <= v_sync_i; 			
				end if; 
			  end if;
			end process v_sync_proc;    
			
			-------------------------------------------------------------------------
			-- Output Signals 
			-------------------------------------------------------------------------
			-- video on/off   
			--video_on <=
			--	'1' when (h_count<HorizDply-1) and (v_count<VertDply) else
			--	'0';
			  
			-- pixel position    
			pixel_x <= std_logic_vector(h_count);
			pixel_y <= std_logic_vector(v_count);
			en_tick <= en_25mhz;

 end arch;
