  
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 


ENTITY assignment4_tb IS
END assignment4_tb;

ARCHITECTURE BEHAVIORAL OF assignment4_tb IS

  SIGNAL finished : STD_LOGIC:= '0';
  CONSTANT period_time : TIME := 83333 ps;
  SIGNAL CLK : std_logic ;
  SIGNAL a32 : STD_LOGIC_VECTOR (31 downto 0);
  SIGNAL x32 : STD_LOGIC_VECTOR (31 downto 0);
  SIGNAL p : STD_LOGIC_VECTOR (127 downto 0);
  SIGNAL p64 : STD_LOGIC_VECTOR (63 downto 0);
  COMPONENT assignment4 IS
  
  PORT (
    CLK : in     std_logic;
            a32, x32 : in STD_LOGIC_VECTOR(31 downto 0);
            p : out STD_LOGIC_VECTOR(127 downto 0);
            p64 : out STD_LOGIC_VECTOR(63 downto 0)
    
  );
  END COMPONENT;
  
BEGIN
  Sim_finished : PROCESS 
    
  BEGIN
    wait for 1000 us;
    finished <= '1';
    wait;
  END PROCESS;
  assignment41 : assignment4  PORT MAP (
    CLK => CLK,
    a32 => a32,
    x32 => x32,
    p => p,
    p64 => p64
  );
  Sim_CLK : PROCESS 
    
  BEGIN
    CLK <= '0';
    WHILE finished /= '1' LOOP
      wait for 2 us;
      CLK <= not CLK;
    END LOOP;
  
    wait;
  END PROCESS;
  Sim_a32 : PROCESS 
    
  BEGIN
    WHILE finished /= '1' LOOP
      a32 <= x"3d1b58ba";
      x32 <= x"af812855";
      wait for 400.0001us;
      a32 <= x"3d1b58ba";
      x32 <= x"3d1b58ba";
      wait for 40.0001us;
      a32 <= x"af812855";
      x32 <= x"3d1b58ba";
      wait for 4.0001us;
      a32 <= x"af812855";
      x32 <= x"af812855";
      wait;
    END LOOP;
  
    wait;
  END PROCESS;
  Sim_x32 : PROCESS
  BEGIN
    WHILE finished /= '1' LOOP
      wait;
    END LOOP;
  
    wait;
  END PROCESS;
  
END BEHAVIORAL;