// fsm_controle.v
// Seleciona o modo de demonstracao e isola os controles fisicos entre os motores.

module fsm_controle (
   input  wire        clk,
   input  wire        reset_n,
   input  wire [1:0]  seletor,
   input  wire [3:0]  botoes_raw,
   input  wire [9:0]  chaves_raw,

   output reg  [3:0]  sw_background,
   output reg  [2:0]  key_sprites,
   output reg  [7:0]  sw_sprites,
   output reg  [7:0]  sw_poligonos,
   output reg         key_poligonos,
   output reg  [1:0]  estado
);

   parameter ESTADO_BACKGROUND = 2'b00;
   parameter ESTADO_SPRITES    = 2'b01;
   parameter ESTADO_POLIGONOS  = 2'b11;

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n)
         estado <= ESTADO_BACKGROUND;
      else begin
         case (seletor)
            2'b00: estado <= ESTADO_BACKGROUND;
            2'b01: estado <= ESTADO_SPRITES;
            2'b11: estado <= ESTADO_POLIGONOS;
            default: estado <= ESTADO_BACKGROUND;
         endcase
      end
   end

   always @(*) begin
      sw_background = 4'b0000;
      key_sprites    = 3'b111;
      sw_sprites     = 8'b00000000;
      sw_poligonos   = 8'b00000000;
      key_poligonos  = 1'b1;

         case (estado)
            ESTADO_BACKGROUND: begin
               sw_background = chaves_raw[3:0];
            end

            ESTADO_SPRITES: begin
               key_sprites = botoes_raw[3:1];
               // SW7=transparencia, SW6=flip H, SW5=flip V, SW4:0=endereco.
               sw_sprites = chaves_raw[7:0];
            end

            ESTADO_POLIGONOS: begin
               key_poligonos = botoes_raw[3];
               // SW7=tipo; SW3..SW0 controlam o cursor.
               sw_poligonos = chaves_raw[7:0];
            end

            default: ;
         endcase
	end

endmodule
