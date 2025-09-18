library ieee;
use ieee.std_logic_1164.all;

entity main is
  -- Total de bits das entradas e saidas
  generic ( larguraDados : natural := 8;
        larguraEnderecos : natural := 9;
        simulacao : boolean := TRUE -- para gravar na placa, altere de TRUE para FALSE
  );
  port   (
    CLOCK_50 : in std_logic;
    KEY: in std_logic_vector(3 downto 0);
	 PC_OUT: out std_logic_vector(larguraDados downto 0);
	 Palavra_Controle: out std_logic_vector(11 downto 0)
  );
end entity;


architecture arquitetura of main is

  signal chavesX_ULA_B : std_logic_vector (larguraDados-1 downto 0);
  signal chavesY_MUX_A : std_logic_vector (larguraDados-1 downto 0);
  signal Saida_MUX : std_logic_vector (larguraDados-1 downto 0);
  signal REG1_ULA_A : std_logic_vector (larguraDados-1 downto 0);
  signal Saida_ULA : std_logic_vector (larguraDados-1 downto 0);
  signal Sinais_Controle : std_logic_vector (11 downto 0);
  signal opCode : std_logic_vector (12 downto 0);
  signal Endereco : std_logic_vector (8 downto 0);
  signal proxPC : std_logic_vector (8 downto 0);
  signal saidaMuxProxPC: std_logic_vector (8 downto 0);
  signal Chave_Operacao_ULA : std_logic;
  signal CLK : std_logic;
  signal saidaULAFlag: std_logic;
  signal flag_zero : std_logic;
  signal SelMUX : std_logic;
  signal Habilita_A : std_logic;
  signal Operacao_ULA : std_logic_vector(1 downto 0);
  signal habLeituraMEM: std_logic;
  signal habEscritaMEM: std_logic;
  signal saidaLogicaDesvio: std_logic_Vector(1 downto 0);
  signal enderecoRetorno: std_logic_vector(8 downto 0);

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
MUX_DadoULA :  entity work.muxGenerico2x1  generic map (larguraDados => larguraDados)
        port map( entradaA_MUX => chavesY_MUX_A,
                 entradaB_MUX =>  opCode(7 downto 0),
                 seletor_MUX => SelMUX,
                 saida_MUX => Saida_MUX);
					  
FlagZero: entity work.flipflop
			port map(DIN => saidaULAFlag, DOUT => flag_zero, ENABLE => Sinais_Controle(2), CLK => CLK, RST => '0');

MUX_PC :  entity work.muxGenerico4x1  generic map (larguraDados => larguraDados+1)
        port map(entrada0 => proxPC,
                 entrada1 =>  opCode(8 downto 0),
					  entrada2 => enderecoRetorno,
					  entrada3 => "000000000",
                 seletor_MUX => saidaLogicaDesvio,
                 saida_MUX => saidaMuxProxPC);

-- O port map completo do Acumulador.
REGA : entity work.registradorGenerico   generic map (larguraDados => larguraDados)
          port map (DIN => Saida_ULA, DOUT => REG1_ULA_A, ENABLE => Habilita_A, CLK => CLK, RST => '0');
			 
REG_RETORNO : entity work.registradorGenerico   generic map (larguraDados => larguraDados+1)
          port map (DIN => proxPC, DOUT => enderecoRetorno, ENABLE => Sinais_Controle(11), CLK => CLK, RST => '0');


-- O port map completo do Program Counter.
PC : entity work.registradorGenerico   generic map (larguraDados => larguraEnderecos)
          port map (DIN => saidaMuxProxPC, DOUT => Endereco, ENABLE => '1', CLK => CLK, RST => '0');

incrementaPC :  entity work.somaConstante  generic map (larguraDados => larguraEnderecos, constante => 1)
        port map( entrada => Endereco, saida => proxPC);


-- O port map completo da ULA:
ULA1 : entity work.ULASomaSub  generic map(larguraDados => larguraDados)
          port map (entradaA => REG1_ULA_A, entradaB => Saida_MUX, saida => Saida_ULA, saida_flag => saidaULAFlag, seletor => Operacao_ULA);

-- Falta acertar o conteudo da ROM (no arquivo memoriaROM.vhd)
ROM1 : entity work.memoriaROM   generic map (dataWidth => 13, addrWidth => 9)
          port map (Endereco => Endereco, Dado => opCode);
			 
DEC_Instru : entity work.decoderInstru
          port map (entrada_dec => opCode(12 downto 9), saida_dec => Sinais_Controle);
			 
LogicaDesvio1 : entity work.logicaDesvio
				port map(entrada_flag => flag_zero, 
							entrada_jmp => Sinais_Controle(10), 
							entrada_jeq => Sinais_Controle(7), 
							entrada_jsr => Sinais_controle(8),
							entrada_ret => Sinais_controle(9),
							saida => saidaLogicaDesvio);

SelMUX <= Sinais_Controle(6);
Habilita_A <= Sinais_Controle(5);
Operacao_ULA <= Sinais_Controle(4 downto 3);
habLeituraMEM <= Sinais_Controle(1);
habEscritaMEM <= Sinais_Controle(0);

RAM1: entity work.memoriaRAM   generic map (dataWidth => larguraDados, addrWidth => larguraDados)
          port map (addr => opCode(7 downto 0), we => habEscritaMEM, re => habLeituraMEM, habilita => opCode(8), dado_in => REG1_ULA_A, dado_out => chavesY_MUX_A, clk => CLK);

PC_OUT <= Endereco;
Palavra_Controle <= Sinais_Controle;

end architecture;