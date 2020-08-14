library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Ultrassom is
	port(	
			CLK27M: in std_logic;

			TRIGGER: in std_logic;
			ECO: out std_logic

			GPIO : out  std_logic_vector (2 downto 0);
end Ultrassom;

architecture Comportamento of Ultrassom is
	signal CONT: std_logic_vector (8 downto 0);
	signal CLKU: std_logic;
	
	----------------------------------------------------
	signal atual, prox: std_logic_vector (1 downto 0);
	signal V: std_logic;
	--------------------------------------------------
	begin
		process(CLK27M)
			begin
				if(CLK27M' event and CLK27M = '1') then
					CONT <= CONT + "000000001";
				end if;
			end process;
	
		CLKU <= CONT(8);
		--------------AQUI ACABA O CLK---------------

		
		prox <= '0'&V when atual = "10" else
				"01" when atual = "00" else
				atua&ECO;

				