
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity project_tb is
end project_tb;

architecture projecttb of project_tb is
constant c_CLOCK_PERIOD         : time := 100 ns;
signal   tb_done                : std_logic;
signal   mem_address            : std_logic_vector (15 downto 0) := (others => '0');
signal   tb_rst                 : std_logic := '0';
signal   tb_start               : std_logic := '0';
signal   tb_clk                 : std_logic := '0';
signal   mem_o_data,mem_i_data  : std_logic_vector (7 downto 0);
signal   enable_wire            : std_logic;
signal   mem_we                 : std_logic;

type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);

signal i: std_logic_vector(3 downto 0) := "0000";

signal RAM0: ram_type := (0 => std_logic_vector(to_unsigned(  2  , 8)),
			 1 => std_logic_vector(to_unsigned(  2  , 8)),
			 2 => std_logic_vector(to_unsigned(  153, 8)),
			 3 => std_logic_vector(to_unsigned(  128, 8)),
			 4 => std_logic_vector(to_unsigned(  24 , 8)),
			 5 => std_logic_vector(to_unsigned(  86 , 8)),
                         others => (others =>'0'));
             -- delta=129 shift=1

signal RAM1: ram_type := (0 => std_logic_vector(to_unsigned(  4  , 8)),
			 1 => std_logic_vector(to_unsigned(  1  , 8)),
			 2 => std_logic_vector(to_unsigned(  4  , 8)),
			 3 => std_logic_vector(to_unsigned(  255, 8)),
			 4 => std_logic_vector(to_unsigned(  182, 8)),
			 5 => std_logic_vector(to_unsigned(  0  , 8)),
                         others => (others =>'0'));         
			 -- delta=255 shift=0    

signal RAM2: ram_type := (0 => std_logic_vector(to_unsigned(  1  , 8)),
			 1 => std_logic_vector(to_unsigned(  4  , 8)),
			 2 => std_logic_vector(to_unsigned(  255, 8)),
			 3 => std_logic_vector(to_unsigned(  255, 8)),
			 4 => std_logic_vector(to_unsigned(  255, 8)),
			 5 => std_logic_vector(to_unsigned(  255, 8)),
                         others => (others =>'0')); 
              -- delta=0 shift=8                

signal RAM3: ram_type := (0 => std_logic_vector(to_unsigned(  2  , 8)),
			 1 => std_logic_vector(to_unsigned(  2  , 8)),
			 2 => std_logic_vector(to_unsigned(  0  , 8)),
			 3 => std_logic_vector(to_unsigned(  0  , 8)),
			 4 => std_logic_vector(to_unsigned(  0  , 8)),
			 5 => std_logic_vector(to_unsigned(  0  , 8)),
                         others => (others =>'0'));
             -- delta=0 shift=8              

signal RAM4: ram_type := (0 => std_logic_vector(to_unsigned(  128  , 8)),
			 1      => std_logic_vector(to_unsigned(  128, 8)),
			 63     => std_logic_vector(to_unsigned(  25, 8)),
			 348    => std_logic_vector(to_unsigned(  34, 8)),
			 7222   => std_logic_vector(to_unsigned(  27, 8)),
			 15241  => std_logic_vector(to_unsigned(  95, 8)),
                         others => (others =>'0')); 
             -- delta=70 shift=2
             
signal RAM5: ram_type := (0 => std_logic_vector(to_unsigned(  2  , 8)),
			 1 => std_logic_vector(to_unsigned(  2  , 8)),
			 2 => std_logic_vector(to_unsigned(  37 , 8)),
			 3 => std_logic_vector(to_unsigned(  255, 8)),
			 4 => std_logic_vector(to_unsigned(  94 , 8)),
			 5 => std_logic_vector(to_unsigned(  0  , 8)),
                         others => (others =>'0'));
             -- delta=255 shift=0
             
signal RAM6: ram_type := (0 => std_logic_vector(to_unsigned(  0  , 8)),
			 1 => std_logic_vector(to_unsigned(  0  , 8)),
             2 => std_logic_vector(to_unsigned(  1  , 8)),
			 3 => std_logic_vector(to_unsigned(  2  , 8)),
			 4 => std_logic_vector(to_unsigned(  3  , 8)),
			 5 => std_logic_vector(to_unsigned(  4  , 8)),
                         others => (others =>'0')); 
             -- dim = 0 x 0
             
