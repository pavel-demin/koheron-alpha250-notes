# Create clk_wiz
cell xilinx.com:ip:clk_wiz pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 250.0
  PRIM_SOURCE Differential_clock_capable_pin
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 250.0
  USE_RESET false
} {
  clk_in1_n adc_1_clk_n
  clk_in1_p adc_1_clk_p
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_0

# Create processing_system7
cell xilinx.com:ip:processing_system7 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/koheron_alpha250.xml
} {
  M_AXI_GP0_ACLK pll_0/clk_out1
  SPI0_SCLK_O spi_cfg_sclk
  SPI0_MOSI_O spi_cfg_mosi
  SPI0_MISO_I spi_cfg_miso
  SPI0_SS_I const_0/dout
  SPI0_SS_O spi_cfg_ss
  SPI0_SS1_O spi_cfg_ss1
  SPI0_SS2_O spi_cfg_ss2
  SPI1_SCLK_O spi_adc_sclk
  SPI1_MOSI_O spi_adc_mosi
  SPI1_MISO_I spi_adc_miso
  SPI1_SS_I const_0/dout
  SPI1_SS_O spi_adc_ss
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]


# Delete input/output port
delete_bd_objs [get_bd_ports exp_n]

# Create output port
create_bd_port -dir O -from 0 -to 0 exp_n

# LED

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary cntr_0 {
  Output_Width 32
} {
  CLK pll_0/clk_out1
}

# Create port_slicer
cell port_slicer slice_0 {
  DIN_WIDTH 32 DIN_FROM 27 DIN_TO 27
} {
  din cntr_0/Q
  dout exp_n
}
