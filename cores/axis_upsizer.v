
`timescale 1 ns / 1 ps

module axis_upsizer #
(
  parameter integer S_AXIS_TDATA_WIDTH = 32,
  parameter integer M_AXIS_TDATA_WIDTH = 96
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

  localparam integer RATIO = M_AXIS_TDATA_WIDTH / S_AXIS_TDATA_WIDTH;
  localparam integer CNTR_WIDTH = RATIO > 1 ? $clog2(RATIO) : 1;
  localparam integer DATA_WIDTH = M_AXIS_TDATA_WIDTH - S_AXIS_TDATA_WIDTH;

  reg [CNTR_WIDTH-1:0] int_cntr_reg;
  reg [DATA_WIDTH-1:0] int_data_reg;

  wire int_last_wire, int_valid_wire, int_ready_wire;

  assign int_last_wire = int_cntr_reg == cfg_data[CNTR_WIDTH-1:0];

  assign int_valid_wire = s_axis_tvalid & int_last_wire;

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

    if(s_axis_tvalid & int_ready_wire)
    begin
      int_data_reg <= {s_axis_tdata, int_data_reg[DATA_WIDTH-1:S_AXIS_TDATA_WIDTH]};
    end
  end

  inout_buffer #(
    .DATA_WIDTH(M_AXIS_TDATA_WIDTH)
  ) buf_0 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data({s_axis_tdata, int_data_reg}), .in_valid(int_valid_wire), .in_ready(int_ready_wire),
    .out_data(m_axis_tdata), .out_valid(m_axis_tvalid), .out_ready(m_axis_tready)
  );

  assign s_axis_tready = int_ready_wire;

endmodule
