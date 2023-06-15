# Create clk_wiz
cell xilinx.com:ip:clk_wiz pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 250.0
  PRIM_SOURCE Differential_clock_capable_pin
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 250.0
  CLKOUT1_REQUESTED_PHASE 78.75
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

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset rst_0 {} {
  ext_reset_in const_0/dout
  dcm_locked pll_0/locked
  slowest_sync_clk pll_0/clk_out1
}

# HUB

# Create axi_hub
cell pavel-demin:user:axi_hub hub_0 {
  CFG_DATA_WIDTH 96
  STS_DATA_WIDTH 64
} {
  S_AXI ps_0/M_AXI_GP0
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 96 DIN_FROM 0 DIN_TO 0
} {
  din hub_0/cfg_data
}

# GPIO

# Delete input/output port
delete_bd_objs [get_bd_ports exp_n]

# Create output port
create_bd_port -dir O -from 7 -to 0 exp_n

# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 96 DIN_FROM 39 DIN_TO 32
} {
  din hub_0/cfg_data
  dout exp_n
}

# DSP48

# Create port_slicer
cell pavel-demin:user:port_slicer slice_2 {
  DIN_WIDTH 96 DIN_FROM 79 DIN_TO 64
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_3 {
  DIN_WIDTH 96 DIN_FROM 95 DIN_TO 80
} {
  din hub_0/cfg_data
}


# Create dsp_macro
cell xilinx.com:ip:dsp_macro dsp_0 {
  INSTRUCTION1 A*B
  A_WIDTH.VALUE_SRC USER
  B_WIDTH.VALUE_SRC USER
  OUTPUT_PROPERTIES User_Defined
  A_WIDTH 16
  B_WIDTH 16
  P_WIDTH 32
} {
  A slice_2/dout
  B slice_3/dout
  CLK pll_0/clk_out1
}

# COUNTER

# Create axis_counter
cell pavel-demin:user:axis_counter cntr_0 {
  AXIS_TDATA_WIDTH 32
} {
  M_AXIS hub_0/S01_AXIS
  aclk pll_0/clk_out1
}

# ADC

for {set i 0} {$i <= 3} {incr i} {

  # Create axis_adc
  cell pavel-demin:user:axis_adc adc_$i {
    ADC_DATA_WIDTH 14
  } {
    adc_n adc_${i}_n
    adc_p adc_${i}_p
    aclk pll_0/clk_out1
  }

}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 2
  NUM_SI 4
} {
  S00_AXIS adc_0/M_AXIS
  S01_AXIS adc_1/M_AXIS
  S02_AXIS adc_2/M_AXIS
  S03_AXIS adc_3/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# FIFO

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_0 {
  S_AXIS_TDATA_WIDTH 64
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 8192
} {
  S_AXIS comb_0/M_AXIS
  M_AXIS hub_0/S00_AXIS
  aclk pll_0/clk_out1
  aresetn slice_0/dout
}

# DAC SPI

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_1 {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 1024
} {
  S_AXIS hub_0/M00_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_spi
cell pavel-demin:user:axis_spi spi_0 {
  SPI_DATA_WIDTH 24
  AXIS_TDATA_WIDTH 24
} {
  S_AXIS fifo_1/M_AXIS
  spi_data spi_dac
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# STS

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 2
  IN0_WIDTH 32
  IN1_WIDTH 32
} {
  In0 fifo_0/read_count
  In1 dsp_0/P
  dout hub_0/sts_data
}
