LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY sonidos_pwm IS
  GENERIC(
      sys_clk         : INTEGER := 50000000;   --system clock frequency in Hz
      pwm_freq        : INTEGER := 200;        --PWM switching frequency in Hz
      bits_resolution : INTEGER := 12;          --bits of resolution setting the duty cycle
      phases          : INTEGER := 2);         --number of output pwms and phases
  PORT(
      clk       : IN  STD_LOGIC;                                  			  --system clock
     -- reset_n   : IN  STD_LOGIC;                                  		  --asynchronous reset
      ena       : IN  STD_LOGIC;                                --latches in new duty cycle
    --  duty      : IN  STD_LOGIC_VECTOR(bits_resolution-1 DOWNTO 0); 	  --duty cycle
      pwm_out   : OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0)       		  --pwm outputs
	 );         --pwm inverse outputs
END sonidos_pwm;

ARCHITECTURE arch OF sonidos_pwm IS
  constant period  : INTEGER := sys_clk/pwm_freq;                          --number of clocks in one pwm period
  signal duty      :  STD_LOGIC_VECTOR(9 DOWNTO 0);
 -- constant C : STD_LOGIC_VECTOR(bits_resolution-1 DOWNTO 0) := 
  TYPE counters IS ARRAY (0 TO phases-1) OF INTEGER RANGE 0 TO period - 1; --data type for array of period counters
  SIGNAL count     : counters := (OTHERS => 0);                            --array of period counters
  SIGNAL half_duty : INTEGER RANGE 0 TO period/2 := 0;                     --number of clocks in 1/2 duty cycle
BEGIN
  PROCESS(clk)

 variable contador : integer range 0 to 599999 := 1;

  BEGIN
	
	  if (clk 'event and clk = '1') then
			if (contador > 0 and contador < 599999) then
				contador := contador + 1;
			elsE
				contador := 1;
			end if;
			
		if (contador = 599999) then
			duty <= duty + 1;
		elsE
			duty <= duty;
		end if;
	end if;

		
	IF(clk'EVENT AND clk = '1') THEN                                --rising system clock edge
      IF(ena = '1') THEN                                                 --latch in new duty cycle
        half_duty <= conv_integer(duty)*period/(2**bits_resolution)/2;     --determine clocks in 1/2 duty cycle
      else
		 pwm_out <= "00";
		 end if;
		
		
      FOR i IN 0 to phases-1 LOOP                                        --create a counter for each phase
        IF(count(0) = period - 1 - i*period/phases) THEN                   --end of period reached
          count(i) <= 0;                                                     --reset counter
        ELSE                                                               --end of period not reached
          count(i) <= count(i) + 1;                                          --increment counter
        END IF;
      END LOOP;
		
		
      FOR i IN 0 to phases-1 LOOP                                        --control outputs for each phase
        IF(count(i) = half_duty) THEN                                      --phase's falling edge reached
          pwm_out(i) <= '0';                                                 --deassert the pwm output
		--	pwm_n_out(i) <= '1';                                               --assert the pwm inverse output
        ELSIF(count(i) = period - half_duty) THEN                          --phase's rising edge reached
          pwm_out(i) <= '1';                                                 --assert the pwm output
       --   pwm_n_out(i) <= '0';                                               --deassert the pwm inverse output
        END IF;
      END LOOP;
		
		
    END IF;
  END PROCESS;
END arch;
