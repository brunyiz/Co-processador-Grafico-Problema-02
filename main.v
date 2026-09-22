// main.v
// Centralizador do nucleo do coprocessador grafico.
// Conecta os geradores de clock, sincronismo de video, decodificador de comandos,
// motores graficos (background, sprites, poligonos), compositor e paleta de cores.
// Alinhado com as portas fisicas em maiusculas especificadas no top-level 'DE1_SOC_golden_top.v'.

module main (
	// Clocks e Resets da Placa DE1-SoC (Sinais de Entrada Fisicos)
	input  wire        CLOCK_50,         // Clock de 50 MHz vindo da placa (CLOCK_50)
	input  wire [3:0]  KEY,              // Botoes mecanicos da placa (KEY[3:0]), ativos em 0
	input  wire [9:0]  SW,               // Chaves deslizantes da placa (SW[9:0])

	// Feedbacks Visuais da Placa (LEDs e Displays de Saida)
	output wire [9:0]  LEDR,             // LEDs vermelhos de status da placa (LEDR[9:0])
	output wire [6:0]  HEX0,             // Segmentos do display de 7 seg 0 (HEX0)
	output wire [6:0]  HEX1,             // Segmentos do display de 7 seg 1 (HEX1)
	output wire [6:0]  HEX2,             // Segmentos do display de 7 seg 2 (HEX2)
	output wire [6:0]  HEX3,             // Segmentos do display de 7 seg 3 (HEX3)
	output wire [6:0]  HEX4,             // Segmentos do display de 7 seg 4 (HEX4)
	output wire [6:0]  HEX5,             // Segmentos do display de 7 seg 5 (HEX5)

	// Conexoes do DAC de Video VGA (ADV7123)
	output wire [7:0]  VGA_R,            // Canal de cor Vermelho de 8 bits (VGA_R)
	output wire [7:0]  VGA_G,            // Canal de cor Verde de 8 bits (VGA_G)
	output wire [7:0]  VGA_B,            // Canal de cor Azul de 8 bits (VGA_B)
	output wire        VGA_HS,           // Pulso de Sincronismo Horizontal (VGA_HS)
	output wire        VGA_VS,           // Pulso de Sincronismo Vertical (VGA_VS)
	output wire        VGA_CLK,          // Clock sincrono do pixel de 25 MHz (VGA_CLK)
	output wire        VGA_BLANK_N,      // Sinalizador de area ativa de video (VGA_BLANK_N)
	output wire        VGA_SYNC_N        // Sinalizador de sincronismo no Verde (VGA_SYNC_N)
);

	// Mapeamento dos pinos maiusculos da placa para os nomes internos do projeto
	wire        clock_50mhz = CLOCK_50;
	wire [3:0]  key_n       = KEY;
	wire [9:0]  sw          = SW;

	// Barramentos de sinal para feedbacks e barramento de exibicao interna
	wire [9:0]  ledr;
	wire [6:0]  hex0;
	wire [6:0]  hex1;
	wire [6:0]  hex2;
	wire [6:0]  hex3;
	wire [6:0]  hex4;
	wire [6:0]  hex5;

	// Barramentos internos para conector VGA
	wire [7:0]  vga_r;
	wire [7:0]  vga_g;
	wire [7:0]  vga_b;
	wire        vga_hs;
	wire        vga_vs;
	wire        vga_clock;
	wire        vga_blank_n;
	wire        vga_sync_n;

	// Associacao sincrona dos barramentos internos as portas fisicas maiusculas de saida
	assign LEDR        = ledr;
	assign HEX0        = hex0;
	assign HEX1        = hex1;
	assign HEX2        = hex2;
	assign HEX3        = hex3;
	assign HEX4        = hex4;
	assign HEX5        = hex5;

	assign VGA_R       = vga_r;
	assign VGA_G       = vga_g;
	assign VGA_B       = vga_b;
	assign VGA_HS      = vga_hs;
	assign VGA_VS      = vga_vs;
	assign VGA_CLK     = vga_clock;
	assign VGA_BLANK_N = vga_blank_n;
	assign VGA_SYNC_N  = vga_sync_n;

	// Sinais de clock e reset internos sincronizados
	wire clock_vga;          // Clock de pixel de 25 MHz para VGA
	wire reset_vga_n;        // Reset sincrono ativo em nivel baixo (KEY0)

	// Divisor de clock e sincronizador de reset
 clock_reset divisor_clock (
	   .CLOCK_50  (clock_50mhz),
	   .reset_n   (key_n[0]),   // O botao KEY0 esta fixado como reset fisico
	   .vga_clk   (clock_vga),
	   .vga_rst_n (reset_vga_n)
	);
    
    assign vga_clock = clock_vga;

   // Coordenadas fisicas da varredura VGA e sinal de apagamento
   wire [9:0] coord_x_vga;   // Coluna de pixel na tela (0 a 639)
   wire [9:0] coord_y_vga;   // Linha de pixel na tela (0 a 479)
   wire       area_visivel;   // Sinal de blanking (1 = desenhando, 0 = apagamento)

   // Gerador de sincronismo VGA de 640x480 @ 60Hz
   controlador_vga gerador_sincronismo (
      .vga_clk   (clock_vga),
      .vga_rst_n (reset_vga_n),
      .o_hsync   (vga_hs),
      .o_vsync   (vga_vs),
      .o_blank_n (area_visivel),
      .o_x       (coord_x_vga),
      .o_y       (coord_y_vga)
   );
    
   assign vga_blank_n = area_visivel;
   assign vga_sync_n   = 1'b1; // Inativo para monitores comuns

   // Resolucao logica: conversao de 640x480 para 320x240
   // O pixel logico e ampliado por um fator 2x2. Uma divisao por 2 equivale a deslocar 1 bit.
   wire [8:0] coord_logica_x = coord_x_vga[9:1]; // Posicao logica horizontal (0-319)
   wire [7:0] coord_logica_y = coord_y_vga[9:1]; // Posicao logica vertical (0-239)

   // Unidade de Controle e FSM
   wire [1:0] modo_selecionado = sw[9:8]; // Definido pelas chaves SW9 e SW8
   wire [1:0] estado_atual_fsm;           // Estado de operacao consolidado

   // Barramentos de pinagem de controle direcionados gerados pela FSM
   wire [3:0] sw_background_control;
   wire [2:0] key_sprites_control;
   wire [7:0] sw_sprites_control;
   wire [7:0] sw_poligonos_control;
   wire       key_poligonos_control;

   // FSM que ativa ou gerencia os modos de desenho baseado nas chaves
   fsm_controle controle_sistema (
      .clk             (clock_vga),
      .reset_n         (reset_vga_n),
      .seletor         (modo_selecionado),
      .botoes_raw      (key_n),
      .chaves_raw      (sw),
      .sw_background   (sw_background_control),
      .key_sprites     (key_sprites_control),
      .sw_sprites      (sw_sprites_control),
      .sw_poligonos    (sw_poligonos_control),
      .key_poligonos   (key_poligonos_control),
      .estado          (estado_atual_fsm)
   );

   // Interface de comandos graficos de 32 bits
   wire [31:0] comando_grafico;
   wire        comando_valido;

   // Barramentos de cor de 8 bits gerados por cada motor grafico
   wire [7:0] cor_fundo;
   wire [7:0] cor_sprite;
   wire [7:0] cor_poligono;

   // Motor de plano de fundo (background): recebe barramento de chaves isolado pela FSM
   motor_background motor_background (
      .clk       (clock_vga),
      .reset_n   (reset_vga_n),
      .x_logico  (coord_logica_x),
      .y_logico  (coord_logica_y),
      .background_sentido      (fio_sentido),
	  .background_deslocamento (fio_deslocamento),
	  .background_atualizar    (fio_atualizar_background),
      .indice_cor(cor_fundo)
   );

   // Motor de Sprites: recebe botoes de movimentacao e chaves de selecao filtrados pela FSM
   wire [8:0] sprite_x_debug;
   wire [7:0] sprite_y_debug;
   wire [4:0] sprite_id_debug;
   wire       sprite_direcao_debug;

   motor_sprites motor_sprites (
      .clk       (clock_vga),
      .reset_n   (reset_vga_n),
      .x_logico  (coord_logica_x),
      .y_logico  (coord_logica_y),
      .botoes    (key_sprites_control),
      .controle_sw(sw_sprites_control),
      .indice_cor(cor_sprite),
      .sprite_x_debug(sprite_x_debug),
      .sprite_y_debug(sprite_y_debug),
      .sprite_id_debug(sprite_id_debug),
      .direcao_debug(sprite_direcao_debug)
   );

   wire [8:0] cursor_x_debug;
   wire [7:0] cursor_y_debug;
   wire [1:0] captura_poligono_debug;

   // Rasterizador: SW3=esq, SW2=baixo, SW1=cima, SW0=dir; KEY3 marca.
   rasterizador_poligonos rasterizador_poligonos (
      .clk       (clock_vga),
      .reset_n   (reset_vga_n),
      .x_logico  (coord_logica_x),
      .y_logico  (coord_logica_y),
      .sw        (sw_poligonos_control),
      .botao_marcar(key_poligonos_control),
      .indice_cor(cor_poligono),
      .cursor_x_debug(cursor_x_debug),
      .cursor_y_debug(cursor_y_debug),
      .estado_debug(captura_poligono_debug)
    );

   // Compositor de Video: define a prioridade de sobreposicao de cada plano
   wire [7:0] cor_pixel_final;

   compositor compositor_de_video (
      .cor_bg    (cor_fundo),
      .cor_spr   (cor_sprite),
      .cor_poly  (cor_poligono),
      .cor_final (cor_pixel_final)
   );

   // Paleta de Cores: converte indice de 8 bits para RGB de 24 bits
   wire [23:0] rgb_final;

   ram_paleta memoria_paleta (
      .clock     (clock_vga),
      .address   (cor_pixel_final),
      .q         (rgb_final)
   );

   // Envio dos sinais de cores filtrados pela visibilidade da tela
   assign vga_r = (area_visivel) ? rgb_final[23:16] : 8'd0;
   assign vga_g = (area_visivel) ? rgb_final[15:8]  : 8'd0;
   assign vga_b = (area_visivel) ? rgb_final[7:0]   : 8'd0;

   // LEDs vermelhos mostram o modo atual da FSM e estado das chaves
   assign ledr[9:8] = modo_selecionado;
   assign ledr[7:0] = sw[7:0];

   // Displays estaveis de depuracao.
   // HEX2 HEX1 HEX0 = X em hexadecimal; HEX4 HEX3 = Y; HEX5 = modo.
   reg [8:0] display_x;
   reg [7:0] display_y;

   always @(*) begin
      case (estado_atual_fsm)
         2'b01: begin
            display_x = sprite_x_debug;
            display_y = sprite_y_debug;
         end
         2'b11: begin
            display_x = cursor_x_debug;
            display_y = cursor_y_debug;
         end
         default: begin
            display_x = {5'd0, sw_background_control};
            display_y = 8'd0;
         end
      endcase
   end

   decodificador_hex decodificador_hex0 (
      .dado_entrada(display_x[3:0]),
      .saida_hex   (hex0)
   );
	
   decodificador_hex decodificador_hex1 (
      .dado_entrada(display_x[7:4]),
      .saida_hex   (hex1)
   );
	
   decodificador_hex decodificador_hex2 (
      .dado_entrada({3'd0, display_x[8]}),
      .saida_hex   (hex2)
   );
	
   decodificador_hex decodificador_hex3 (
      .dado_entrada(display_y[3:0]),
      .saida_hex   (hex3)
   );
	
   decodificador_hex decodificador_hex4 (
      .dado_entrada(display_y[7:4]),
      .saida_hex   (hex4)
   );
	 
   decodificador_hex decodificador_hex5 (
      .dado_entrada({2'b0, estado_atual_fsm}),
      .saida_hex   (hex5)
   );

endmodule
