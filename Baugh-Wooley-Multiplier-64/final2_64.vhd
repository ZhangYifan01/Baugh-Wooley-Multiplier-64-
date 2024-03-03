library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity assignment4 is
    port(
        CLK : in     std_logic;
        a32, x32 : in STD_LOGIC_VECTOR(31 downto 0);
        p : out STD_LOGIC_VECTOR(127 downto 0);
        p64 : out STD_LOGIC_VECTOR(63 downto 0)
    );
end entity assignment4;

architecture rtl of assignment4 is
    component extendedFA is
        port
        (
            PreviousA     : IN STD_LOGIC ;
            X             : IN STD_LOGIC ;
            PreviousCarry : IN STD_LOGIC ;
            PreviousSum   : IN STD_LOGIC ;
            Sum           : OUT STD_LOGIC ;
            Carry         : OUT STD_LOGIC ;
            A             : OUT STD_LOGIC ;
            clk           : IN STD_LOGIC
        );
    end component;
    component FA is
        port
        (
            A    : IN STD_LOGIC ;
            B    : IN STD_LOGIC ;
            Cin  : IN STD_LOGIC ;
            S    : OUT STD_LOGIC ;
            Cout : OUT STD_LOGIC ;
            clk  : IN STD_LOGIC
        );
    end component;
    component dff is
        port
        (
            D    : IN std_logic ;
            clk  : IN std_logic ;
            Q    : OUT std_logic
        );
    end component;
    
    --start of new code here
    type matrix is array (0 to 64) of std_logic_vector(0 to 64);
    signal block1, block2, block3, block4, block5, block6 : matrix;
    signal bmA, bmCarry, bmSum: matrix;
    
    signal p_temp : STD_LOGIC_VECTOR(127 downto 0);
    signal a,x : STD_LOGIC_VECTOR(63 downto 0);
    --signal block1out :  STD_LOGIC_VECTOR(31 downto 0);
    signal FAsignal :  STD_LOGIC_VECTOR(0 to 63);
begin
    a <= x"00000000" & a32;
    x <= x"00000000" & x32;
    initialx:
    for i in 0 to 63 generate
        block1(i)(0) <= x(i);
    end generate;
    b1:
    for i in 0 to 63 generate
        begin
        b1_vertical:
        for j in 0 to 63 generate
            begin
            b1dff: dff
            port map
            (
                D   => block1(i)(j),
                clk => clk,
                Q   => block1(i)(j + 1)
            );
        end generate b1_vertical;
    end generate b1;
    -- useful signals: block(0-31)(0-31), total of 32
    initialbmCarrybmA:
    for i in 0 to 63 generate
        bmCarry(i)(0) <= '0';
        bmA(i)(0) <= a(63 - i);
        bmSum(0)(i) <= '0';
        bmSum(i)(0) <= '0';
    end generate;
    bmatrix:
    for i in 0 to 63 generate
        begin
        bmatrix_vertical:
        for j in 0 to 63 generate
            begin
            mefa: extendedFA
            port map
            (
                PreviousA     => bmA(i)(j),
                X             => block1(j)(j),
                PreviousCarry => bmCarry(i)(j),
                PreviousSum   => bmSum(i)(j),
                Sum           => bmSum(i + 1)(j + 1),
                Carry         => bmCarry(i)(j + 1),
                A             => bmA(i)(j + 1),
                clk           => clk
            );
            
        end generate bmatrix_vertical;
    end generate bmatrix;
    -- useful signals: block(1-32)(32), total of 32 : A, Carry
    -- and block(32)(1-32): Sum

    --block2
    b2init:
    for i in 0 to 63 generate
        block2(i)(0) <= bmSum(64)(i + 1);
    end generate b2init;
    b2:
    for i in 0 to 63 generate
        begin
        b2_vertical:
        for j in 0 to 63 generate
            begin
            b1dff: dff
            port map
            (
                D   => block2(i)(j),
                clk => clk,
                Q   => block2(i)(j + 1)
            );
        end generate b2_vertical;
    end generate b2;
    -- useful signals: block(31-0?)(0-31), total of 32
    --block3
    b3init:
    for i in 0 to 63 generate
        block3(i)(0) <= block2(63 - i)(i);
    end generate b3init;
    b3:
    for i in 0 to 63 generate
        begin
        b3_vertical:
        for j in 0 to 63 generate
            begin
            b1dff: dff
            port map
            (
                D   => block3(i)(j),
                clk => clk,
                Q   => block3(i)(j + 1)
            );
        end generate b3_vertical;
    end generate b3;
    -- useful signals: block(0-31)(32)
    
    --link to final output p(i) <= bmSum(32)(i + 1);
    finalout31to0:
    for i in 0 to 63 generate
        begin
        p(i) <= block3(63 - i)(64);
        p64(i) <= block3(63 - i)(64);
    end generate finalout31to0;
    
    finalout62to31:
    for i in 0 to 62 generate
        begin
        p_temp(126-i) <= block6(i)(i);
    end generate finalout62to31;
    
    --finalout62to31 might be 1 cycle too fast, delay 1 cycle
    finalout62to31_new:
    for i in 0 to 62 generate
        begin
        output_correction: dff
        port map
        (
            D   => p_temp(126-i),
            clk => clk,
            Q   => p(126-i)
        );
        
        
        --p(62-i) <= p_temp(62-i);
    end generate finalout62to31_new;
    
    --full adders
    FAsignal(63) <= '0';
    bfa:
    for i in 0 to 62 generate
        begin
        mfa: FA
        port map
        (
            A    => block4(i)(62 - i),
            B    => block5(i)(62 - i),
            Cin  => FAsignal(i+1),
            S    => block6(i)(0), --p(62 - i)
            Cout => FAsignal(i),
            clk  => clk
        );
    end generate bfa;
    p(127) <= FAsignal(0);
    
    --block4:Sum
    b4init:
    for i in 0 to 62 generate
        block4(i)(0) <= bmSum(i+1)(64);
    end generate b4init;
    b4:
    for i in 0 to 62 generate
        begin
        b4_vertical:
        for j in 0 to 63 generate
            begin
            b1dff: dff
            port map
            (
                D   => block4(i)(j),
                clk => clk,
                Q   => block4(i)(j + 1)
            );
        end generate b4_vertical;
    end generate b4;
    --useful: block(0-30)(30-0?) old:bmSum(i+1)(32),

    --block5:Carry
    b5init:
    for i in 0 to 62 generate
        block5(i)(0) <= bmCarry(i)(64);
    end generate b5init;
    b5:
    for i in 0 to 62 generate --from 31 to 30
        begin
        b5_vertical:
        for j in 0 to 63 generate
            begin
            b1dff: dff
            port map
            (
                D   => block5(i)(j),
                clk => clk,
                Q   => block5(i)(j + 1)
            );
        end generate b5_vertical;
    end generate b5;
    --useful: block(0-30)(30-0) old:bmCarry(i)(32)
    
    --block6
    b6:
    for i in 0 to 62 generate
        begin
        b6_vertical:
        for j in 0 to 63 generate
            begin
            b1dff: dff
            port map
            (
                D   => block6(i)(j),
                clk => clk,
                Q   => block6(i)(j + 1)
            );
        end generate b6_vertical;
    end generate b6;

