library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
        r1_sel : in std_logic;
        r2_sel : in std_logic;
        r3_sel : in std_logic;
        rmax_sel : in std_logic;
        rmin_sel : in std_logic;
        o_sel : in std_logic_vector(1 downto 0);
        o_end : out std_logic;
        o_dim : out std_logic;
        o_zero : out std_logic
    );
end datapath;

architecture arch of datapath is 

signal mux_r1 : std_logic_vector (7 downto 0);
signal o_r1 : std_logic_vector (7 downto 0);
signal sub_r1 : std_logic_vector (7 downto 0);
signal mult : std_logic_vector (15 downto 0);
signal mux_r2 : std_logic_vector (15 downto 0);
signal o_r2 : std_logic_vector(15 downto 0);
signal sum_r2 : std_logic_vector(15 downto 0);
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
signal sub_dim : std_logic_vector (7 downto 0);
signal shift_value : std_logic_vector (3 downto 0);
signal o_rshift : std_logic_vector (3 downto 0);
signal sub_shift : std_logic_vector (7 downto 0);
signal o_shift : std_logic_vector (15 downto 0);

begin
    
    --Mux utilizzato per inizializzare reg1 a num_colonne (r1_sel = '0'), e successivamente renderlo un contatore decrescente (r1_sel = '1').
    with r1_sel select
        mux_r1 <= i_data when '0',
                    sub_r1 when '1',
                    "XXXXXXXX" when others;
    
    --Registro reg1, utilizzato per conservare num_colonne (viene utilizzato per calcolare la dimensione totale dell'immagine).
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r1 <= "00000000";
        elsif rising_edge(i_clk) then
            if (r1_load = '1') then
                o_r1 <= mux_r1;
            end if;
        end if;
    end process;
    
    --Segnale utilizzato per indicare quando num_colonne o num_righe sono uguali a zero.
    o_zero <= '1' when (i_data = "00000000" or o_r1="00000000") else '0';
    
    --Segnale utilizzato per indicare l'ultimo ciclo di clock nel calcolo della dimensione totale dell'immagine.
    o_dim <= '1' when (o_r1 = "00000001") else '0';
    
    --Sottrattore che decrementa di '1' il valore di reg1 ogni ciclo di clock durante il calcolo della dimensione totale.
    sub_r1 <= std_logic_vector(unsigned(o_r1) - "00000001");
    
    --Sommatore utilizzato per calcolare la dimensione totale dell'immagine, usato per sommare num_righe a se stesso num_colonne volte.
    mult <= std_logic_vector(unsigned("00000000" & i_data) + unsigned(o_r2));
    
    --Mux utilizzato per inizializzare reg2 a zero (r2_sel = '0'), e successivamente renderlo un accumulatore per il calcolo della dimensione totale (r2_sel = '1').
    with r2_sel select
        mux_r2 <= "0000000000000000" when '0',
                    mult when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
    --Registro reg2, utilizzato per memorizzare la dimensione totale dell'immagine.    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_r2 <= "0000000000000000";
        elsif rising_edge(i_clk) then
            if(r2_load = '1') then
                o_r2 <= mux_r2;
            end if;
        end if;
    end process;
    
    --Sommatore utilizzato per sommare i contenuti di reg2 e reg3, al fine di calcolare l'indirizzo in cui salvare i pixel equalizzati corrispondenti a quelli di indirizzo contenuto in reg3.
    sum_out <= std_logic_vector(unsigned(o_r3) + unsigned(o_r2));
    
    --Mux utilizzato per inizializzare reg3 all'indirizzo del primo pixel (r3_sel = '0'), e successivamente renderlo un contatore crescente (r3_sel = '1').
    with r3_sel select
        mux_r3 <= "0000000000000010" when '0',
                    sum_r3 when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
   --Registro reg3, utilizzato per indicare l'indirizzo di memoria del pixel da leggere.    
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
    
    --Sommatore utilizzato per incrementare di '1' il valore di reg3 per ottenere l'indirizzo del pixel successivo.
    sum_r3 <= std_logic_vector(unsigned(o_r3) + "0000000000000001");
    
    --Sommatore utilizzato per generare il segnale da confrontare con reg3 per determinare la lettura dell'ultimo pixel.
    sum_r2 <= std_logic_vector(unsigned(o_r2) + "0000000000000010");
    
    --Segnale utilizzato per indicare la lettura dell'ultimo pixel dell'immagine.
    o_end <= '1' when (sum_r2 = o_r3) else '0';
    
    --Mux utilizzato per determinare se leggere l'indirizzo di memoria '0' (0_sel = '00'), '1' (0_sel = '01'), quello contenuto in reg3 (0_sel = '10') o quello dato dalla somma del contenuto di reg3 e la dimensione totale dell'immagine (0_sel = '11').
    with o_sel select
        o_address <= "0000000000000000" when "00",
                    "0000000000000001" when "01",
                    o_r3 when "10",
                    sum_out when "11",
                    "XXXXXXXXXXXXXXXX" when others;
    
    --Mux utilizzato per confrontare il contenuto di reg_max e il valore del pixel corrente, portando avanti quello maggiore.
    mux_rmax <= i_data when (o_rmax < i_data) else 
                o_rmax;
    
    --Mux utilizzato per inizializzare reg_max a zero (rmax_sel = '0'), e successivamente assegnargli il valore contenuto in mux_rmax (rmax_sel = '1').
    with rmax_sel select
        mux_rst_rmax <= "00000000" when '0',
                    mux_rmax when '1',
                    "XXXXXXXX" when others;
    
    --Registro reg_max, utilizzato per memorizzare il pixel di valore massimo dell'immagine.        
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
    
    --Mux utilizzato per confrontare il contenuto di reg_min e il valore del pixel corrente, portando avanti quello minore.
    mux_rmin <= i_data when (o_rmin > i_data) else
                o_rmin;
    
    --Mux utilizzato per inizializzare reg_min a 255 (rmin_sel = '0'), e successivamente assegnargli il valore contenuto in mux_rmin (rmin_sel = '1').                       
    with rmin_sel select
        mux_rst_rmin <= "11111111" when '0',
                    mux_rmin when '1',
                    "XXXXXXXX" when others;
    
    --Registro reg_min, utilizzato per memorizzare il pixel di valore minimo dell'immagine.                   
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
    
    --Sottrattore utilizzato per eseguire la differenza tra reg_max e reg_min per ottenere il DELTA_VALUE dell'immagine.
    sub_dim <= std_logic_vector(unsigned(o_rmax) - unsigned(o_rmin));
    
    --Controllo a soglie utilizzato per eseguire il calcolo dello SHIFT_LEVEL dell'immagine a partire dal suo DELTA_VALUE, evitando così la necessità di implementare il calcolo logaritmico.
    shift_value <= "0000" when (sub_dim = "11111111") else
            "0001" when ("01111111" <= sub_dim and sub_dim <= "11111110") else
            "0010" when ("00111111" <= sub_dim and sub_dim <= "01111110") else
            "0011" when ("00011111" <= sub_dim and sub_dim <= "00111110") else
            "0100" when ("00001111" <= sub_dim and sub_dim <= "00011110") else
            "0101" when ("00000111" <= sub_dim and sub_dim <= "00001110") else
            "0110" when ("00000011" <= sub_dim and sub_dim <= "00000110") else
            "0111" when ("00000001" <= sub_dim and sub_dim <= "00000010") else
            "1000" when (sub_dim = "00000000") else
            "XXXX";
    
    --Registro reg_shift, utilizzato per memorizzare lo SHIFT_LEVEL dell'immagine. 
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
    
    --Sottrattore utilizzato per eseguire la differenza tra il pixel corrente e reg_min..
    sub_shift <= std_logic_vector(unsigned(i_data) - unsigned(o_rmin));
    
    --Esecutore dello shift sinistro del valore sub_shift per una quantità SHIFT_LEVEL, al fine di ottenere TEMP_PIXEL.
    o_shift <= std_logic_vector(shift_left(unsigned("00000000" & sub_shift), to_integer(unsigned(o_rshift)))); 
    
    --Mux utilizzato per confrontare il contenuto di o_shift e '255', portando in uscita dal circuito quello minore.
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
        r1_sel : in std_logic;
        r2_sel : in std_logic;
        r3_sel : in std_logic;
        rmax_sel : in std_logic;
        rmin_sel : in std_logic;
        o_sel : in std_logic_vector(1 downto 0);
        o_end : out std_logic;
        o_dim : out std_logic;
        o_zero : out std_logic
    );
