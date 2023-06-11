
`timescale 1 ns / 1 ps

module axis_counter #
(
  parameter integer AXIS_TDATA_WIDTH = 32
)
(
  input  wire                        aclk,

  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,
  input  wire                        m_axis_tready
);

  reg [AXIS_TDATA_WIDTH-1:0] int_cntr_reg = {(AXIS_TDATA_WIDTH){1'b0}};

  always @(posedge aclk)
  begin
    if(m_axis_tready)
    begin
      int_cntr_reg <= int_cntr_reg + 1'b1;
    end
  end

  assign m_axis_tdata = int_cntr_reg;
  assign m_axis_tvalid = 1'b1;

endmodule
