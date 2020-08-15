library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity caixapreta is
    Port ( DIPSW : in  STD_LOGIC_VECTOR (3 downto 0);
	 
	        CLK27MHz : in  STD_LOGIC;
			  
           BUT0 : in  STD_LOGIC;
			  GPIO : out  STD_LOGIC_VECTOR (2 downto 0);
           LEDS : out  STD_LOGIC_VECTOR (3 downto 0));
end caixapreta;

architecture comportamento of caixapreta is
component contBCD port (CLK : in  STD_LOGIC; EN: in  STD_LOGIC; RCO: out  STD_LOGIC; Q : out  STD_LOGIC_VECTOR (3 downto 0)); end component;
component display port( NUM7, NUM6, NUM5, NUM4, NUM3, NUM2, NUM1, NUM0: in std_logic_vector(3 downto 0);
			 CLK: in std_logic; CS, Dout: out std_logic ); 	end component;

signal CLK,CLKdisp:STD_LOGIC;
signal cont:STD_LOGIC_VECTOR (23 downto 0);
signal cont2:STD_LOGIC_VECTOR (23 downto 0);
signal num0,num1,num2,num3,num4,num5,num6,num7,num8,num9,num10:STD_LOGIC_VECTOR (3 downto 0);
signal RCO0,RCO1,RCO2,RCO3,RCO4,RCO5,RCO6,RCO7,RCO8,RCO9,RCO10:STD_LOGIC;
signal cs,din:STD_LOGIC;


begin

process(CLK27MHz)
begin
	if(CLK27MHz'event and CLK27MHz = '1') then
		if (cont = "000000000000000000000000") then cont <= "000000000000000100001101";
		else cont <= cont-"000000000000000000000001";
		end if;
		cont2 <= cont2 + "000000000000000000000001";
	end if;
end process;
CLK <= cont(8);

U0: contBCD port map (CLK => CLK, EN => not BUT0, RCO => RCO0, Q => num0); 
U1: contBCD port map (CLK => CLK, EN => RCO0, RCO => RCO1, Q => num1); 
U2: contBCD port map (CLK => CLK, EN => RCO1, RCO => RCO2, Q => num2); 
U3: contBCD port map (CLK => CLK, EN => RCO2, RCO => RCO3, Q => num3); 
U4: contBCD port map (CLK => CLK, EN => RCO3, RCO => RCO4, Q => num4); 
U5: contBCD port map (CLK => CLK, EN => RCO4, RCO => RCO5, Q => num5); 
U6: contBCD port map (CLK => CLK, EN => RCO5, RCO => RCO6, Q => num6); 
U7: contBCD port map (CLK => CLK, EN => RCO6, RCO => RCO7, Q => num7); 
U8: contBCD port map (CLK => CLK, EN => RCO7, RCO => RCO8, Q => num8); 
U9: contBCD port map (CLK => CLK, EN => RCO8, RCO => RCO9, Q => num9); 
U10: contBCD port map (CLK => CLK, EN => RCO9, RCO => RCO10, Q => num10); 
U11: display port map (num7 => num10,num6 => num9,num5 => num8,num4 => num7,num3 => num6,num2 => num5,
                       num1 => num4,num0 => num3,clk => clkdisp,cs => cs,dout => din); 

clkdisp <= cont2(5);
--clkdisp <= num3(0);
GPIO(0) <= clkdisp;
GPIO(1) <= cs;
GPIO(2) <= din;
--LEDS <= num5;
LEDS <= '1'&clkdisp&cs&din;

end comportamento;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity contBCD is
    Port ( CLK : in  STD_LOGIC;
			  EN: in  STD_LOGIC;
           RCO: out  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (3 downto 0));
end contBCD;

architecture comportamento of contBCD is
signal cont:STD_LOGIC_VECTOR (3 downto 0);


begin

process(CLK)
begin
	if(CLK'event and CLK = '1') then
		if (EN = '1' and cont="1001") then cont <= "0000";
		elsif (EN = '1') then cont <= cont + "0001";
		end if;
	end if;
end process;
Q <= cont;
RCO <= cont(3) and cont(0) and EN;
end comportamento;

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
signal EN: std_logic_vector(8 downto 0):="000000000"; --ontador de 9 bits
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