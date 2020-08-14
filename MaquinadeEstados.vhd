library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DiagramaEstados is
	port(	A, B: in std_logic_vector(3 downto 0);
			CLK27M: in std_logic;
			S: out std_logic_vector(3 downto 0));
end DiagramaEstados;

architecture Comportamento of DiagramaEstados is
signal CONT: std_logic_vector (25 downto 0); --do Clock
signal CLK: std_logic; --do Clock

--------------------------------------------------
signal atual, prox: std_logic_vector (1 downto 0);
signal V: std_logic;
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

	V <= B(0);

	prox <= 	'0'&V when atual = "00" else
				"10" when atual = "01" else
				'1'&V when atual = "10" else
				V&V;

	S(1 downto 0) <= 	atual;
	S(2) <= atual(1) xor atual(0);
	
	process(CLK)
		begin
			if(CLK' event and CLK = '1') then
					atual <= prox;
					S(3) <= '0';
			end if;
		end process;

end Comportamento;


-- FUNCTION + --- to colocando aqui pra ir mais rapido
-- pag 517

-- (A: std_logic_vector;
--  B: std_logic_vector)
--	 return std_logic_vector is
-- variable carry: std_logic;
-- variable soma: std_logic_vector (A'left downto 0)
-- begin
-- 	carry := '0';
--		for i in 0 to A'left loop
--	* VARIABLE IMPORTA A ORDEM, POIS EH COMPUTACIONAL
--			soma(i) := A(i) xor B(i) xor carry
--			blablalba 
--
--* se for usar sobrecarga do -, só mudar o carry pra 1
--* e mudar de B pra notB, que eu não sei como faz
--
-- EXEMPLO DE SOMADOR USANDO A SOBRECARGA <----
-- signal So: std_logic_vector(4 downto 0)
-- begin
-- 	So <= ('0'&A) + ('0'&B) + ("0000"&Ci);
-- 	Co <=So(4);
-- 	S <= So(3 downto 0);

-- LISTA DE VHDL -> FAZER A FUNCAO MAIOR <

-- FUNCAO USANDO SOBRECARGA DAS FUNCOES < >

-- entidade -> entra A e B (std_logic_vector 4bits)
--					entra Ci (3 bits)
-- OBS: Ci = (A<B)i (A=B)i (A>B)i

-- Co <= "100" when A<B else
--			"001" when A>B else
--			Ci;