signal RAM7: ram_type := (0 => std_logic_vector(to_unsigned(  128  , 8)),
			 1 => std_logic_vector(to_unsigned(  0  , 8)),
             2 => std_logic_vector(to_unsigned(  1  , 8)),
			 3 => std_logic_vector(to_unsigned(  2  , 8)),
			 4 => std_logic_vector(to_unsigned(  3  , 8)),
			 5 => std_logic_vector(to_unsigned(  4  , 8)),
                         others => (others =>'0'));
             -- dim = N x 0 

signal RAM8: ram_type := (0 => std_logic_vector(to_unsigned(  0  , 8)),
			 1 => std_logic_vector(to_unsigned(  128  , 8)),
             2 => std_logic_vector(to_unsigned(  1  , 8)),
			 3 => std_logic_vector(to_unsigned(  2  , 8)),
			 4 => std_logic_vector(to_unsigned(  3  , 8)),
			 5 => std_logic_vector(to_unsigned(  4  , 8)),
                         others => (others =>'0'));
             -- dim = 0 x N
                                                                                                                                            
component project_reti_logiche is
port (
      i_clk         : in  std_logic;
      i_start       : in  std_logic;
      i_rst         : in  std_logic;
      i_data        : in  std_logic_vector(7 downto 0);
      o_address     : out std_logic_vector(15 downto 0);
      o_done        : out std_logic;
      o_en          : out std_logic;
      o_we          : out std_logic;
      o_data        : out std_logic_vector (7 downto 0)
      );
end component project_reti_logiche;


begin
UUT: project_reti_logiche
port map (
          i_clk      	=> tb_clk,
          i_start       => tb_start,
          i_rst      	=> tb_rst,
          i_data    	=> mem_o_data,
          o_address  	=> mem_address,
          o_done      	=> tb_done,
          o_en   	=> enable_wire,
          o_we 		=> mem_we,
          o_data    	=> mem_i_data
          );

p_CLK_GEN : process is
begin
    wait for c_CLOCK_PERIOD/2;
    tb_clk <= not tb_clk;
end process p_CLK_GEN;


