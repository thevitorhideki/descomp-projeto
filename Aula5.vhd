library ieee;
use ieee.std_logic_1164.all;

entity Aula5 is
  -- Total de bits das entradas e saidas
  generic ( larguraDados : natural := 8;
        larguraEnderecos : natural := 9;
        simulacao : boolean := TRUE -- para gravar na placa, altere de TRUE para FALSE
  );
  port   (
    CLOCK_50 : in std_logic;
    KEY: in std_logic_vector(3 downto 0);
	 PALAVRA_CONTROLE : out std_logic_vector(11 downto 0);
    --ENTRADAB_ULA: out std_logic_vector(larguraDados-1 downto 0);
    PC_OUT: out std_logic_vector(larguraEnderecos-1 downto 0)
    --LEDR  : out std_logic_vector(larguraEnderecos downto 0)
	 --RegistradorA : out std_logic_vector (larguraDados-1 downto 0);
	 --OpUla : out std_logic_vector (1 downto 0)
	 --Flag_Sinal: out std_logic


  );
end entity;


architecture arquitetura of Aula5 is

  signal RMEM : std_logic;
  signal WMEM : std_logic;
  signal ROM_OUT : std_logic_vector(larguraDados-1 downto 0);
  signal INSTRUCAO : std_logic_vector(12 downto 0);
  
  signal MUX : std_logic_vector (larguraDados-1 downto 0);
  signal MUX4_OUT : std_logic_vector (larguraDados downto 0);
  signal REGA : std_logic_vector (larguraDados-1 downto 0);
  signal Saida_ULA : std_logic_vector (larguraDados-1 downto 0);
  signal Sinais_Controle : std_logic_vector (11 downto 0);
  signal Endereco : std_logic_vector (larguraDados downto 0);
  signal proxPC : std_logic_vector (larguraDados downto 0);
  signal CLK : std_logic;
  signal SelMUX : std_logic;
  signal Habilita_A : std_logic;
  signal Habilita_Flag : std_logic;
  signal Habilita_Retorno : std_logic;
  signal Operacao : std_logic_vector(1 downto 0);
  signal JMP : std_logic;
  signal JEQ : std_logic;
  signal JSR : std_logic;
  signal RET : std_logic;
  signal Entrada_Flag : std_logic;
  signal Saida_Flag : std_logic;
  signal SelMuxPC : std_logic_vector(1 downto 0);
  signal Endereco_Retorno : std_logic_vector (larguraDados downto 0);

  --signal Opcode : std_logic_vector (3 downto 0);

begin

-- Instanciando os componentes:

-- Para simular, fica mais simples tirar o edgeDetector
gravar:  if simulacao generate
CLK <= KEY(0);
else generate
detectorSub0: work.edgeDetector(bordaSubida)
        port map (clk => CLOCK_50, entrada => (not KEY(0)), saida => CLK);
end generate;

-- O port map completo do MUX.
MUX1 :  entity work.muxGenerico2x1  generic map (larguraDados => larguraDados)
        port map( entradaA_MUX => ROM_OUT,
                 entradaB_MUX => INSTRUCAO(7 downto 0),
                 seletor_MUX => SelMUX,
                 saida_MUX => MUX);

-- O port map completo do Acumulador.
REG : entity work.registradorGenerico   generic map (larguraDados => larguraDados)
          port map (DIN => Saida_ULA, DOUT => REGA, ENABLE => Habilita_A, CLK => CLK, RST => '0');
			 
REG_RETORNO : entity work.registradorGenerico   generic map (larguraDados => larguraDados+1)
          port map (DIN => proxPC, DOUT => Endereco_Retorno, ENABLE => Habilita_Retorno, CLK => CLK, RST => '0');

-- O port map completo do Program Counter.
PC : entity work.registradorGenerico   generic map (larguraDados => larguraEnderecos)
          port map (DIN => MUX4_OUT, DOUT => Endereco, ENABLE => '1', CLK => CLK, RST => '0');

incrementaPC :  entity work.somaConstante  generic map (larguraDados => larguraEnderecos, constante => 1)
        port map( entrada => Endereco, saida => proxPC);

ULA1 : entity work.ULASomaSub  generic map(larguraDados => larguraDados)
          port map (entradaA => REGA, entradaB => MUX, saida => Saida_ULA, seletor => Operacao, saida_flag => Saida_Flag);

ROM1 : entity work.memoriaROM   
          port map (Endereco => Endereco, Dado => INSTRUCAO);
			 
DEC : entity work.decoderInstru 
          port map (opcode => INSTRUCAO(12 downto 9), saida => Sinais_Controle);

RAM : entity work.memoriaRAM
		    port map(addr => INSTRUCAO(7 downto 0), we => WMEM, re => RMEM, habilita => INSTRUCAO(8), clk => CLK, dado_in => REGA, dado_out => ROM_OUT);
			 
Flipflop: entity work.flipflop
			 port map (DIN => Saida_Flag, DOUT => Entrada_Flag, ENABLE => Habilita_Flag, CLK => CLK, RST => '0');
			 
LogicaDesvio: entity work.LogicaDesvio
			 port map(entrada_flag => Entrada_Flag, entrada_jmp => JMP, entrada_jeq => JEQ, entrada_jsr => JSR, entrada_ret => RET, saida => SelMuxPC);
			 
MUX4: entity work.muxGenerico4x1
        port map( entradaA_MUX => proxPC,
                 entradaB_MUX => INSTRUCAO(8 downto 0),
					  entradaC_MUX => Endereco_Retorno,
					  entradaD_MUX => "000000000",
                 seletor_MUX => SelMuxPC,
                 saida_MUX => MUX4_OUT);
			 
Habilita_Retorno <= Sinais_Controle(11);			 
JMP <= Sinais_Controle(10);
RET <= Sinais_Controle(9);
JSR <= Sinais_Controle(8);
JEQ <= Sinais_Controle(7);
SelMUX <= Sinais_Controle(6);
Habilita_A <= Sinais_Controle(5);
Operacao <= Sinais_Controle(4 downto 3);
Habilita_Flag <= Sinais_Controle(2);
RMEM <= Sinais_Controle(1);
WMEM <= Sinais_Controle(0);


--ENTRADAB_ULA <= MUX;M
-- A ligacao dos LEDs:M
--LEDR <= Sinais_Controle(3 downto 2) & REGA;
PALAVRA_CONTROLE <= Sinais_Controle;

PC_OUT <= Endereco;
--OpULA <= Operacao;
--RegistradorA <= REGA;
--Flag_Sinal <= Entrada_Flag;

end architecture;