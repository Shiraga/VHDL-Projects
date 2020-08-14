library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Contador is
	port(	A, B: in std_logic_vector(3 downto 0);
			CLK27M: in std_logic;
			S: out std_logic_vector(3 downto 0));
end Contador;

--entrada -> CLR, UP, LOAD, EN e CLK
--Saida -> Q (LEDs) e RCO (estrutural) 

architecture Comportamento of Contador is
signal CONT: std_logic_vector (25 downto 0); --do CLK
signal CLK: std_logic; --do CLK tbem

----------------------------------------------------
signal CONT2: std_logic_vector (3 downto 0);

signal CLR, UP, LOAD, EN: std_logic;
signal D: std_logic_vector(3 downto 0);
signal Q: std_logic_vector(3 downto 0);
--------------------------------------------------
begin
	process(CLK27M)
		begin
			if(CLK27M' event and CLK27M = '1') then
				CONT <= CONT + "00000000000000000000000001";
			end if;
		end process;

	CLK <= CONT(25);
	--------------AQUI ACABA O CLK---------------
	D <= A(3 downto 0);
	CLR <= B(0);
	UP <= B(1);
	LOAD <= B(2);
	EN <= B(3);
	
	
	process(CLK, CLR)
		begin
			if(CLR = '1') then
				CONT2 <= "0000";
			elsif(CLK' event and CLK = '1') then
				if (LOAD = '0') then
					CONT2 <= D;
				elsif(EN = '1' and UP = '1') then
					CONT2 <= CONT2 + "0001";
				elsif(EN = '1' and UP = '0') then
					CONT2 <= CONT2 - "0001";
				end if;
			end if;
		end process;
		
		
	S <= CONT2;
	
	--RCO <= '1' when (CONT = "1111" and UP = '1') else
	--			'1' when (CONT = "0000" and UP = '0') else
	--			'0';
end Comportamento;