// ram_paleta.v
// Memoria de paleta de cores modificada para realizar a decodificacao direta
// sincrona do indice logico de 8 bits (no padrao RGB332) para sinais de 24 bits RGB.
// Como as cores ja estao codificadas diretamente no proprio indice, o modulo
// extrai as fatias de bits de cada canal de cor (R, G, B) e realiza o fanning sincrono.

module ram_paleta (
   input  wire        clock,           // Clock sincrono de pixel de 25 MHz
   input  wire [7:0]  address,         // Indice de cor de 8 bits (padrao RGB332)
   output reg  [23:0] q                // Saida sincrona RGB de 24 bits (R=23:16, G=15:8, B=7:0)
);

   // Extracao direta de bits de cor (RGB332) e fanning sincrono para 8 bits por canal:
   // Red (3 bits: address[7:5]) -> expandido para 8 bits por replicacao de bits
   // Green (3 bits: address[4:2]) -> expandido para 8 bits por replicacao de bits
   // Blue (2 bits: address[1:0]) -> expandido para 8 bits por replicacao de bits
   always @(posedge clock) begin
      q[23:16] <= {address[7:5], address[7:5], address[7:6]};
      q[15:8]  <= {address[4:2], address[4:2], address[4:3]};
      q[7:0]   <= {address[1:0], address[1:0], address[1:0], address[1:0]};
   end

endmodule