end component;
    
signal r1_load : std_logic;
signal r2_load : std_logic;
signal r3_load : std_logic;
signal rmax_load : std_logic;
signal rmin_load : std_logic;
signal rshift_load : std_logic;
signal r1_sel : std_logic;
signal r2_sel : std_logic;
signal r3_sel : std_logic;
signal rmax_sel : std_logic;
signal rmin_sel : std_logic;
signal o_sel : std_logic_vector(1 downto 0);
signal o_end : std_logic;
signal o_dim : std_logic;
signal o_zero : std_logic;

type S is (RST, START, INIT, DIM, PAUSE, LOAD_1, MINMAX, SHIFT, LOAD_2, EQLZ, DONE);
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
        r1_sel => r1_sel,
        r2_sel => r2_sel,
        r3_sel => r3_sel, 
        rmax_sel => rmax_sel,
        rmin_sel => rmin_sel, 
        o_sel => o_sel, 
        o_end => o_end,
        o_dim => o_dim,
        o_zero => o_zero
    );
    
    --Process utilizzato per scandire il passaggio di stato a ogni ciclo di clock o in caso di RESET.
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= RST;
        elsif rising_edge(i_clk) then
            cur_state <= next_state;
        end if;
    end process;
    
    --Process utilizzato per stabilire lo stato successivo del circuito in base a quello corrente e una serie di segnali (sia interni che esterni). Si noti che lo stato successivo corrisponde a quello corrente in mancanza di istruzioni differenti.
    process(cur_state, i_start, o_end)
    begin
        next_state <= cur_state;
        case cur_state is 
            when RST =>
                if i_start = '1' then
                    next_state <= START;
                end if;
            when START =>
                    next_state <= INIT;
            when INIT =>
                    next_state <= DIM;
            when DIM =>
                    if o_zero = '1' then
                        next_state <= DONE;
                    elsif  o_dim = '1' then
                        next_state <= LOAD_1;
                    else
                        next_state <= PAUSE;
                    end if;            
            when PAUSE =>
                    next_state <= DIM;
            when LOAD_1 =>
                    if o_end = '0' then
                        next_state <= MINMAX;
                    else
                        next_state <= SHIFT;
                    end if;
            when MINMAX =>
                    next_state <= LOAD_1;
            when SHIFT =>
                    next_state <= LOAD_2;
            when LOAD_2 =>
                    if o_end = '0' then 
                        next_state <= EQLZ;
                    else 
                        next_state <= DONE;
                    end if;
            when EQLZ => 
                    next_state <= LOAD_2;
            when DONE =>
                if i_start = '0' then
                    next_state <= RST;
                end if;
        end case;
    end process;
    
    --Process utilizzato per stabilire i valori dei segnali controllati dalla macchina a stati in base allo stato corrente.
    process (cur_state)
    begin
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
        rmax_load <= '0';
        rmin_load <= '0';
        rshift_load <= '0';
        r1_sel <= '0';
        r2_sel <= '0';
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
                r2_load <= '1';
                r3_load <= '1';
                r1_sel <= '0';
                r2_sel <= '0';
                r3_sel <= '0';
                rmax_sel <= '0';
                rmin_sel <= '0';
                rmax_load <= '1';
                rmin_load <= '1';
            when DIM =>
                o_sel <= "01";
                o_en <= '1';
                o_we <= '0';
                r1_load <= '1';
                r2_load <= '1';
                r3_load <= '0';
                r1_sel <= '1';
                r2_sel <= '1';
            when PAUSE =>
                o_sel <= "01";
                o_en <= '1';
                o_we <= '0';
                r1_load <= '0';
                r2_load <= '0';
                r1_sel <= '1';
                r2_sel <= '1';
            when LOAD_1 =>
                o_sel <= "10";
                o_en <= '1';
                o_we <= '0';
                r1_load <= '0';
                r2_load <= '0';
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