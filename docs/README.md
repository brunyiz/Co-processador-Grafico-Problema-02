# Co-processador-Grafico-em-FPGA-Problema-02

Núcleo de um coprocessador gráfico programável implementado em Verilog na plataforma Terasic DE1-SoC (Intel/Altera Cyclone V). O projeto dá continuidade ao núcleo gráfico desenvolvido no Problema 01, transformando-o em uma arquitetura programável organizada de forma semelhante a processadores convencionais, com ISA de 32 bits, unidade de busca de instruções, unidade de controle, datapath, banco de registradores, ULA e registrador de status, integrando os motores gráficos (background, sprites e polígonos) como unidades funcionais acionadas por instruções.

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

#### Arquitetura mínima

O sistema deve possuir, no mínimo:

- Instruction Set Architecture (ISA) de 32 bits.
- Unidade de busca de instruções.
- Registrador de Instrução (IR).
- Unidade de Controle.
- Banco de registradores.
- Unidade Lógica e Aritmética (ULA).
- Datapath.
- Registrador de status.
- Unidades funcionais gráficas (motores de background, sprites e polígonos).
- Compositor.
- Controlador VGA.

#### Unidades funcionais mínimas

1. Unidade de busca de instruções.
2. Unidade de Controle.
3. Unidade Lógica e Aritmética.
4. Motor de Background.
5. Motor de Sprites.
6. Rasterizador de Polígonos.
7. Unidade de Controle de Quadro.
8. Compositor.
9. Controlador VGA.

O compositor, a unidade de controle de quadro e o controlador VGA devem operar continuamente, independentemente da execução das instruções.

#### Programa gráfico

Deve existir, conforme a estratégia adotada pela equipe:

- **Busca ativa**: memória de instruções interna ao projeto contendo um pequeno programa gráfico armazenado em arquivo `.mif` ou `.hex`.
- **Busca passiva**: arquitetura projetada para receber instruções de uma fila de comandos proveniente da interface MMIO com o processador ARM, acompanhada de um programa em Assembly do ARM que use os recursos do coprocessador.

#### Programa de demonstração

- Pelo menos um programa escrito em Assembly da ISA criada pela equipe.
- Sintaxe da ISA definida pela própria equipe.

#### Comunicação e sincronização

- Mecanismo de sincronização com o sinal VGA (ex.: sinais `valid`, `busy`, `done`).
- Toda operação do coprocessador deve ser consequência da execução de uma instrução pertencente à ISA definida.

#### Herança do Problema 01

- Motores de background, sprites e polígonos tratados como unidades funcionais do novo coprocessador.
- Integração com o compositor, a paleta e a saída VGA já existentes.

### Requisitos Não Funcionais

- Descrição integral em Verilog, com arquitetura modular (controle, datapath, memórias, unidades funcionais e saída de vídeo separados).
- Todos os registradores e memórias com estratégia definida de reinicialização ou inicialização.
- Ausência de instabilidade visual, perda de sincronismo ou pixels indefinidos após a inicialização.
- Uso de memórias em bloco M10K sintetizadas a partir de IPs do Quartus.
- Código-fonte com organização e comentários que permitam manutenção por terceiros.

### Entregáveis Obrigatórios 

- Código RTL completo do coprocessador gráfico e do top-level utilizado na DE1-SoC.
- Projeto Quartus com todos os arquivos necessários para compilação e programação da placa.
- Repositório GitHub organizado, contendo código, documentação, arquivos de síntese e instruções de reprodução.

---

## Arquitetura

<!-- Diagrama de blocos e descrição do plano de execução de instruções
     e do plano de vídeo contínuo. -->

### Unidades Funcionais

<!-- Descrição de cada unidade funcional e como se relacionam. -->

### Fluxo de Dados e Controle

<!-- Caminho das instruções, dados e sinais de controle. -->

### Sincronização com VGA

<!-- Sinais valid/busy/done e mecanismo de sincronização. -->

---

## ISA

<!-- Mnemônicos, formatos R/I/J, tabela de opcodes, semântica,
     convenções de uso dos registradores, formato de codificação
     das instruções gráficas. -->

### Formatos de Instrução

### Conjunto de Instruções

### Convenções de Registradores

---

## Hardware e Ferramentas

| Item | Especificação |
|---|---|
| Placa | |
| FPGA | |
| Ferramenta de síntese | |
| Linguagem de descrição | |
| Saída de vídeo | |
| Clock de entrada | |
| Clock de pixel | |

---

## Estrutura do Repositório

```
<!-- Árvore de arquivos -->
```

---

