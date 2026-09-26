# Co-processador-Grafico-em-FPGA-Problema-02

Coprocessador gráfico programável implementado em Verilog na plataforma Terasic DE1-SoC (Intel/Altera Cyclone V). O núcleo gera de forma autônoma um sinal de vídeo VGA de 640×480 @ ~60 Hz a partir de uma resolução lógica interna de 320×240, com três camadas gráficas independentes — background (tilemap), sprites e polígonos rasterizados — controladas por um conjunto de instruções definido pela própria equipe (ISA de 32 bits), executado por um datapath com unidade de controle, banco de registradores e ULA.

Projeto desenvolvido para a disciplina **MI — Sistemas Digitais** (Problema 02, semestre 2026.2).

---

## Sumário

- [Requisitos](#requisitos)
- [Arquitetura](#arquitetura)
- [ISA](#isa)
- [Hardware e Ferramentas](#hardware-e-ferramentas)
- [Estrutura do Repositório](#estrutura-do-repositório)
- [Módulos do Sistema](#módulos-do-sistema)
- [Programa de Demonstração](#programa-de-demonstração)
- [Compilação e Programação](#compilação-e-programação)
- [Testes](#testes)
- [Resultados e Análise](#resultados-e-análise)
- [Funcionalidades Não Atendidas](#funcionalidades-não-atendidas)
- [Autores](#autores)

---

## Requisitos

### Requisitos Funcionais

- ISA de 32 bits definida pela equipe, com formato de instruções documentado.
- Unidade de busca de instruções, registrador de instrução (IR), unidade de controle, banco de registradores, ULA, datapath e registrador de status.
- Mecanismo de sincronização com a saída de vídeo (sinais `valid`, `busy`, `done`).
- Motores de background, sprites e polígonos integrados como unidades funcionais acionadas por instruções.
- Unidade de controle de quadro, compositor e controlador VGA operando continuamente, independentes da execução das instruções.
- Saída VGA 640×480 a ~60 Hz, resolução lógica 320×240 com duplicação 2×2.
- Programa de demonstração escrito em Assembly da ISA criada pela equipe.
- Camada de background baseada em tilemap de 40×30 posições com tiles de 8×8 pixels.
- Até 32 sprites de 16×16 pixels com atributos configuráveis.
- Rasterização de retângulos e triângulos preenchidos com aritmética inteira.
- Composição de prioridades fixa entre camadas.
- Conversão de índice de cor de 8 bits para RGB de 24 bits.

### Requisitos Não Funcionais

- Descrição integral em Verilog, com arquitetura modular (controle, datapath, memórias, unidades funcionais e saída de vídeo separados).
- Todos os registradores e memórias com estratégia de reinicialização definida.
- Ausência de instabilidade visual, perda de sincronismo ou pixels indefinidos após a inicialização.
- Uso de memórias em bloco M10K sintetizadas a partir de IPs do Quartus.

---

## Arquitetura

O sistema é organizado em dois planos que operam em paralelo:

- **Plano de execução de instruções**: unidade de busca → IR → unidade de controle → datapath (banco de registradores, ULA, registrador de status) → unidades funcionais gráficas (background, sprites, polígonos).
- **Plano de vídeo (contínuo)**: controlador VGA → motores gráficos → compositor → paleta → DAC VGA.

A separação garante que a geração de vídeo permaneça estável independentemente do estado da execução das instruções.

### Diagrama de Blocos

```
             +---------------------+
             |  Memória de         |
             |  Instruções (.mif)  |
             +----------+----------+
                        |
                        v
             +---------------------+     +----------------------+
             |  Unidade de Busca   |---->|  Registrador de      |
             |  de Instruções      |     |  Instrução (IR)      |
             +---------------------+     +----------+-----------+
                                                  |
                                                  v
                                       +----------------------+
                                       |  Unidade de Controle |
                                       +----------+-----------+
                                                  |
                    +-----------------------------+-----------------+
                    v                             v                 v
             +-------------+             +--------------+   +-------------+
             |  Banco de   |             |     ULA      |   |  Registrador|
             | Registradores|            |              |   |  de Status  |
             +------+------+             +------+-------+   +-------------+
                    |                           |
                    +-------------+-------------+
                                  v
                    +-----------------------------+
                    |      Datapath / Controle    |
                    |   das unidades funcionais   |
                    +-------+-------+-------+
                            |       |       |
                            v       v       v
                     +---------+ +---------+ +--------------+
                     |  Motor  | |  Motor  | | Rasterizador |
                     |Background| | Sprites | |  Polígonos   |
                     +----+----+ +----+----+ +-------+------+
                          |           |              |
                          +-----+-----+--------------+
                                v
                        +---------------+       +---------------+
                        |  Compositor   |------>|   Paleta      |
                        +---------------+       +-------+-------+
                                                        |
                                                        v
                                                 +-------------+
                                                 |  Saída VGA  |
                                                 +-------------+
```

---

## ISA

\preencher{Documentar aqui: conjunto de instruções, mnemônicos, formatos R/I/J, tabela de opcodes, semântica de cada instrução e convenções de uso dos registradores. Incluir o formato de codificação das instruções gráficas (configuração de background, escrita de sprite, rasterização, escrita de paleta).}

---

## Hardware e Ferramentas

| Item | Especificação |
|---|---|
| Placa | Terasic DE1-SoC (Intel/Altera Cyclone V SoC) |
| FPGA | Cyclone V (5CSEMA5F31C6) |
| Ferramenta de síntese | Intel Quartus Prime (versão utilizada: \preencher{}) |
| Linguagem de descrição | Verilog-2001 |
| Saída de vídeo | VGA 640×480 @ ~60 Hz via DAC ADV7123 |
| Clock de entrada | 50 MHz (pino `CLOCK_50`) |
| Clock de pixel | 25 MHz |

---

## Estrutura do Repositório

```
.
├── DE1_SOC_golden_top.v        # Top-level físico da placa (padrão Terasic)
├── main.v                       # Núcleo do coprocessador gráfico
├── clock_reset.v                # Divisor de clock e sincronizador de reset
├── controlador_vga.v            # Gerador de sincronismo VGA 640×480
├── fsm_controle.v               # Unidade de controle principal
├── busca_instrucoes.v           # Unidade de busca de instruções
├── registrador_instrucao.v      # IR
├── banco_registradores.v        # Banco de registradores
├── ula.v                        # Unidade Lógica e Aritmética
├── registrador_status.v         # Registrador de status
├── motor_background.v           # Motor de tilemap
├── motor_sprites.v              # Motor de 32 sprites 16×16
├── rasterizador_poligonos.v     # Rasterizador de retângulos e triângulos
├── controle_quadro.v            # Unidade de controle de quadro
├── compositor.v                 # Compositor de prioridade entre camadas
├── ram_paleta.v                 # Decodificador RGB332 → RGB888
├── decodificador_hex.v          # Conversor para displays de 7 segmentos
├── *.mif                        # Arquivos de inicialização das memórias
├── programa_grafico.asm         # Programa de demonstração em Assembly da ISA
└── PBL_2-SD_grupo_4.qpf/.qsf    # Arquivo de projeto Quartus
```

---

## Módulos do Sistema

\preencher{Para cada módulo, descrever entradas, processamento e saídas, com a mesma estrutura usada no relatório. Incluir tabelas de pinagem, temporização e formato de sinais quando aplicável.}

---

## Programa de Demonstração

\preencher{Descrever o programa em Assembly da ISA criada pela equipe. Incluir listagem comentada, explicar o que cada instrução faz e como o programa é carregado (memória de instruções interna ou fila MMIO).}

---

## Compilação e Programação

1. Abra o projeto `PBL_2-SD_grupo_4.qpf` no Intel Quartus Prime.
2. Verifique se todos os arquivos `.v` e `.mif` estão no diretório do projeto.
3. Execute **Processing → Start Compilation**.
4. Conecte a placa DE1-SoC via USB-Blaster.
5. Abra o **Programmer**, carregue o `.sof` gerado e pressione **Start**.
6. Conecte um monitor VGA à saída de vídeo da placa.

---

## Testes

| Cenário | Descrição | Método |
|---|---|---|
| Transparência | Índice de cor 0 em sprites e polígonos deve deixar a camada inferior aparecer | Testbench + hardware |
| Espelhamento | Espelhamento horizontal e vertical por sprite | Testbench + hardware |
| Sobreposição | Resolução correta de pixels com múltiplas camadas ativas | Testbench + hardware |
| Prioridade | Regra fixa entre as camadas | Testbench + hardware |
| Execução de instruções | Cada instrução da ISA produz o efeito gráfico esperado | Testbench |
| Comandos inválidos | Comportamento da FSM diante de opcodes não definidos | Testbench |
| Sincronização `busy`/`done` | Sincronização entre unidades funcionais e compositor/VGA | Testbench de integração |

Scripts de automação: \preencher{descrever comandos usados para simulação, síntese e programação da placa}.

---

## Resultados e Análise

### Utilização de Recursos

\preencher{Inserir tabela extraída do Fitter do Quartus: ALMs, registradores, pinos, blocos de memória, DSPs.}

### Timing

\preencher{Inserir resultado do Timing Analyzer: frequência máxima reportada, setup slack por corner, caminho crítico identificado.}

### Desempenho

\preencher{Análise de latência de execução de instruções, throughput gráfico e eventuais gargalos.}

### Demonstração em Hardware

\preencher{Descrever os resultados observados na placa: cena renderizada, funcionamento dos três modos, execução do programa em Assembly. Incluir fotos ou referências a vídeos.}

---

## Funcionalidades Não Atendidas

\preencher{Listar de forma explícita todas as funcionalidades previstas em requisito que não foram implementadas ou que apresentam defeito conhecido nesta versão.}

### Melhorias Possíveis

\preencher{Sugestões de evolução: ampliação da ISA, implementação de frame buffer com troca de buffers, paleta RAM programável real, pipeline de instruções, integração com o HPS via MMIO.}
