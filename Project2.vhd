library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Ultrassom is
	Port(	CLK27M: in std_logic;
			ECHO: in std_logic;
			BUT0 : in  STD_LOGIC;
			GPIO : out  std_logic_vector (2 downto 0));
end Ultrassom;

architecture behavior of Ultrassom is

component contBCD port (CLK: in STD_LOGIC; EN: in  STD_LOGIC; CLR: in STD_LOGIC;
						RCO: out  STD_LOGIC;
						Q: out  STD_LOGIC_VECTOR (3 downto 0));
end component;
							
component FFD port (	CLK: in STD_LOGIC; 
						D: in STD_LOGIC_VECTOR (11 downto 0);
						Q: out  STD_LOGIC_VECTOR (11 downto 0));		
end component;

component display port (NUM7, NUM6, NUM5, NUM4, NUM3, NUM2, NUM1, NUM0: in std_logic_vector(3 downto 0);
						CLK: in std_logic;
						CS, Dout: out std_logic ); 					
end component;


signal CONT: std_logic_vector (8 downto 0);
signal CLK: std_logic;
----------------------------------------------------
signal atual, prox: std_logic_vector (1 downto 0);
signal trig, clear: std_logic;
----------------------------------------------------
signal RCO0, RCO1, RCO2:std_logic; --cascateamento dos BCDs
signal cont1, cont2, cont3: std_logic_vector (3	downto 0);
----------------------------------------------------
signal display: std_logic_vector (11 downto 0);
signal clkdisp: std_logic;
signal cs, din: std_logic;
signal LOAD: std_logic;
----------------------------------------------------
begin
	process(CLK27M)
		begin
			if(CONT = "000000000") then 
				CONT <= "100001101"; --269
			end if;
			
			if(CLK27M' event and CLK27M = '1') then
				CONT <= CONT - "000000001";
			end if;
	end process;
	
CLK <= CONT(8); --aproximadamente 10us
--------------AQUI ACABA O CLK---------------

	process(CLK)
		begin
		prox <= 	"01" when atual = "00" else
					ECHO&'1' when atual = "01" else
					'1'&ECHO when atual = "11" else
					"00";
------------STATE MACHINE SETADA-----------

		trig <= not atual(1) and not atual(0);
		clear <= not atual(1) and atual(0);
-------------SET TRIGGER E CLEAR------------

		LOAD <= atual(1) and not atual(0); --LOAD = '1' somente se estado atual for "10"
------------------SET LOAD -----------------

	end process;
	
	process(ECHO)
		begin
			if(ECHO'event and ECHO = '0') then
				if(LOAD = '1')
					display <= cont3&cont2&cont1; -- 3 contadores BCD em cascata
				end if;
			end if;
	end process;

----------------MOSTRA DISPLAY----------------

U0: contBCD port map (CLK => CLK, EN => not BUT0, RCO => RCO0, Q => cont1); 
U1: contBCD port map (CLK => CLK, EN => RCO0, RCO => RCO1, Q => cont2); 
U2: contBCD port map (CLK => CLK, EN => RCO1, RCO => RCO2, Q => cont3);
D3: display port map (	num7 => display(11 downto 8),
								num6 => display(7 downto 4),
								num5 => display(3 downto 0),
								num4 => "0000",
								num3 => "0000",
								num2 => "0000",
								num1 => "0000",
								num0 => "0000",
								clk => clkdisp, cs => cs, dout => din ); 
F4: FFD port map (CLK => CLK, D => display(11 downto 0));

clkdisp <= cont2(5);
--clkdisp <= num3(0);
GPIO(0) <= clkdisp;
GPIO(1) <= cs;
GPIO(2) <= din;
--LEDS <= num5;
LEDS <= '1'&clkdisp&cs&din;

atual <= proximo;

end behavior;

------------------------------------------------------------------------------------------
-----------------------------CONTADOR BCD COM CLEAR---------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity contBCD is
    Port (  CLK : in  STD_LOGIC;
			EN: in  STD_LOGIC;
			CLR: in STD_LOGIC;
            RCO: out  STD_LOGIC;
            Q : out  STD_LOGIC_VECTOR (3 downto 0));
end contBCD;

architecture comportamento of contBCD is
signal cont:STD_LOGIC_VECTOR (3 downto 0);

begin

process(CLK, CLR)
begin
	if(CLR = '1')
		then cont <= "0000";
	elsif(CLK'event and CLK = '1') then
		if (EN = '1' and cont="1001") then cont <= "0000";
		elsif (EN = '1') then cont <= cont + "0001";
		end if;
	end if;
end process;

Q <= cont;
RCO <= cont(3) and cont(0) and EN;
end comportamento;

------------------------------------------------------------------------------------------
---------------------FLIP FLOPS D PARA INTERFACE COM O DISPLAY----------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FFD is
	Port (  CLK: in  STD_LOGIC;
			D: in STD_LOGIC_VECTOR (11 downto 0);
            Q: out  STD_LOGIC_VECTOR (11 downto 0));
end FFD;

architecture comportamento of FFD is
signal A: std_logic_vector(3 downto 0); -- seria a entrada D do FFD

begin

process(CLK)
begin
	if(CLK'event and CLK = '1')
		then A <= D(3 downto 0);
	else A <= A;
	end if;
end process;

Q <= A(3 downto 0);

end comportamento;

-------------------------------------------------------------------------------------------
-------------------------------------DISPLAY-----------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity display is		--Implementao do componente Display
port( NUM7, NUM6, NUM5, NUM4, NUM3, NUM2, NUM1, NUM0: in std_logic_vector(3 downto 0);
		CLK: in std_logic; 
		CS, Dout: out std_logic);
end display;

architecture comportamento of display is

--Declarao e inicializao das variveis---------------------
signal EN: std_logic_vector(8 downto 0):="000000000"; --contador de 9 bits
signal palavra, proxpalavra: std_logic_vector(15 downto 0):="0000000000000000"; --palavra na fila de bits e proxpalavra
signal proxnum, proxdisplay: std_logic_vector(3 downto 0); --sinais de controle de algarismo e posicao do display
signal Dis: std_logic_vector(2 downto 0); --Sinal da posicao da posicao a partir do contador de 9 bits
signal proxfig,Fig: std_logic_vector(1 downto 0):="00"; --Sinal que pega o bit mais significativo e o sexto bit, para a logica de configuraao da palavra
signal configur: std_logic:='0';
---------------------------------------------------------------

begin

		Dis<=EN(7 downto 5); --Posicao do display baseada no contador de 9 bits
		
		proxnum <=  NUM1 when Dis="001" else 
					NUM2 when Dis="010" else
					NUM3 when Dis="011" else
					NUM4 when Dis="100" else
					NUM5 when Dis="101" else
					NUM6 when Dis="110" else
					NUM7 when Dis="111" else
					NUM0;

		proxdisplay <= 	"0010" when Dis="001" else 
						"0011" when Dis="010" else
						"0100" when Dis="011" else
						"0101" when Dis="100" else
						"0110" when Dis="101" else
						"0111" when Dis="110" else
						"1000" when Dis="111" else
						"0001";
	
		proxpalavra<=	"0000110000000001" when (configur = '0' and Dis = "000") else -- modo normal
						"0000101111111111" when (configur = '0' and Dis = "001") else -- scan todos
						"0000101000001111" when (configur = '0' and Dis = "010") else -- intensidade
						"0000100111111111" when (configur = '0' and Dis = "011") else -- BCD
						--"1111111111111111" when (configur = '0' and Dis = "100") else
						--"0000001100000111";
						--"0000001101010101";
						--"0000"&"0001"&"01010111";
						"0000"&proxdisplay&"0000"&proxnum;
						
		 
	process(CLK) --Processo que atualiza os valores do componente
	begin
			if(CLK'event and CLK='0') then -- As configuraes de proximo estado podem ser feitas a qualquer momento
				EN<=EN+"000000001";
				configur <= EN(8) or configur;

				if(EN(4) = '0') then --Coloca a proxpalavra na fila de bits no "final" do CS='1' 
					palavra<=proxpalavra;
				else
					palavra<=palavra(14 downto 0)&'0'; --Coloca o proximo bit da fila no bus a cada clock quando CS='0'					
--					palavra<='0'&palavra(15 downto 1); --Coloca o proximo bit da fila no bus a cada clock quando CS='0'
				end if;
			end if;
	end process;


	Dout<=palavra(15); --Bus: sinal sendo passado para o display
--	Dout<=palavra(0); --Bus: sinal sendo passado para o display
	CS <= not EN(4);  --Sinal CS que controla a habilitao da escrita no display
end comportamento;