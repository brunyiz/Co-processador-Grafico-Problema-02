// decodificador_hex.v
// Conversor síncrono/combinacional para displays de 7 segmentos (catodo comum/anodo comum).
// Converte um valor hexadecimal de 4 bits para os segmentos físicos ativos em nível baixo (0 acende, 1 apaga).

module decodificador_hex (
   input  wire [3:0] dado_entrada, // Valor de 4 bits a ser exibido (0 a F)
   output reg  [6:0] saida_hex     // Sinais para os segmentos do display [g f e d c b a]
);

   // Mapeamento lógico de segmentos para display de 7 segmentos da placa DE1-SoC
   // Segmentos: saida_hex[0] = a, [1] = b, [2] = c, [3] = d, [4] = e, [5] = f, [6] = g
   always @(*) begin
      case (dado_entrada)
         4'h0:    saida_hex = 7'b100_0000; // Exibe '0'
         4'h1:    saida_hex = 7'b111_1001; // Exibe '1'
         4'h2:    saida_hex = 7'b010_0100; // Exibe '2'
         4'h3:    saida_hex = 7'b011_0000; // Exibe '3'
         4'h4:    saida_hex = 7'b001_1001; // Exibe '4'
         4'h5:    saida_hex = 7'b001_0010; // Exibe '5'
         4'h6:    saida_hex = 7'b000_0010; // Exibe '6'
         4'h7:    saida_hex = 7'b111_1000; // Exibe '7'
         4'h8:    saida_hex = 7'b000_0000; // Exibe '8'
         4'h9:    saida_hex = 7'b001_0000; // Exibe '9'
         4'hA:    saida_hex = 7'b000_1000; // Exibe 'A'
         4'hb:    saida_hex = 7'b000_0011; // Exibe 'b'
         4'hC:    saida_hex = 7'b100_0110; // Exibe 'C'
         4'hd:    saida_hex = 7'b010_0001; // Exibe 'd'
         4'he:    saida_hex = 7'b000_0110; // Exibe 'E'
         4'hf:    saida_hex = 7'b000_1110; // Exibe 'F'
         default: saida_hex = 7'b111_1111; // Todos apagam
      endcase
   end

endmodule