MEM : process(tb_clk)
begin
if tb_clk'event and tb_clk = '1' then
    if enable_wire = '1' then
        if i = "0000" then
            if mem_we = '1' then
                RAM0(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM0(conv_integer(mem_address)) after 1 ns;
            end if;
        elsif i ="0001" then
            if mem_we = '1' then
                RAM1(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM1(conv_integer(mem_address)) after 1 ns;
            end if;
        elsif i = "0010" then 
            if mem_we = '1' then
                RAM2(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM2(conv_integer(mem_address)) after 1 ns;
            end if;
        elsif i = "0011" then 
            if mem_we = '1' then
                RAM3(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM3(conv_integer(mem_address)) after 1 ns;
            end if;
        elsif i = "0100" then 
            if mem_we = '1' then
                RAM4(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM4(conv_integer(mem_address)) after 1 ns;
            end if;
        elsif i = "0101" then 
            if mem_we = '1' then
                RAM5(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM5(conv_integer(mem_address)) after 1 ns;
            end if;
        elsif i = "0110" then 
            if mem_we = '1' then
                RAM6(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM6(conv_integer(mem_address)) after 1 ns;
            end if;
        elsif i = "0111" then 
            if mem_we = '1' then
                RAM7(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM7(conv_integer(mem_address)) after 1 ns;
            end if;
        elsif i = "1000" then 
            if mem_we = '1' then
                RAM8(conv_integer(mem_address))  <= mem_i_data;
                mem_o_data                      <= mem_i_data after 1 ns;
            else
                mem_o_data <= RAM8(conv_integer(mem_address)) after 1 ns;
            end if;
        end if;
    end if;
end if;
end process;


test : process is
begin 
    wait for 100 ns;
    wait for c_CLOCK_PERIOD;
    tb_rst <= '1';
    wait for c_CLOCK_PERIOD;
    wait for 100 ns;
    tb_rst <= '0';
    wait for c_CLOCK_PERIOD;
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait for 900 ns;
    tb_rst <= '1';
    wait for c_CLOCK_PERIOD;
    wait for 100 ns;
    tb_rst <= '0';
    tb_start <= '0';
    i <= "0001";

    
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0010";

    
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0011";
    
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0100";
    
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0101";
    
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0110";
    
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0111";
    
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "1000";


    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    
    
    -- delta=255 shift=0
	assert RAM1(6) = std_logic_vector(to_unsigned( 4 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  4  found " & integer'image(to_integer(unsigned(RAM1(6))))  severity failure; 
	assert RAM1(7) = std_logic_vector(to_unsigned( 255 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  255  found " & integer'image(to_integer(unsigned(RAM1(7))))  severity failure; 
	assert RAM1(8) = std_logic_vector(to_unsigned( 182 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  182  found " & integer'image(to_integer(unsigned(RAM1(8))))  severity failure; 
	assert RAM1(9) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM1(9))))  severity failure;
	
	-- delta=0 shift=8
	assert RAM2(6) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM2(6))))  severity failure; 
	assert RAM2(7) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM2(7))))  severity failure; 
	assert RAM2(8) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM2(8))))  severity failure; 
	assert RAM2(9) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM2(9))))  severity failure;

    -- delta=0 shift=8
    assert RAM3(6) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM3(6))))  severity failure; 
	assert RAM3(7) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM3(7))))  severity failure; 
	assert RAM3(8) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM3(8))))  severity failure; 
	assert RAM3(9) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM3(9))))  severity failure;

    -- delta=70 shift=2
    assert RAM4(16447) = std_logic_vector(to_unsigned( 100 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  100  found " & integer'image(to_integer(unsigned(RAM4(16447))))  severity failure; 
	assert RAM4(16732) = std_logic_vector(to_unsigned( 136 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  136  found " & integer'image(to_integer(unsigned(RAM4(16732))))  severity failure; 
	assert RAM4(23606) = std_logic_vector(to_unsigned( 108 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  108  found " & integer'image(to_integer(unsigned(RAM4(23606))))  severity failure; 
	assert RAM4(31625) = std_logic_vector(to_unsigned( 255 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  255  found " & integer'image(to_integer(unsigned(RAM4(31625))))  severity failure;
	
	-- delta=255 shift=0
    assert RAM5(6) = std_logic_vector(to_unsigned( 37 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  37  found " & integer'image(to_integer(unsigned(RAM5(6))))  severity failure; 
	assert RAM5(7) = std_logic_vector(to_unsigned( 255 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  255  found " & integer'image(to_integer(unsigned(RAM5(7))))  severity failure; 
	assert RAM5(8) = std_logic_vector(to_unsigned( 94 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  94  found " & integer'image(to_integer(unsigned(RAM5(8))))  severity failure; 
	assert RAM5(9) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM5(9))))  severity failure;
	
	-- dim = 0 x 0
    assert RAM6(2) = std_logic_vector(to_unsigned( 1 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  1  found " & integer'image(to_integer(unsigned(RAM6(6))))  severity failure; 
	assert RAM6(3) = std_logic_vector(to_unsigned( 2 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  2  found " & integer'image(to_integer(unsigned(RAM6(7))))  severity failure; 
	assert RAM6(4) = std_logic_vector(to_unsigned( 3 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  3  found " & integer'image(to_integer(unsigned(RAM6(8))))  severity failure; 
	assert RAM6(5) = std_logic_vector(to_unsigned( 4 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  4  found " & integer'image(to_integer(unsigned(RAM6(9))))  severity failure;
	
	-- dim = N x 0
    assert RAM7(2) = std_logic_vector(to_unsigned( 1 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  1  found " & integer'image(to_integer(unsigned(RAM7(6))))  severity failure; 
	assert RAM7(3) = std_logic_vector(to_unsigned( 2 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  2  found " & integer'image(to_integer(unsigned(RAM7(7))))  severity failure; 
	assert RAM7(4) = std_logic_vector(to_unsigned( 3 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  3  found " & integer'image(to_integer(unsigned(RAM7(8))))  severity failure; 
	assert RAM7(5) = std_logic_vector(to_unsigned( 4 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  4  found " & integer'image(to_integer(unsigned(RAM7(9))))  severity failure;
	
	-- dim = 0 x N
    assert RAM8(2) = std_logic_vector(to_unsigned( 1 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  1  found " & integer'image(to_integer(unsigned(RAM8(6))))  severity failure; 
	assert RAM8(3) = std_logic_vector(to_unsigned( 2 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  2  found " & integer'image(to_integer(unsigned(RAM8(7))))  severity failure; 
	assert RAM8(4) = std_logic_vector(to_unsigned( 3 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  3  found " & integer'image(to_integer(unsigned(RAM8(8))))  severity failure; 
	assert RAM8(5) = std_logic_vector(to_unsigned( 4 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  4  found " & integer'image(to_integer(unsigned(RAM8(9))))  severity failure;
	
    assert false report "Simulation Ended! TEST PASSATO" severity failure;

end process test;

end projecttb; 


