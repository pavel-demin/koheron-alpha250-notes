
`timescale 1 ns / 1 ps

module axis_spi_e727
(
  // System signals
  input  wire        aclk,
  input  wire        aresetn,

  output wire        spi_sclk,
  output wire        spi_mosi,
  output wire        spi_ssel,
  output wire        spi_ldat,

  // Slave side
  output wire        s_axis_tready,
  input  wire [15:0] s_axis_tdata,
  input  wire        s_axis_tvalid
);

  reg [16:0] int_data_reg, int_data_next;
  reg [7:0] int_sclk_reg, int_sclk_next;
  reg [2:0] int_cntr_reg, int_cntr_next;
  reg int_enbl_reg, int_enbl_next;
  reg int_ssel_reg, int_ssel_next;
  reg int_ldat_reg, int_ldat_next;
  reg int_tready_reg, int_tready_next;

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_data_reg <= 17'd0;
      int_sclk_reg <= 8'd0;
      int_cntr_reg <= 3'd0;
      int_enbl_reg <= 1'b0;
      int_ssel_reg <= 1'b1;
      int_ldat_reg <= 1'b1;
      int_tready_reg <= 1'b0;
    end
    else
    begin
      int_data_reg <= int_data_next;
      int_sclk_reg <= int_sclk_next;
      int_cntr_reg <= int_cntr_next;
      int_enbl_reg <= int_enbl_next;
      int_ssel_reg <= int_ssel_next;
      int_ldat_reg <= int_ldat_next;
      int_tready_reg <= int_tready_next;
    end
  end

  always @*
  begin
    int_data_next = int_data_reg;
    int_sclk_next = int_sclk_reg;
    int_cntr_next = int_cntr_reg;
    int_enbl_next = int_enbl_reg;
    int_ssel_next = int_ssel_reg;
    int_ldat_next = int_ldat_reg;
    int_tready_next = int_tready_reg;

    if(s_axis_tvalid & ~int_enbl_reg)
    begin
      int_data_next = {1'b0, s_axis_tdata};
      int_sclk_next = 8'd0;
      int_enbl_next = 1'b1;
      int_ssel_next = 1'b0;
      if(~|int_cntr_reg) int_ldat_next = 1'b0;
      int_tready_next = 1'b1;
    end

    if(int_tready_reg)
    begin
      int_tready_next = 1'b0;
    end

    if(int_enbl_reg)
    begin
      int_sclk_next = int_sclk_reg + 1'b1;
    end

    if(int_sclk_reg[2:0] == 3'd3)
    begin
      int_data_next = {int_data_reg[15:0], 1'b0};

      if(int_sclk_reg[7:3] == 5'd16)
      begin
        int_cntr_next = int_cntr_reg + 1'b1;
        int_ssel_next = 1'b1;
        if(int_cntr_reg == 3'd6)
        begin
          int_cntr_next = 3'd0;
          int_ldat_next = 1'b1;
        end
      end

      if(int_sclk_reg[7:3] == 5'd17)
      begin
        int_enbl_next = 1'b0;
      end
    end
  end

  assign s_axis_tready = int_tready_reg;

  assign spi_sclk = (int_ssel_reg | int_ldat_reg) ? 1'b0 : int_sclk_reg[2];
  assign spi_mosi = int_data_reg[16];
  assign spi_ssel = int_ssel_reg | int_ldat_reg;
  assign spi_ldat = int_ldat_reg;

endmodule