## Módulos do Sistema

<!-- Um sub-tópico por módulo, com entradas, processamento e saídas. -->

---

## Programa de Demonstração

<!-- Descrição e listagem do programa em Assembly da ISA.
     Explicar o que cada instrução faz e como o programa é carregado. -->

---

## Compilação e Programação

<!-- Passo a passo para abrir o projeto Quartus, compilar,
     programar a placa, conectar o monitor VGA. -->

---

## Testes

### Cenários de Teste

| Cenário | Descrição | Método |
|---|---|---|
| Transparência | | |
| Espelhamento | | |
| Sobreposição | | |
| Prioridade | | |
| Troca de buffers | | |
| Comandos inválidos | | |
| Sincronização busy/done | | |

### Testbenches

- Testbench por módulo principal.
- Testbench de integração do coprocessador.

### Scripts de Automação

<!-- Comandos usados para simulação, síntese e programação. -->

---

## Resultados e Análise

### Utilização de Recursos

<!-- Tabela extraída do Fitter: ALMs, registradores, pinos,
     blocos de memória, DSPs. -->

### Timing

<!-- Frequência máxima reportada, setup slack por corner,
     caminho crítico identificado. -->

### Desempenho

<!-- Latência de execução de instruções, throughput gráfico, gargalos. -->

### Demonstração em Hardware

<!-- Resultados observados na placa, fotos, referências a vídeos. -->

---

## Funcionalidades Não Atendidas

<!-- Lista explícita das funcionalidades previstas em requisito
     que não foram implementadas ou que apresentam defeito. -->

### Melhorias Possíveis

<!-- Sugestões de evolução. -->

---

## Autores

- *
- *
- *

Bacharelado em Engenharia de Computação — UEFS
Disciplina: MI — Sistemas Digitais (2026.2)

---

## Referências

- TERASIC. **DE1-SoC User Manual**, rev. F. Terasic Technologies Inc., 2018.
- UNIVERSIDADE ESTADUAL DE FEIRA DE SANTANA. **Problema #2 — 2026.2: Sistema Digital**. Departamento de Tecnologia, Área de Eletrônica, 2026.
- PINEDA, J. **A Parallel Algorithm for Polygon Rasterization**. SIGGRAPH '88, 1988.

## Avisos sobre o estado atual do projeto vs. requisitos

Comparando o diagrama que você mandou com o que o enunciado exige:

| Requisito do enunciado | Status no diagrama atual |
|---|---|
| ISA de 32 bits | Não aparece no diagrama — precisa de seção própria |
| Unidade de busca de instruções | Presente |
| Registrador de Instrução (IR) | Não aparece explicitamente no diagrama |
| Unidade de Controle | Presente |
| Banco de registradores | Presente (3, um por motor) |
| ULA | **Não aparece no diagrama** |
| Datapath | Presente implicitamente |
| Registrador de status | **Não aparece no diagrama** |
| Unidade de Controle de Quadro | **Não aparece no diagrama** |
| Compositor | Presente |
| Controlador VGA | Presente |

### Pontos que vocês precisam decidir antes de preencher o relatório

1. **ULA e registrador de status**: o enunciado exige ambos. Ou vocês já têm e só não estão no diagrama, ou precisam adicionar. Isso é item obrigatório da ISA.

2. **Unidade de Controle de Quadro**: exigida na Seção 3.1, não aparece no diagrama. Precisa existir e ser documentada.

3. **IR (Registrador de Instrução)**: obrigatório na Seção 3 do enunciado. Se ele está dentro da "Unidade de Controle" no diagrama, vale separar ou explicar isso na documentação.

4. **Busca ativa ou passiva de instruções**: o diagrama mostra ARM conectado à Unidade de Busca, o que sugere **busca passiva** (ARM fornece as instruções). Se for esse o caso, o enunciado exige que exista um programa em Assembly do ARM usando os recursos do coprocessador — não apenas o programa em Assembly da ISA própria.

5. **Mecanismo valid/busy/done**: exigido implicitamente na Seção 2 dos objetivos de aprendizagem. Precisa ser documentado.

6. **Testes de "troca de buffers"**: exigido na Seção 5. Se vocês não implementaram frame buffer, digam isso explicitamente na seção "Funcionalidades Não Atendidas".

4. **Sinais `valid`/`busy`/`done`** são exigidos pelo enunciado e não aparecem no diagrama atual. Precisa haver um capítulo ou subseção explicando como o controle sincroniza com as unidades funcionais.

5. **Registrador de status** também é obrigatório e não aparece no diagrama — precisa de seção dedicada.
