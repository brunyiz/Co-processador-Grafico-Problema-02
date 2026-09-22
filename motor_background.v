// motor_background.v
module motor_background (
    input  wire        clk,
    input  wire        reset_n,
    input  wire [8:0]  x_logico,        // 0..319 (VGA pede pixel)
    input  wire [7:0]  y_logico,        // 0..239 (VGA pede pixel)
    input  wire [1:0]  background_sentido,
    input  wire [9:0]  background_deslocamento,
    input  wire        background_atualizar,
    output wire [7:0]  indice_cor       // Cor sai direto do mapa
);

    // ============================================================
    // SCROLL
    // ============================================================
    reg [5:0] scroll_tile_x;
    reg [4:0] scroll_tile_y;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scroll_tile_x <= 6'd0;
            scroll_tile_y <= 5'd0;
        end
        else if (background_atualizar) begin
            case (background_sentido)
                2'b10: begin // Esquerda
                    if (scroll_tile_x >= background_deslocamento)
                        scroll_tile_x <= scroll_tile_x - background_deslocamento[5:0];
                    else
                        scroll_tile_x <= (6'd40 + scroll_tile_x) - background_deslocamento[5:0];
                end
                    
                2'b11: begin // Direita
                    if ((scroll_tile_x + background_deslocamento[5:0]) >= 6'd40)
                        scroll_tile_x <= (scroll_tile_x + background_deslocamento[5:0]) - 6'd40;
                    else
                        scroll_tile_x <= scroll_tile_x + background_deslocamento[5:0];
                end

                2'b00: begin // Cima
                    if (scroll_tile_y >= background_deslocamento)
                        scroll_tile_y <= scroll_tile_y - background_deslocamento[4:0];
                    else
                        scroll_tile_y <= (5'd30 + scroll_tile_y) - background_deslocamento[4:0];
                end
                    
                2'b01: begin // Baixo
                    if ((scroll_tile_y + background_deslocamento[4:0]) >= 5'd30)
                        scroll_tile_y <= (scroll_tile_y + background_deslocamento[4:0]) - 5'd30;
                    else
                        scroll_tile_y <= scroll_tile_y + background_deslocamento[4:0];
                end
            endcase
        end
    end

    // ============================================================
    // COORDENADA DA CENA COM WRAP
    // ============================================================

    // Multiplica o tile por 8 para transformar o scroll em pixel e alinhar com o VGA
    wire [9:0] pixel_scroll_x = {4'b0, scroll_tile_x} << 3;
    wire [8:0] pixel_scroll_y = {4'b0, scroll_tile_y} << 3;

    // Soma o scroll em pixel com a coordenada do VGA
    wire [9:0] soma_x = {1'b0, x_logico} + pixel_scroll_x;
    wire [8:0] soma_y = {1'b0, y_logico} + pixel_scroll_y;

    wire [8:0] abs_x = (soma_x >= 10'd320) ? (soma_x - 10'd320) : soma_x[8:0];
    wire [7:0] abs_y = (soma_y >= 9'd240) ?  (soma_y - 9'd240)  : soma_y[7:0];

    // ============================================================
    // DESCARTA O DETALHE DO PIXEL E LÊ O MAPA
    // ============================================================

    // Pegamos apenas os bits altos [8:3]. Isso significa que os pixels de 0 a 7
    // caem no tile 0. Os pixels de 8 a 15 caem no tile 1, e assim por diante.
    wire [5:0] tile_x = abs_x[8:3]; // 0..39
    wire [4:0] tile_y = abs_y[7:3]; // 0..29

    wire [10:0] linha_x40 = ({6'd0, tile_y} << 5) + ({6'd0, tile_y} << 3);
    wire [10:0] endereco_mapa = linha_x40 + {5'd0, tile_x};

    // A ROM do Mapa liga direto na saída indice_cor
    mapa_rom ROM_MAPA (
        .address (endereco_mapa),
        .clock   (clk),
        .rden    (1'b1),
        .q       (indice_cor)
    );

endmodule