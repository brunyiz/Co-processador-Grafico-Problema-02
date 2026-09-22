// clock_reset.v
// Divide o clock de 50 MHz da placa por 2 para obter o clock de vídeo de 25 MHz da VGA,
// e sincroniza o sinal de reset físico (KEY[0]) para o domínio de 25 MHz.
module clock_reset (
   input  wire CLOCK_50,   // Clock de 50 MHz da placa DE1-SoC
   input  wire reset_n,    // Reset físico (geralmente KEY[0], ativo em baixo)
   output reg  vga_clk,    // Clock de 25 MHz para a VGA
   output reg  vga_rst_n   // Reset sincronizado no clock de 25 MHz
);

   // Divisor de clock por 2
   always @(posedge CLOCK_50 or negedge reset_n) begin
      if (!reset_n)
         vga_clk <= 1'b0;
      else
         vga_clk <= ~vga_clk;
   end

   // Sincronizador de reset (fila de dois flip-flops para evitar metaestabilidade)
   reg rst_sync1;
   always @(posedge vga_clk or negedge reset_n) begin
      if (!reset_n) begin
         rst_sync1 <= 1'b0;
         vga_rst_n <= 1'b0;
      end else begin
         rst_sync1 <= 1'b1;
         vga_rst_n <= rst_sync1;
      end
   end

endmodule
