
`timescale 1 ns / 1 ps

module axis_controller
(
  // System signals
  input  wire        aclk,
  input  wire        aresetn,

  input  wire [31:0] cfg_data,

  // Slave side
  input  wire [31:0] s_axis_tdata,
  input  wire        s_axis_tvalid,
  output wire        s_axis_tready,

  // Master side
  output wire [95:0] m_axis_tdata,
  output wire        m_axis_tvalid
);

  reg [31:0] int_cntr_reg;
  reg [95:0] int_data_reg;
  reg int_valid_reg;

  assign int_comp_wire = |int_cntr_reg;

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_cntr_reg <= 32'd0;
      int_data_reg <= 96'd0;
      int_valid_reg <= 1'b0;
    end
    else
    begin
      if(int_comp_wire)
      begin
        int_cntr_reg <= int_cntr_reg - 1'b1;
        int_data_reg <= 96'd0;
        int_valid_reg <= 1'b0;
      end
      else if(s_axis_tvalid)
      begin
        int_cntr_reg <= cfg_data;
        int_data_reg <= {24'h000000, 24'h250000, 8'h14, s_axis_tdata[31:16], 8'h11, s_axis_tdata[15:0]};
        int_valid_reg <= 1'b1;
      end
    end
  end

  assign s_axis_tready = ~int_comp_wire & aresetn;
  assign m_axis_tdata = int_data_reg;
  assign m_axis_tvalid = int_valid_reg;

endmodule
