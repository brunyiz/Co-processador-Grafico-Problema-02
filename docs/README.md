# Co-processador-Grafico-em-FPGA-Problema-02

<!-- Descrição de uma linha do projeto -->

Projeto desenvolvido para a disciplina **MI — Sistemas Digitais** (Problema 02, 2026.2).

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
<!-- Lista dos requisitos do enunciado -->

### Requisitos Não Funcionais
<!-- Modularidade, reinicialização, timing, etc. -->

---

## Arquitetura

<!-- Diagrama de blocos -->
<!-- Explicação do plano de execução de instruções e do plano de vídeo contínuo -->

---

## ISA

<!-- Mnemônicos, formatos, tabela de opcodes, convenções -->

---

## Hardware e Ferramentas

| Item | Especificação |
|---|---|
| Placa | |
| FPGA | |
| Ferramenta | |
| Linguagem | |
| Saída de vídeo | |
| Clock | |

---

## Estrutura do Repositório

```
<!-- Árvore de arquivos -->
```

---

## Módulos do Sistema

<!-- Um sub-tópico por módulo, com entradas/processamento/saídas -->

---

## Programa de Demonstração

<!-- Descrição e listagem do programa em Assembly -->

---

## Compilação e Programação

<!-- Passo a passo -->

---

## Testes

| Cenário | Descrição | Método |
|---|---|---|

---

## Resultados e Análise

### Utilização de Recursos

### Timing

### Desempenho

### Demonstração em Hardware

---

## Funcionalidades Não Atendidas

### Melhorias Possíveis

---

## Observações sobre o estado atual do projeto

Olhando o diagrama que você enviou, o projeto já tem muito mais do que o Problema 01 tinha. Alguns pontos que preciso te avisar, porque vão impactar o relatório e o README quando forem preenchidos:

1. **Unidade de busca + Unidade de controle + ARM já aparecem no diagrama.** Se o ARM já está na arquitetura, vocês precisam decidir e documentar se a **busca é ativa** (memória de instruções interna com `.mif`) ou **passiva** (fila de comandos via MMIO). Isso muda todo o Capítulo 2.3 e 2.4 do relatório.

2. **Três bancos de registradores separados** (um por motor: Background, Sprites, Polígonos). Isso é diferente do que se costuma ver em coprocessadores com banco único. Vale documentar a justificativa (isolamento por unidade funcional, evita contenção).

3. **Diagrama mostra somente o caminho de dados.** Falta no esboço um capítulo específico para a ISA — que é obrigatório pelo enunciado. Sem ISA definida, não dá para escrever nem o `datapath` nem o programa de demonstração.

4. **Sinais `valid`/`busy`/`done`** são exigidos pelo enunciado e não aparecem no diagrama atual. Precisa haver um capítulo ou subseção explicando como o controle sincroniza com as unidades funcionais.

5. **Registrador de status** também é obrigatório e não aparece no diagrama — precisa de seção dedicada.
