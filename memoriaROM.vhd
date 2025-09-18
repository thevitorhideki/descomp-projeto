library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoriaROM is
   generic (
          dataWidth: natural := 13;
          addrWidth: natural := 9
    );
   port (
          Endereco : in std_logic_vector (addrWidth-1 DOWNTO 0);
          Dado : out std_logic_vector (dataWidth-1 DOWNTO 0)
    );
end entity;

architecture assincrona of memoriaROM is

  constant NOP  : std_logic_vector(3 downto 0) := "0000";
  constant LDA  : std_logic_vector(3 downto 0) := "0001";
  constant SOMA : std_logic_vector(3 downto 0) := "0010";
  constant SUB  : std_logic_vector(3 downto 0) := "0011";
  constant LDI  : std_logic_vector(3 downto 0) := "0100";
  constant STA  : std_logic_vector(3 downto 0) := "0101";
  constant JMP  : std_logic_vector(3 downto 0) := "0110";
  constant JEQ  : std_logic_vector(3 downto 0) := "0111";
  constant CEQ  : std_logic_vector(3 downto 0) := "1000";
  constant JSR  : std_logic_vector(3 downto 0) := "1001";
  constant RET  : std_logic_vector(3 downto 0) := "1010";
  

  type blocoMemoria is array(0 TO 2**addrWidth - 1) of std_logic_vector(dataWidth-1 DOWNTO 0);

  function initMemory
        return blocoMemoria is variable tmp : blocoMemoria := (others => (others => '0'));
  begin
      -- Palavra de Controle = SelMUX, Habilita_A, Reset_A, Operacao_ULA
      -- Inicializa os endereços:
        tmp(0)  := JSR & std_logic_vector(to_unsigned(14,9));   -- Desta posicao para baixo, é necessário acertar os valores
        tmp(1)  := JMP & std_logic_vector(to_unsigned(5,9));
        tmp(2)  := JEQ & std_logic_vector(to_unsigned(9,9));
        tmp(3)  := NOP & std_logic_vector(to_unsigned(0,9));
        tmp(4)  := NOP & std_logic_vector(to_unsigned(0,9));
        tmp(5)  := LDI & std_logic_vector(to_unsigned(5,9));
        tmp(6)  := STA & std_logic_vector(to_unsigned(256,9));
        tmp(7)  := CEQ & std_logic_vector(to_unsigned(256,9));
		  tmp(8)  := JMP & std_logic_vector(to_unsigned(2,9));
        tmp(9)  := NOP & std_logic_vector(to_unsigned(0,9));
		  tmp(10) := LDI & std_logic_vector(to_unsigned(4,9));
		  tmp(11) := CEQ & std_logic_vector(to_unsigned(256,9));
		  tmp(12) := JEQ & std_logic_vector(to_unsigned(3,9));
		  tmp(13) := JMP & std_logic_vector(to_unsigned(13,9));
		  tmp(14) := NOP & std_logic_vector(to_unsigned(0,9));
		  tmp(15) := RET & std_logic_vector(to_unsigned(0,9));


        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;