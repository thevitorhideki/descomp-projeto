library ieee;
use ieee.std_logic_1164.all;

entity LogicaDesvio is
  -- Total de bits das entradas e saidas
  generic ( larguraDados : natural := 8);
  port (
    entrada_flag, entrada_jmp, entrada_jeq, entrada_jsr, entrada_ret : in std_logic;
	 saida: out std_logic_vector(1 downto 0)
	);
end entity;

architecture comportamento of logicaDesvio is
  begin

  saida <= "01" when ( (entrada_jeq = '1' and entrada_flag = '1')  or entrada_jmp = '1' or entrada_jsr = '1') else
                      "10" when (entrada_ret = '1') else
                      "00";
end architecture;
