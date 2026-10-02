// motor_background.v
// Plano de fundo baseado em tilemap 40 x 30 (tiles de 8 x 8 pixels).
//
// Usa apenas a mapa_rom (1200 x 8, init = background_map.mif).
// Cada palavra da ROM ja e o indice de cor (RGB332) do tile naquela posicao,
// portanto o dado lido da ROM vai direto para a saida indice_cor.
//
// Scroll (controle_sw, vindo da fsm_controle):
//   SW3 = esquerda | SW2 = baixo | SW1 = cima | SW0 = direita
// O deslocamento e feito SEMPRE em passos de 1 tile (8 pixels), com
// repeticao automatica enquanto a chave estiver ligada, e com wrap
// (a cena e repetida: 40 tiles na horizontal, 30 na vertical).
//
// Fluxo:
//   x/y logico -> tile da tela (x>>3, y>>3) + scroll_tile (mod 40 / mod 30)
//              -> endereco = tile_y*40 + tile_x -> mapa_rom -> indice_cor
//
// Latencia: a mapa_rom (M10K) tem endereco registrado => 1 ciclo de clk.

module motor_background (
    input  wire        clk,
    input  wire        reset_n,
    input  wire [8:0]  x_logico,        // 0..319
    input  wire [7:0]  y_logico,        // 0..239
    input  wire [3:0]  controle_sw,     // SW3=esq, SW2=baixo, SW1=cima, SW0=dir
    output wire [7:0]  indice_cor
);

    // ============================================================
    // PARAMETROS
    // ============================================================
    // Ciclos de clk (25 MHz) entre dois passos de scroll.
    // 3_000_000 / 25 MHz = 120 ms por tile (~8 tiles/s).
    parameter PASSO_CICLOS = 22'd3_000_000;

    localparam TILES_X = 6'd40;
    localparam TILES_Y = 5'd30;

    // ============================================================
    // SCROLL EM TILES
    // ============================================================
    reg [5:0] scroll_tile_x;   // 0..39
    reg [4:0] scroll_tile_y;   // 0..29

    reg [21:0] contador_passo;
    wire       pulso_passo = (contador_passo == PASSO_CICLOS - 22'd1);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            contador_passo <= 22'd0;
        else if (pulso_passo)
            contador_passo <= 22'd0;
        else
            contador_passo <= contador_passo + 22'd1;
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scroll_tile_x <= 6'd0;
            scroll_tile_y <= 5'd0;
        end
        else if (pulso_passo) begin
            // Horizontal (esquerda tem prioridade sobre direita)
            if (controle_sw[3]) begin
                if (scroll_tile_x == 6'd0)
                    scroll_tile_x <= TILES_X - 6'd1;
                else
                    scroll_tile_x <= scroll_tile_x - 6'd1;
            end
            else if (controle_sw[0]) begin
                if (scroll_tile_x == TILES_X - 6'd1)
                    scroll_tile_x <= 6'd0;
                else
                    scroll_tile_x <= scroll_tile_x + 6'd1;
            end

            // Vertical (cima tem prioridade sobre baixo)
            if (controle_sw[1]) begin
                if (scroll_tile_y == 5'd0)
                    scroll_tile_y <= TILES_Y - 5'd1;
                else
                    scroll_tile_y <= scroll_tile_y - 5'd1;
            end
            else if (controle_sw[2]) begin
                if (scroll_tile_y == TILES_Y - 5'd1)
                    scroll_tile_y <= 5'd0;
                else
                    scroll_tile_y <= scroll_tile_y + 5'd1;
            end
        end
    end

    // ============================================================
    // TILE DA TELA + SCROLL (COM WRAP)
    // ============================================================
    // Como o scroll e em tiles inteiros, nao ha soma em pixels:
    // basta somar o scroll ao indice do tile da tela.
    wire [5:0] tela_tile_x = x_logico[8:3];   // 0..39
    wire [4:0] tela_tile_y = y_logico[7:3];   // 0..29

    wire [6:0] soma_x = {1'b0, tela_tile_x} + {1'b0, scroll_tile_x};  // 0..78
    wire [5:0] soma_y = {1'b0, tela_tile_y} + {1'b0, scroll_tile_y};  // 0..58

    wire [5:0] tile_x = (soma_x >= {1'b0, TILES_X}) ? (soma_x - {1'b0, TILES_X}) : soma_x[5:0];
    wire [4:0] tile_y = (soma_y >= {1'b0, TILES_Y}) ? (soma_y - {1'b0, TILES_Y}) : soma_y[4:0];

    // endereco = tile_y * 40 + tile_x   (40 = 32 + 8)
    wire [10:0] linha_x40     = ({6'd0, tile_y} << 5) + ({6'd0, tile_y} << 3);
    wire [10:0] endereco_mapa = linha_x40 + {5'd0, tile_x};

    // ============================================================
    // MAPA_ROM (1200 x 8): a palavra lida ja e o indice de cor
    // ============================================================
    mapa_rom ROM_MAPA (
        .address (endereco_mapa),
        .clock   (clk),
        .rden    (1'b1),
        .q       (indice_cor)
    );

endmodule
