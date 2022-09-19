library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_data : out std_logic_vector (7 downto 0);
        r1_load : in std_logic;
        r2_load : in std_logic;
        r3_load : in std_logic;
        rmax_load : in std_logic;
        rmin_load : in std_logic;
        rshift_load : in std_logic;
        r3_sel : in std_logic;
        rmax_sel : in std_logic;
        rmin_sel : in std_logic;
        o_sel : in std_logic_vector(1 downto 0);
        o_end : out std_logic
    );
end datapath;

architecture arch of datapath is 

signal o_r1 : std_logic_vector (7 downto 0);
signal mult : std_logic_vector (15 downto 0);
signal sum_r2 : std_logic_vector(15 downto 0);
signal o_r2 : std_logic_vector(15 downto 0);
signal sum_out : std_logic_vector(15 downto 0);
signal mux_r3 : std_logic_vector(15 downto 0);
signal o_r3 : std_logic_vector (15 downto 0);
signal sum_r3 : std_logic_vector (15 downto 0);
signal mux_rmax : std_logic_vector (7 downto 0);
signal o_rmax : std_logic_vector (7 downto 0);
signal mux_rst_rmax : std_logic_vector (7 downto 0);
signal mux_rmin : std_logic_vector (7 downto 0);
signal mux_rst_rmin : std_logic_vector (7 downto 0);
signal o_rmin : std_logic_vector (7 downto 0);
signal sub_DIM : std_logic_vector (7 downto 0);
signal shift_value : std_logic_vector (3 downto 0);
signal o_rshift : std_logic_vector (3 downto 0);
signal sub_shift : std_logic_vector (7 downto 0);
signal o_shift : std_logic_vector (15 downto 0);

begin
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r1 <= "00000000";
        elsif rising_edge(i_clk) then
            if (r1_load = '1') then
                o_r1 <= i_data;
            end if;
        end if;
    end process;
    
    mult <= std_logic_vector(unsigned(o_r1) * unsigned(i_data));
    
    sum_out <= std_logic_vector(unsigned(o_r3) + unsigned(o_r2));
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r2 <= "0000000000000000";
        elsif rising_edge(i_clk) then
            if(r2_load = '1') then
                o_r2 <= mult;
            end if;
        end if;
    end process;
    
    with r3_sel select
        mux_r3 <= "0000000000000010" when '0',
                    sum_r3 when '1',
                    "XXXXXXXXXXXXXXXX" when others;
                    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r3 <= "0000000000000000";
        elsif rising_edge(i_clk) then
            if(r3_load = '1') then
                o_r3 <= mux_r3;
            end if;
        end if;
    end process;
    
    sum_r3 <= std_logic_vector(unsigned(o_r3) + "0000000000000001");
    
    sum_r2 <= std_logic_vector(unsigned(o_r2) + "0000000000000010");
    
    o_end <= '1' when (sum_r2 = o_r3) else '0';
    
    with o_sel select
        o_address <= "0000000000000000" when "00",
                    "0000000000000001" when "01",
                    o_r3 when "10",
                    sum_out when "11",
                    "XXXXXXXXXXXXXXXX" when others;
    
    mux_rmax <= i_data when (o_rmax < i_data) else 
                o_rmax;
                    
    with rmax_sel select
        mux_rst_rmax <= "00000000" when '0',
                    mux_rmax when '1',
                    "XXXXXXXX" when others;
                    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_rmax <= "00000000";
        elsif rising_edge(i_clk) then
            if(rmax_load = '1') then
                o_rmax <= mux_rst_rmax;
            end if;
        end if;
    end process;
    
    mux_rmin <= i_data when (o_rmin > i_data) else
                o_rmin;
                                
    with rmin_sel select
        mux_rst_rmin <= "11111111" when '0',
                    mux_rmin when '1',
                    "XXXXXXXX" when others;
                    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_rmin <= "00000000";
        elsif rising_edge(i_clk) then
            if(rmin_load = '1') then
                o_rmin <= mux_rst_rmin;
            end if;
        end if;
    end process;
    
    sub_DIM <= std_logic_vector(unsigned(o_rmax) - unsigned(o_rmin));
    
    shift_value <= "0000" when (sub_DIM = "11111111") else
            "0001" when ("01111111" <= sub_DIM and sub_DIM <= "11111110") else
            "0010" when ("00111111" <= sub_DIM and sub_DIM <= "01111110") else
            "0011" when ("00011111" <= sub_DIM and sub_DIM <= "00111110") else
            "0100" when ("00001111" <= sub_DIM and sub_DIM <= "00011110") else
            "0101" when ("00000111" <= sub_DIM and sub_DIM <= "00001110") else
            "0110" when ("00000011" <= sub_DIM and sub_DIM <= "00000110") else
            "0111" when ("00000001" <= sub_DIM and sub_DIM <= "00000010") else
            "1000" when (sub_DIM = "00000000") else
            "XXXX";
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_rshift <= "0000";
        elsif rising_edge(i_clk) then
            if(rshift_load = '1') then
                o_rshift <= shift_value;
            end if;
        end if;
    end process;
    
    sub_shift <= std_logic_vector(unsigned(i_data) - unsigned(o_rmin));
    
    o_shift <= ("00000000" & sub_shift) when (shift_value = "0000") else
            ("0000000" & sub_shift & "0") when (shift_value = "0001") else
            ("000000" & sub_shift & "00") when (shift_value = "0010") else
            ("00000" & sub_shift & "000") when (shift_value = "0011") else
            ("0000" & sub_shift & "0000") when (shift_value = "0100") else
            ("000" & sub_shift & "00000") when (shift_value = "0101") else
            ("00" & sub_shift & "000000") when (shift_value = "0110") else
            ("0" & sub_shift & "0000000") when (shift_value = "0111") else
            (sub_shift & "00000000") when (shift_value = "1000") else
            "XXXXXXXXXXXXXXXX";
    
    o_data <= o_shift (7 downto 0) when (o_shift < "0000000011111111") else
              "11111111";
    
