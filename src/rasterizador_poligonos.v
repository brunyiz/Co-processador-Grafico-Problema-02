// rasterizador_poligonos.v
// Rasterizador de triangulos e retangulos preenchidos.
// Cursor independente dos vertices: SW3=esquerda, SW2=baixo, SW1=cima, SW0=direita.
// KEY3 marca os vertices. SW7 escolhe o tipo: 0=triangulo, 1=retangulo.

module rasterizador_poligonos (
	input  wire        clk,
	input  wire        reset_n,
	input  wire [8:0]  x_logico,
	input  wire [7:0]  y_logico,
	input  wire [7:0]  sw,
	input  wire        botao_marcar, // KEY3, ativo em 0
	output reg  [7:0]  indice_cor,
	output wire [8:0]  cursor_x_debug,
	output wire [7:0]  cursor_y_debug,
	output wire [1:0]  estado_debug
);

	// Cursor
	reg [8:0] cursor_x;
	reg [7:0] cursor_y;
	reg [18:0] contador_movimento;

	// 25 MHz / 250000 = 100 atualizacoes/s; 1 pixel logico por atualizacao.
	wire pulso_movimento = (contador_movimento == 19'd249999);

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n)
         contador_movimento <= 19'd0;
      else if (pulso_movimento)
         contador_movimento <= 19'd0;
      else
         contador_movimento <= contador_movimento + 19'd1;
   end

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         cursor_x <= 9'd160;
         cursor_y <= 8'd120;
      end else if (pulso_movimento) begin
         // Permite diagonal se duas chaves forem ligadas.
         if (sw[3] && !sw[0] && cursor_x > 9'd0)
            cursor_x <= cursor_x - 9'd1;          // SW3 = esquerda
         else if (sw[0] && !sw[3] && cursor_x < 9'd319)
            cursor_x <= cursor_x + 9'd1;          // SW0 = direita

         if (sw[1] && !sw[2] && cursor_y > 8'd0)
            cursor_y <= cursor_y - 8'd1;          // SW1 = cima
         else if (sw[2] && !sw[1] && cursor_y < 8'd239)
            cursor_y <= cursor_y + 8'd1;          // SW2 = baixo
      end
   end

   assign cursor_x_debug = cursor_x;
   assign cursor_y_debug = cursor_y;

   // KEY3: sincronizacao, borda e pequeno bloqueio contra bouncing
   reg marcar_sync0, marcar_sync1, marcar_anterior;
   reg [18:0] debounce_marcar;
   wire marcar_press = marcar_anterior && !marcar_sync1 && (debounce_marcar == 19'd0);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            marcar_sync0    <= 1'b1;
            marcar_sync1    <= 1'b1;
            marcar_anterior <= 1'b1;
            debounce_marcar <= 19'd0;
        end else begin
            marcar_sync0    <= botao_marcar;
            marcar_sync1    <= marcar_sync0;
            marcar_anterior <= marcar_sync1;

            if (marcar_press)
               debounce_marcar <= 19'd250000; // ~10 ms a 25 MHz
            else if (debounce_marcar != 19'd0)
               debounce_marcar <= debounce_marcar - 19'd1;
        end
    end

   // Captura dos vertices
   reg [8:0] X1, X2, X3;
   reg [7:0] Y1, Y2, Y3;
   reg [1:0] estado_captura;       // 0=P1, 1=P2, 2=P3
   reg       tipo_latched;         // 0=triangulo, 1=retangulo
   reg       poligono_valido;

   assign estado_debug = estado_captura;

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         X1 <= 9'd0; Y1 <= 8'd0;
         X2 <= 9'd0; Y2 <= 8'd0;
         X3 <= 9'd0; Y3 <= 8'd0;
         estado_captura <= 2'd0;
         tipo_latched   <= 1'b0;
         poligono_valido <= 1'b0;
      end else if (marcar_press) begin
         case (estado_captura)
            2'd0: begin
               // Comecar outro poligono invalida o anterior durante a captura.
               X1 <= cursor_x;
               Y1 <= cursor_y;
               tipo_latched <= sw[7];
               poligono_valido <= 1'b0;
               estado_captura <= 2'd1;
            end

            2'd1: begin
               X2 <= cursor_x;
               Y2 <= cursor_y;
               if (tipo_latched) begin
                  // Retangulo termina com dois pontos.
                  poligono_valido <= 1'b1;
                  estado_captura <= 2'd0;
               end else begin
                  estado_captura <= 2'd2;
               end
            end

            2'd2: begin
               X3 <= cursor_x;
               Y3 <= cursor_y;
               poligono_valido <= 1'b1;
               estado_captura <= 2'd0;
            end

            default: begin
               estado_captura <= 2'd0;
               poligono_valido <= 1'b0;
            end
         endcase
      end
   end

   // Retangulo preenchido
   wire [8:0] min_x = (X1 < X2) ? X1 : X2;
   wire [8:0] max_x = (X1 > X2) ? X1 : X2;
   wire [7:0] min_y = (Y1 < Y2) ? Y1 : Y2;
   wire [7:0] max_y = (Y1 > Y2) ? Y1 : Y2;

   wire pixel_no_retangulo =
      (x_logico >= min_x) && (x_logico <= max_x) &&
      (y_logico >= min_y) && (y_logico <= max_y);

	// Triangulo preenchido - funcoes de borda com aritmetica signed correta
	// E(A,B,P) = (Px-Ax)*(By-Ay) - (Py-Ay)*(Bx-Ax)
	wire signed [10:0] px_x1 = $signed({1'b0,x_logico}) - $signed({1'b0,X1});
	wire signed [10:0] px_x2 = $signed({1'b0,x_logico}) - $signed({1'b0,X2});
	wire signed [10:0] px_x3 = $signed({1'b0,x_logico}) - $signed({1'b0,X3});

	wire signed [9:0] py_y1 = $signed({1'b0,y_logico}) - $signed({1'b0,Y1});
	wire signed [9:0] py_y2 = $signed({1'b0,y_logico}) - $signed({1'b0,Y2});
	wire signed [9:0] py_y3 = $signed({1'b0,y_logico}) - $signed({1'b0,Y3});

	wire signed [9:0] dy12 = $signed({1'b0,Y2}) - $signed({1'b0,Y1});
	wire signed [9:0] dy23 = $signed({1'b0,Y3}) - $signed({1'b0,Y2});
	wire signed [9:0] dy31 = $signed({1'b0,Y1}) - $signed({1'b0,Y3});

	wire signed [10:0] dx12 = $signed({1'b0,X2}) - $signed({1'b0,X1});
	wire signed [10:0] dx23 = $signed({1'b0,X3}) - $signed({1'b0,X2});
	wire signed [10:0] dx31 = $signed({1'b0,X1}) - $signed({1'b0,X3});

	wire signed [21:0] e12 = px_x1 * dy12 - py_y1 * dx12;
	wire signed [21:0] e23 = px_x2 * dy23 - py_y2 * dx23;
	wire signed [21:0] e31 = px_x3 * dy31 - py_y3 * dx31;

	wire todos_positivos = (e12 >= 0) && (e23 >= 0) && (e31 >= 0);
	wire todos_negativos = (e12 <= 0) && (e23 <= 0) && (e31 <= 0);
	wire pixel_no_triangulo = todos_positivos || todos_negativos;

	// Cursor = exatamente um pixel logico branco (2x2 na VGA fisica).
	wire pixel_no_cursor = (x_logico == cursor_x) && (y_logico == cursor_y);

   // Saida combinacional evita um atraso extra entre coordenada e camada.
   always @(*) begin
      if (pixel_no_cursor) begin
         indice_cor = 8'd255;
      end else if (!poligono_valido) begin
         indice_cor = 8'd0;
      end else if (tipo_latched) begin
         indice_cor = pixel_no_retangulo ? 8'd100 : 8'd0;
      end else begin
         indice_cor = pixel_no_triangulo ? 8'd224 : 8'd0;
      end
   end

endmodule