end architecture rtl;
---------------------------------components(efa, fa, dff)----------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity extendedFA is
    Port ( PreviousA : in STD_LOGIC;
        X : in STD_LOGIC;
        PreviousCarry : in STD_LOGIC;
        PreviousSum : in STD_LOGIC;
        Sum : out STD_LOGIC;
        Carry : out STD_LOGIC;
        A: out STD_LOGIC;
        clk : in STD_LOGIC
    );
end extendedFA;
architecture gate_level of extendedFA is
    signal AX: STD_LOGIC;
    signal temp1: STD_LOGIC;
    signal temp2: STD_LOGIC;
begin
    AX <= PreviousA and X;
    temp1 <= AX XOR PreviousSum XOR PreviousCarry;
    temp2 <= (AX AND PreviousSum) OR (PreviousCarry AND AX) OR (PreviousCarry AND PreviousSum);
    process (clk) is
    begin
        if (clk'event and clk = '1') then
            A <= PreviousA;
            Sum <= temp1;
            Carry <= temp2;
        end if;
    end process;
end architecture gate_level;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FA is
    Port ( A : in STD_LOGIC;
        B : in STD_LOGIC;
        Cin : in STD_LOGIC;
        S : out STD_LOGIC;
        Cout : out STD_LOGIC;
        clk : in STD_LOGIC
    );
end FA;
architecture gate_level of FA is
    signal temp1:STD_LOGIC;
    signal temp2:STD_LOGIC;
begin
    temp1 <= A XOR B XOR Cin;
    temp2 <= (A AND B) OR (Cin AND A) OR (Cin AND B);
    process (clk) is
    begin
        if (clk'event and clk = '1') then
            S <= temp1;
            Cout <= temp2;
        end if;
    end process;
end architecture gate_level;
library IEEE;
use IEEE.std_logic_1164.all;
entity dff is
    port ( D, clk : in std_logic;
        Q: out std_logic);
end dff;

Architecture behavior1 of dff is
begin
    output: process (clk) is
    begin
        if (clk'event and clk = '1') then
            Q <= D;
        end if;
    end process;
End Architecture;