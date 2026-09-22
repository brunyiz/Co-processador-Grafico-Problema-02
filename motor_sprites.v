// motor_sprites.v
// Motor de 32 sprites 16x16.
// Controles no modo SPRITES:
//   KEY3 + KEY2: movem o sprite selecionado.
//   KEY1: alterna o par de direcoes.
//      modo 0 -> KEY3=esquerda, KEY2=baixo
//      modo 1 -> KEY3=direita,  KEY2=cima
//   SW7: transparencia (1 = cor 0 transparente; 0 = cor 0 opaca para demonstracao)
//   SW6: espelhamento horizontal
//   SW5: espelhamento vertical
//   SW4..SW0: endereco do sprite (0..31)

module motor_sprites (
   input  wire        clk,
   input  wire        reset_n,
   input  wire [8:0]  x_logico,
   input  wire [7:0]  y_logico,
   input  wire [2:0]  botoes,          // [2]=KEY3, [1]=KEY2, [0]=KEY1; ativos em 0
   input  wire [7:0]  controle_sw,
   output reg  [7:0]  indice_cor,
   output wire [8:0]  sprite_x_debug,
   output wire [7:0]  sprite_y_debug,
   output wire [4:0]  sprite_id_debug,
   output wire        direcao_debug
);

   wire [4:0] selecao_sprite = controle_sw[4:0];
   wire sw_transparencia = controle_sw[7];
   wire sw_mirror_h      = controle_sw[6];
   wire sw_mirror_v      = controle_sw[5];

   reg [8:0] sprite_x [0:31];
   reg [7:0] sprite_y [0:31];
   reg [4:0] sprite_pat [0:31];      // 0..31: indice do padrao real na sprite_rom
   reg       sprite_en [0:31];
   reg       sprite_mirror_h [0:31];
   reg       sprite_mirror_v [0:31];
   reg       sprite_transp [0:31];

   // ------------------------------------------------------------------
   // Movimento suave ~70 Hz
   // ------------------------------------------------------------------
   reg [18:0] contador_velocidade;
   wire pulso_movimento = (contador_velocidade == 19'd349999);

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n)
         contador_velocidade <= 19'd0;
      else if (pulso_movimento)
         contador_velocidade <= 19'd0;
      else
         contador_velocidade <= contador_velocidade + 19'd1;
   end

   // KEY1 alterna o sentido dos dois botoes de movimento.
   // Sincronizacao + borda + bloqueio de ~10 ms para evitar bounce.
   reg key1_sync0, key1_sync1, key1_anterior;
   reg [18:0] debounce_key1;
   reg modo_direcao;
   wire key1_press = key1_anterior && !key1_sync1 && (debounce_key1 == 19'd0);

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         key1_sync0 <= 1'b1;
         key1_sync1 <= 1'b1;
         key1_anterior <= 1'b1;
         debounce_key1 <= 19'd0;
         modo_direcao <= 1'b0;
      end else begin
         key1_sync0 <= botoes[0];
         key1_sync1 <= key1_sync0;
         key1_anterior <= key1_sync1;

         if (key1_press) begin
            modo_direcao <= ~modo_direcao;
            debounce_key1 <= 19'd250000;
         end else if (debounce_key1 != 19'd0) begin
            debounce_key1 <= debounce_key1 - 19'd1;
         end
      end
   end

   wire key3_ativo = !botoes[2];
   wire key2_ativo = !botoes[1];

   // Atributos + movimento
   integer k;
   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         for (k = 0; k < 32; k = k + 1) begin
            // Grade segura dentro de 320x240.
            sprite_x[k] <= 9'd16 + ((k % 8) * 9'd36);
            sprite_y[k] <= 8'd16 + ((k / 8) * 8'd52);
            sprite_pat[k] <= k[4:0];
            sprite_en[k] <= 1'b1;
            sprite_mirror_h[k] <= 1'b0;
            sprite_mirror_v[k] <= 1'b0;
            sprite_transp[k] <= 1'b1;
         end
      end else begin
         // As chaves editam os atributos do registro atualmente enderecado.
         sprite_transp[selecao_sprite]  <= sw_transparencia;
         sprite_mirror_h[selecao_sprite] <= sw_mirror_h;
         sprite_mirror_v[selecao_sprite] <= sw_mirror_v;

         if (pulso_movimento) begin
            if (!modo_direcao) begin
               // Estado inicial pedido: KEY3 esquerda, KEY2 baixo.
               if (key3_ativo && sprite_x[selecao_sprite] > 9'd0)
                  sprite_x[selecao_sprite] <= sprite_x[selecao_sprite] - 9'd1;
               if (key2_ativo && sprite_y[selecao_sprite] < 8'd224)
                  sprite_y[selecao_sprite] <= sprite_y[selecao_sprite] + 8'd1;
            end else begin
               // Depois de KEY1: KEY3 direita, KEY2 cima.
               if (key3_ativo && sprite_x[selecao_sprite] < 9'd304)
                  sprite_x[selecao_sprite] <= sprite_x[selecao_sprite] + 9'd1;
               if (key2_ativo && sprite_y[selecao_sprite] > 8'd0)
                  sprite_y[selecao_sprite] <= sprite_y[selecao_sprite] - 8'd1;
            end
         end
      end
   end

   assign sprite_x_debug  = sprite_x[selecao_sprite];
   assign sprite_y_debug  = sprite_y[selecao_sprite];
   assign sprite_id_debug = selecao_sprite;
   assign direcao_debug   = modo_direcao;

   // Busca do sprite que cobre o pixel.
   // Indice 0 = maior prioridade (fica por cima).
   // O loop varre de 0 a 31; o primeiro encontrado trava a selecao.
   // ------------------------------------------------------------------
   reg       pixel_encontrado;
   reg [3:0] px_local;
   reg [3:0] py_local;
   reg [4:0] pat_local;
   reg       transp_local;
   integer idx;
   reg [8:0] dx_local;
   reg [7:0] dy_local;

   always @(*) begin
      pixel_encontrado = 1'b0;
      px_local = 4'd0;
      py_local = 4'd0;
      pat_local = 5'd0;
      transp_local = 1'b1;
      dx_local = 9'd0;
      dy_local = 8'd0;

      // Varredura de 0 até 31 garante prioridade absoluta para o Sprite 00
      for (idx = 0; idx <= 31; idx = idx + 1) begin
         if (!pixel_encontrado && sprite_en[idx] &&
            x_logico >= sprite_x[idx] && x_logico < sprite_x[idx] + 9'd16 &&
            y_logico >= sprite_y[idx] && y_logico < sprite_y[idx] + 8'd16) begin

            pixel_encontrado = 1'b1;
            dx_local = x_logico - sprite_x[idx];
            dy_local = y_logico - sprite_y[idx];
            px_local = sprite_mirror_h[idx] ? (4'd15 - dx_local[3:0]) : dx_local[3:0];
            py_local = sprite_mirror_v[idx] ? (4'd15 - dy_local[3:0]) : dy_local[3:0];
            pat_local = sprite_pat[idx];
            transp_local = sprite_transp[idx];
         end
      end
   end

   // Padroes de sprite armazenados em ROM dedicada (sprite_rom.v + sprite_patterns.mif)
   wire [7:0] cor_rom;
   sprite_rom rom_sprites (
       .address ({pat_local, py_local, px_local}),
       .clock   (clk),
       .rden    (1'b1),
       .q       (cor_rom)
   );

   // Com transparencia ligada, indice 0 deixa a camada de baixo aparecer.
   // Com transparencia desligada, o zero vira branco para deixar o teste evidente.
   always @(*) begin
		if (!pixel_encontrado || transp_local || (cor_rom == 8'd0))
			indice_cor = 8'd0;
		else
			indice_cor = cor_rom;
		end

endmodule