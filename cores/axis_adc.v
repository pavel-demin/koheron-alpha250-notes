
`timescale 1 ns / 1 ps

module axis_adc #
(
  parameter integer ADC_DATA_WIDTH = 14,
  parameter integer AXIS_TDATA_WIDTH = 16
)
(
  // System signals
  input  wire                        aclk,

  // ADC signals
  input  wire [ADC_DATA_WIDTH/2-1:0] adc_n,
  input  wire [ADC_DATA_WIDTH/2-1:0] adc_p,

  // Master side
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid
);
  localparam PADDING_WIDTH = AXIS_TDATA_WIDTH - ADC_DATA_WIDTH;

  reg [ADC_DATA_WIDTH-1:0] int_data_reg;

  wire [ADC_DATA_WIDTH/2-1:0] int_adc_wire;
  wire [ADC_DATA_WIDTH-1:0] int_data_wire;

  genvar j;

  generate
    for(j = 0; j < ADC_DATA_WIDTH/2; j = j + 1)
    begin : ADC_DATA
      IBUFDS #(
        .DIFF_TERM("FALSE"),
        .IBUF_LOW_PWR("TRUE"),
        .IOSTANDARD("DEFAULT")
      ) IBUFDS_inst (
        .IB(adc_n[j]),
        .I(adc_p[j]),
        .O(int_adc_wire[j])
      );
      IDDR #(
        .DDR_CLK_EDGE("SAME_EDGE_PIPELINED")
      ) IDDR_inst (
        .Q1(int_data_wire[j*2+0]),
        .Q2(int_data_wire[j*2+1]),
        .D(int_adc_wire[j]),
        .C(aclk),
        .CE(1'b1),
        .R(1'b0),
        .S(1'b0)
      );
    end
  endgenerate

  always @(posedge aclk)
  begin
    int_data_reg <= int_data_wire;
  end

  assign m_axis_tdata = {{(PADDING_WIDTH+1){int_data_reg[ADC_DATA_WIDTH-1]}}, int_data_reg[ADC_DATA_WIDTH-2:0]};
  assign m_axis_tvalid = 1'b1;

endmodule