end arch;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

component datapath is 
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_data : out std_logic_vector (7 downto 0);
        r1_load : in std_logic;
        r2_load : in std_logic;
        r3_load : in std_logic;
        rmax_load : in std_logic;
        rmin_load : in std_logic;
        rshift_load : in std_logic;
        r3_sel : in std_logic;
        rmax_sel : in std_logic;
        rmin_sel : in std_logic;
        o_sel : in std_logic_vector(1 downto 0);
        o_end : out std_logic
    );
end component;
    
signal r1_load : std_logic;
signal r2_load : std_logic;
signal r3_load : std_logic;
signal rmax_load : std_logic;
signal rmin_load : std_logic;
signal rshift_load : std_logic;
signal r3_sel : std_logic;
signal rmax_sel : std_logic;
signal rmin_sel : std_logic;
signal o_sel : std_logic_vector(1 downto 0);
signal o_end : std_logic;

type S is (RST, START, INIT, DIM, EMPTY, LOAD_1, MINMAX, SHIFT, LOAD_2, EQLZ, DONE);
signal cur_state : S;
signal next_state : S;

    
begin

    DATAPATH0: datapath port map(
        i_clk => i_clk,
        i_rst => i_rst, 
        i_data => i_data, 
        o_address => o_address, 
        o_data => o_data,
        r1_load => r1_load, 
        r2_load => r2_load,
        r3_load => r3_load, 
        rmax_load => rmax_load, 
        rmin_load => rmin_load, 
        rshift_load => rshift_load,
        r3_sel => r3_sel, 
        rmax_sel => rmax_sel,
        rmin_sel => rmin_sel, 
        o_sel => o_sel, 
        o_end => o_end
    );
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= RST;
        elsif rising_edge(i_clk) then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start, o_end)
    begin
        next_state <= cur_state;
        case cur_state is 
            when RST =>
                if i_start = '1' then
                    next_state <= START;
                end if;
            when START =>
                if i_start = '1' then
                    next_state <= INIT;
                end if;
            when INIT =>
                if i_start = '1' then 
                    next_state <= DIM;
                end if;
            when DIM =>
                if i_start = '1' then 
                    next_state <= EMPTY;
                end if;
            when EMPTY =>
                if i_start = '1' then
                    if o_end = '0' then 
                        next_state <= MINMAX;
                    else
                        next_state <= DONE;
                    end if;
                end if;
            when LOAD_1 =>
                if i_start = '1' then
                    if o_end = '0' then
                        next_state <= MINMAX;
                    else
                        next_state <= SHIFT;
                    end if;
                end if;
            when MINMAX =>
                if i_start = '1' then 
                    next_state <= LOAD_1;
                end if;
            when SHIFT =>
                if i_start = '1' then 
                    next_state <= LOAD_2;
                end if;
            when LOAD_2 =>
                if i_start = '1' then
                    if o_end = '0' then 
                        next_state <= EQLZ;
                    else 
                        next_state <= DONE;
                    end if;
                end if;
            when EQLZ => 
                if i_start = '1' then
                    next_state <= LOAD_2;
                end if;
            when DONE =>
                if i_start = '0' then
                    next_state <= RST;
                end if;
        end case;
    end process;
    
    process (cur_state)
    begin
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
        rmax_load <= '0';
        rmin_load <= '0';
        rshift_load <= '0';
        r3_sel <= '0';
        rmax_sel <= '0';
        rmin_sel <= '0';
        o_sel <= "00";
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        
        case cur_state is
            when RST =>
                o_done <= '0';
            when START =>
                o_sel <= "00";
                o_en <= '1';
                o_we <= '0';
            when INIT =>
                o_sel <= "01";
                o_en <= '1';
                o_we <= '0';
                r1_load <= '1';
                r2_load <= '0';
                r3_load <= '1';
                r3_sel <= '0';
                rmax_sel <= '0';
                rmin_sel <= '0';
                rmax_load <= '1';
                rmin_load <= '1';
            when DIM =>
                o_sel <= "01";
                o_en <= '1';
                o_we <= '0';
                r1_load <= '0';
                r2_load <= '1';
                r3_load <= '0';
            when EMPTY =>
                o_sel <= "10";
                o_en <= '1';
                o_we <= '0';
            when LOAD_1 =>
                o_sel <= "10";
                o_en <= '1';
                o_we <= '0';
            when MINMAX =>
                o_sel <= "10";
                o_en <= '0';
                o_we <= '0';
                r2_load <= '0';
                r3_load <= '1';
                r3_sel <= '1';
                rmax_sel <= '1';
                rmin_sel <= '1';
                rmax_load <= '1';
                rmin_load <= '1';
            when SHIFT =>
                r3_load <= '1';
                r3_sel <= '0';
                rmax_load <= '0';
                rmin_load <= '0';
                rshift_load <= '1';
            when LOAD_2 =>
                o_sel <= "10";
                o_en <= '1';
                o_we <= '0';
                r3_load <= '0';
                rshift_load <= '0';
            when EQLZ =>
                o_sel <= "11";
                o_en <= '1';
                o_we <= '1';
                r3_load <= '1';
                r3_sel <= '1';
            when DONE =>
                o_done <= '1';
        end case;
    end process;
end Behavioral;