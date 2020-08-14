library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Ultrassom is
	port(	A, B: in std_logic_vector(3 downto 0);
			CLK27M: in std_logic;
			S: out std_logic_vector(3 downto 0));
end Ultrassom;

architecture Comportamento of Ultrassom is
	signal CONT: std_logic_vector (8 downto 0);
	signal CLKU: std_logic;
	
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
					CONT <= CONT + "000000001";
				end if;
			end process;
	
		CLKU <= CONT(8);
		--------------AQUI ACABA O CLK---------------
		D <= A(3 downto 0);
		CLR <= B(0);
		UP <= B(1);
		LOAD <= B(2);
		EN <= B(3);