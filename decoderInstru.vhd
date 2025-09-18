library ieee;
use ieee.std_logic_1164.all;

entity decoderInstru is
  port ( entrada_dec : in std_logic_vector(3 downto 0);
         saida_dec : out std_logic_vector(11 downto 0)
  );
end entity;

architecture comportamento of decoderInstru is

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
  
  alias habEscritaRetorno: std_logic is saida_dec(11);
  alias jumpSignal: std_logic is saida_dec(10);
  alias retSignal: std_logic is saida_dec(9);
  alias jsrSignal: std_logic is saida_dec(8);
  alias jeqSignal: std_logic is saida_dec(7);
  alias SelMUX: std_logic is saida_dec(6);
  alias HabilitaA: std_logic is saida_dec(5);
  alias op: std_logic_vector(1 downto 0) is saida_dec(4 downto 3);
  alias HabFlagIgual: std_logic is saida_dec(2);
  alias HabLeituraMEM: std_logic is saida_dec(1);
  alias HabEscritaMEM: std_logic is saida_dec(0);

  begin
  
  habEscritaRetorno <= '1' when entrada_dec = JSR else '0';
  jumpSignal <= '1' when entrada_dec = JMP else '0';
  retSignal <= '1' when entrada_dec = RET else '0';
  jsrSignal <= '1' when entrada_dec = JSR else '0';
  jeqSignal <= '1' when entrada_dec = JEQ else '0';
  SelMUX <= '1' when entrada_dec = LDI else '0';
  HabilitaA <= '1' when entrada_dec = LDA or entrada_dec = SOMA or entrada_dec = SUB or entrada_dec = LDI else '0';
  op <= "10" when entrada_dec = LDA or entrada_dec = LDI else
		  "01" when entrada_dec = SOMA else "00";
  HabFlagIgual <= '1' when entrada_dec = CEQ else '0';
  HabLeituraMEM <= '1' when entrada_dec = LDA or entrada_dec = SOMA or entrada_dec = SUB or entrada_dec = CEQ else '0';
  HabEscritaMEM <= '1' when entrada_dec = STA else '0';

end architecture;