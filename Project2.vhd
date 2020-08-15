library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Ultrassom is
	port(	
			CLK27M: in std_logic;
			ECHO: in std_logic;
			GPIO : out  std_logic_vector (2 downto 0);
end Ultrassom;

architecture behavior of Ultrassom is
	signal CONT: std_logic_vector (8 downto 0);
	signal CLK: std_logic;
	
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
	
		CLK <= CONT(8); --aproximadamente 10us
		--------------AQUI ACABA O CLK---------------
		
		V <= triggerPulse(CLK, atual);

		prox <= '0'&V	 when atual = "00" else
				ECHO&'1' when atual = "01" else
				'1'&ECHO when atual = "11" else
				"00";

		------------STATE MACHINE SETADA-----------



end behavior




function triggerPulse (CLK: std_logic;
						atual: std_logic_vector (1 downto 0))
						return std_logic is
variable TRIGGER: std_logic;
begin
	if(CLK'event and CLK = '1')
		TRIGGER <= '1' when atual = '00' else
					'0';
	end if;
	return TRIGGER;
end;




-- library IEEE;
-- use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.STD_LOGIC_ARITH.ALL;
-- use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- entity triggerPulse is
-- 	port(	
-- 			CLK: in std_logic;
-- 			TRIGGER: out std_logic;
-- end triggerPulse;

-- architecture behavior of triggerPulse is
-- 	process(CLK, atual)
-- 		begin
-- 			if(CLK'event and CLK = '1')
-- 				TRIGGER <= '1' when atual = '00' else
-- 							'0';
-- 			end if;
-- 		end process;

-- 	-------------AQUI ACABA O TRIGGERPULSE-------------
-- end behavior
