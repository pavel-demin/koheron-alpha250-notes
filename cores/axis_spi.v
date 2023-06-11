
`timescale 1 ns / 1 ps

module axis_spi #
(
  parameter integer SPI_DATA_WIDTH = 16
)
(
  // System signals
  input  wire        aclk,
  input  wire        aresetn,

  output wire [3:0]  spi_data,

  // Slave side
  output wire        s_axis_tready,
  input  wire [31:0] s_axis_tdata,
  input  wire        s_axis_tvalid
);

  reg [SPI_DATA_WIDTH-1:0] int_data_reg, int_data_next;
  reg [9:0] int_cntr_reg, int_cntr_next;
  reg int_enbl_reg, int_enbl_next;
  reg int_ssel_reg, int_ssel_next;
  reg int_tready_reg, int_tready_next;

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_data_reg <= {(SPI_DATA_WIDTH){1'b0}};
      int_cntr_reg <= 10'd0;
      int_enbl_reg <= 1'b0;
      int_ssel_reg <= 1'b1;
      int_tready_reg <= 1'b0;
    end
    else
    begin
      int_data_reg <= int_data_next;
      int_cntr_reg <= int_cntr_next;
      int_enbl_reg <= int_enbl_next;
      int_ssel_reg <= int_ssel_next;
      int_tready_reg <= int_tready_next;
    end
  end

  always @*
  begin
    int_data_next = int_data_reg;
    int_cntr_next = int_cntr_reg;
    int_enbl_next = int_enbl_reg;
    int_ssel_next = int_ssel_reg;
    int_tready_next = int_tready_reg;

    if(s_axis_tvalid & ~int_enbl_reg)
    begin
      int_data_next = s_axis_tdata[SPI_DATA_WIDTH-1:0];
      int_enbl_next = 1'b1;
      int_tready_next = 1'b1;
    end

    if(int_tready_reg)
    begin
      int_tready_next = 1'b0;
    end

    if(int_enbl_reg)
    begin
      int_cntr_next = int_cntr_reg + 1'b1;
    end

    if(int_cntr_reg[3:0] == 4'd3)
    begin
      if(~|int_cntr_reg[9:4])
      begin
        int_ssel_next = 1'b0;
      end
      else
      begin
        int_data_next = {int_data_reg[SPI_DATA_WIDTH-2:0], 1'b0};
      end
      if(int_cntr_reg[9:4] == SPI_DATA_WIDTH)
      begin
        int_ssel_next = 1'b1;
      end
    end

    if(int_cntr_reg == {SPI_DATA_WIDTH[5:0], 4'd15})
    begin
      int_cntr_next = 10'd0;
      int_enbl_next = 1'b0;
    end

  end

  assign s_axis_tready = int_tready_reg;

  assign spi_data[0] = int_cntr_reg[3];
  assign spi_data[1] = int_data_reg[SPI_DATA_WIDTH-1];
  assign spi_data[2] = int_ssel_reg;
  assign spi_data[3] = 1'b1;

endmodule
