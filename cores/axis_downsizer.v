
`timescale 1 ns / 1 ps

module axis_downsizer #
(
  parameter integer S_AXIS_TDATA_WIDTH = 128,
  parameter integer M_AXIS_TDATA_WIDTH = 32
)
(
  // System signals
  input  wire                          aclk,
  input  wire                          aresetn,

  input  wire [15:0]                   cfg_data,

  // Slave side
  input  wire [S_AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input  wire                          s_axis_tvalid,
  output wire                          s_axis_tready,

  // Master side
  output wire [M_AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                          m_axis_tvalid,
  input  wire                          m_axis_tready
);

  localparam integer RATIO = S_AXIS_TDATA_WIDTH / M_AXIS_TDATA_WIDTH;
  localparam integer CNTR_WIDTH = RATIO > 1 ? $clog2(RATIO) : 1;

  reg [CNTR_WIDTH-1:0] int_cntr_reg;

  wire [M_AXIS_TDATA_WIDTH-1:0] int_data_mux [RATIO-1:0];
  wire int_last_wire, int_ready_wire;

  genvar j;

  assign int_last_wire = int_cntr_reg == cfg_data[CNTR_WIDTH-1:0];

  generate
    for(j = 0; j < RATIO; j = j + 1)
    begin : SLICES
      assign int_data_mux[j] = s_axis_tdata[j*M_AXIS_TDATA_WIDTH+:M_AXIS_TDATA_WIDTH];
    end
  endgenerate

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_cntr_reg <= {(CNTR_WIDTH){1'b0}};
    end
    else if(s_axis_tvalid & int_ready_wire)
    begin
      int_cntr_reg <= int_last_wire ? {(CNTR_WIDTH){1'b0}} : int_cntr_reg + 1'b1;
    end
  end

  inout_buffer #(
    .DATA_WIDTH(M_AXIS_TDATA_WIDTH)
  ) buf_0 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(int_data_mux[int_cntr_reg]), .in_valid(s_axis_tvalid), .in_ready(int_ready_wire),
    .out_data(m_axis_tdata), .out_valid(m_axis_tvalid), .out_ready(m_axis_tready)
  );

  assign s_axis_tready = int_last_wire & int_ready_wire;

endmodule
