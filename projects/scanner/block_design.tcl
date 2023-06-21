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
  CFG_DATA_WIDTH 224
  STS_DATA_WIDTH 64
} {
  S_AXI ps_0/M_AXI_GP0
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 224 DIN_FROM 0 DIN_TO 0
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 224 DIN_FROM 1 DIN_TO 1
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_2 {
  DIN_WIDTH 224 DIN_FROM 2 DIN_TO 2
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_3 {
  DIN_WIDTH 224 DIN_FROM 3 DIN_TO 3
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_4 {
  DIN_WIDTH 224 DIN_FROM 31 DIN_TO 16
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_5 {
  DIN_WIDTH 224 DIN_FROM 63 DIN_TO 32
} {
  din hub_0/cfg_data
}

# DAC

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_0 {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 2048
} {
  S_AXIS hub_0/M00_AXIS
  aclk pll_0/clk_out1
  aresetn slice_0/dout
}

# Create axis_controller
cell pavel-demin:user:axis_controller ctrl_0 {} {
  S_AXIS fifo_0/M_AXIS
  cfg_data slice_5/dout
  aclk pll_0/clk_out1
  aresetn slice_1/dout
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 9
  M_TDATA_NUM_BYTES 3
} {
  S_AXIS ctrl_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_1/dout
}

# Create axis_spi
cell pavel-demin:user:axis_spi spi_0 {
  SPI_DATA_WIDTH 24
  AXIS_TDATA_WIDTH 24
} {
  S_AXIS conv_0/M_AXIS
  spi_data spi_dac
  aclk pll_0/clk_out1
  aresetn slice_1/dout
}

# ADC

for {set i 0} {$i <= 3} {incr i} {

  # Create axis_adc
  cell pavel-demin:user:axis_adc adc_$i {
    ADC_DATA_WIDTH 14
    AXIS_TDATA_WIDTH 16
  } {
    adc_n adc_${i}_n
    adc_p adc_${i}_p
    aclk pll_0/clk_out1
  }

}

for {set i 0} {$i <= 4} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer slice_[expr $i + 6] {
    DIN_WIDTH 224 DIN_FROM [expr 32 * $i + 95] DIN_TO [expr 32 * $i + 64]
  } {
    din hub_0/cfg_data
  }

  # Create axis_constant
  cell pavel-demin:user:axis_constant phase_$i {
    AXIS_TDATA_WIDTH 32
  } {
    cfg_data slice_[expr $i + 6]/dout
    aclk pll_0/clk_out1
  }

  # Create dds_compiler
  cell xilinx.com:ip:dds_compiler dds_$i {
    DDS_CLOCK_RATE 250
    SPURIOUS_FREE_DYNAMIC_RANGE 138
    FREQUENCY_RESOLUTION 0.4
    PHASE_INCREMENT Streaming
    HAS_ARESETN true
    HAS_PHASE_OUT false
    PHASE_WIDTH 30
    OUTPUT_WIDTH 24
    NEGATIVE_SINE true
  } {
    S_AXIS_PHASE phase_$i/M_AXIS
    aclk pll_0/clk_out1
    aresetn slice_2/dout
  }
}

# Create c_shift_ram
cell xilinx.com:ip:c_shift_ram delay_0 {
  WIDTH.VALUE_SRC USER
  WIDTH 14
  DEPTH 3
} {
  D adc_0/m_axis_tdata
  CLK pll_0/clk_out1
}

# Create c_shift_ram
cell xilinx.com:ip:c_shift_ram delay_1 {
  WIDTH.VALUE_SRC USER
  WIDTH 14
  DEPTH 3
} {
  D adc_1/m_axis_tdata
  CLK pll_0/clk_out1
}

# Create dsp48
cell pavel-demin:user:dsp48 mixer_0 {
  A_WIDTH 14
  B_WIDTH 14
  P_WIDTH 18
} {
  A adc_1/m_axis_tdata
  B adc_2/m_axis_tdata
  CLK pll_0/clk_out1
}

# Create dsp48
cell pavel-demin:user:dsp48 mixer_1 {
  A_WIDTH 14
  B_WIDTH 14
  P_WIDTH 18
} {
  A adc_1/m_axis_tdata
  B adc_3/m_axis_tdata
  CLK pll_0/clk_out1
}

for {set i 0} {$i <= 9} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer dds_slice_$i {
    DIN_WIDTH 48 DIN_FROM [expr 24 * ($i % 2) + 23] DIN_TO [expr 24 * ($i % 2)]
  } {
    din dds_[expr $i / 2]/m_axis_data_tdata
  }

  # Create dsp48
  cell pavel-demin:user:dsp48 mult_$i {
    A_WIDTH 24
    B_WIDTH 14
    P_WIDTH 32
  } {
    A dds_slice_$i/dout
    B delay_0/Q
    CLK pll_0/clk_out1
  }

}

for {set i 10} {$i <= 11} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer dds_slice_$i {
    DIN_WIDTH 48 DIN_FROM [expr 24 * ($i % 2) + 23] DIN_TO [expr 24 * ($i % 2)]
  } {
    din dds_0/m_axis_data_tdata
  }

  # Create dsp48
  cell pavel-demin:user:dsp48 mult_$i {
    A_WIDTH 24
    B_WIDTH 14
    P_WIDTH 32
  } {
    A dds_slice_$i/dout
    B delay_1/Q
    CLK pll_0/clk_out1
  }

}

for {set i 12} {$i <= 15} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer dds_slice_$i {
    DIN_WIDTH 48 DIN_FROM [expr 24 * ($i % 2) + 23] DIN_TO [expr 24 * ($i % 2)]
  } {
    din dds_[expr ($i - 10) / 2]/m_axis_data_tdata
  }

  # Create dsp48
  cell pavel-demin:user:dsp48 mult_$i {
    A_WIDTH 24
    B_WIDTH 18
    P_WIDTH 32
  } {
    A dds_slice_$i/dout
    B mixer_0/P
    CLK pll_0/clk_out1
  }

}

for {set i 16} {$i <= 19} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer dds_slice_$i {
    DIN_WIDTH 48 DIN_FROM [expr 24 * ($i % 2) + 23] DIN_TO [expr 24 * ($i % 2)]
  } {
    din dds_[expr ($i - 10) / 2]/m_axis_data_tdata
  }

  # Create dsp48
  cell pavel-demin:user:dsp48 mult_$i {
    A_WIDTH 24
    B_WIDTH 18
    P_WIDTH 32
  } {
    A dds_slice_$i/dout
    B mixer_1/P
    CLK pll_0/clk_out1
  }

}

for {set i 0} {$i <= 19} {incr i} {

  # Create axis_variable
  cell pavel-demin:user:axis_variable rate_$i {
    AXIS_TDATA_WIDTH 16
  } {
    cfg_data slice_4/dout
    aclk pll_0/clk_out1
    aresetn slice_2/dout
  }

  # Create cic_compiler
  cell xilinx.com:ip:cic_compiler cic_$i {
    INPUT_DATA_WIDTH.VALUE_SRC USER
    FILTER_TYPE Decimation
    NUMBER_OF_STAGES 6
    SAMPLE_RATE_CHANGES Programmable
    MINIMUM_RATE 10
    MAXIMUM_RATE 1000
    FIXED_OR_INITIAL_RATE 10
    INPUT_SAMPLE_FREQUENCY 250
    CLOCK_FREQUENCY 250
    INPUT_DATA_WIDTH 32
    QUANTIZATION Truncation
    OUTPUT_DATA_WIDTH 32
    USE_XTREME_DSP_SLICE false
    HAS_DOUT_TREADY true
    HAS_ARESETN true
  } {
    s_axis_data_tdata mult_$i/P
    s_axis_data_tvalid const_0/dout
    S_AXIS_CONFIG rate_$i/M_AXIS
    aclk pll_0/clk_out1
    aresetn slice_2/dout
  }

}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  NUM_SI 10
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  S02_AXIS cic_2/M_AXIS_DATA
  S03_AXIS cic_3/M_AXIS_DATA
  S04_AXIS cic_4/M_AXIS_DATA
  S05_AXIS cic_5/M_AXIS_DATA
  S06_AXIS cic_6/M_AXIS_DATA
  S07_AXIS cic_7/M_AXIS_DATA
  S08_AXIS cic_8/M_AXIS_DATA
  S09_AXIS cic_9/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn slice_2/dout
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_1 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  NUM_SI 10
} {
  S00_AXIS cic_10/M_AXIS_DATA
  S01_AXIS cic_11/M_AXIS_DATA
  S02_AXIS cic_12/M_AXIS_DATA
  S03_AXIS cic_13/M_AXIS_DATA
  S04_AXIS cic_14/M_AXIS_DATA
  S05_AXIS cic_15/M_AXIS_DATA
  S06_AXIS cic_16/M_AXIS_DATA
  S07_AXIS cic_17/M_AXIS_DATA
  S08_AXIS cic_18/M_AXIS_DATA
  S09_AXIS cic_19/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn slice_2/dout
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_1 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 40
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS comb_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_2/dout
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_2 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 40
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS comb_1/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_2/dout
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_20 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  FIXED_OR_INITIAL_RATE 250
  INPUT_SAMPLE_FREQUENCY 25
  CLOCK_FREQUENCY 250
  NUMBER_OF_CHANNELS 10
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_DOUT_TREADY true
  HAS_ARESETN true
} {
  S_AXIS_DATA conv_1/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_2/dout
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_21 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  FIXED_OR_INITIAL_RATE 250
  INPUT_SAMPLE_FREQUENCY 25
  CLOCK_FREQUENCY 250
  NUMBER_OF_CHANNELS 10
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_DOUT_TREADY true
  HAS_ARESETN true
} {
  S_AXIS_DATA conv_2/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_2/dout
}

# Create floating_point
cell xilinx.com:ip:floating_point fp_0 {
  OPERATION_TYPE Fixed_to_float
  A_PRECISION_TYPE.VALUE_SRC USER
  C_A_EXPONENT_WIDTH.VALUE_SRC USER
  C_A_FRACTION_WIDTH.VALUE_SRC USER
  A_PRECISION_TYPE Custom
  C_A_EXPONENT_WIDTH 2
  C_A_FRACTION_WIDTH 30
  RESULT_PRECISION_TYPE Single
  HAS_ARESETN true
} {
  S_AXIS_A cic_20/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn slice_2/dout
}

# Create floating_point
cell xilinx.com:ip:floating_point fp_1 {
  OPERATION_TYPE Fixed_to_float
  A_PRECISION_TYPE.VALUE_SRC USER
  C_A_EXPONENT_WIDTH.VALUE_SRC USER
  C_A_FRACTION_WIDTH.VALUE_SRC USER
  A_PRECISION_TYPE Custom
  C_A_EXPONENT_WIDTH 2
  C_A_FRACTION_WIDTH 30
  RESULT_PRECISION_TYPE Single
  HAS_ARESETN true
} {
  S_AXIS_A cic_21/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn slice_2/dout
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_3 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 40
} {
  S_AXIS fp_0/M_AXIS_RESULT
  aclk pll_0/clk_out1
  aresetn slice_2/dout
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_4 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 40
} {
  S_AXIS fp_1/M_AXIS_RESULT
  aclk pll_0/clk_out1
  aresetn slice_2/dout
}

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_1 {
  S_AXIS_TDATA_WIDTH 320
  M_AXIS_TDATA_WIDTH 320
  WRITE_DEPTH 2048
  ALWAYS_READY TRUE
} {
  S_AXIS conv_3/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_3/dout
}

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_2 {
  S_AXIS_TDATA_WIDTH 320
  M_AXIS_TDATA_WIDTH 320
  WRITE_DEPTH 2048
  ALWAYS_READY TRUE
} {
  S_AXIS conv_4/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_3/dout
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_5 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 40
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS fifo_1/M_AXIS
  M_AXIS hub_0/S00_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_3/dout
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_6 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 40
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS fifo_2/M_AXIS
  M_AXIS hub_0/S01_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_3/dout
}

# STS

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 3
  IN0_WIDTH 16
  IN1_WIDTH 16
  IN2_WIDTH 16
} {
  In0 fifo_0/write_count
  In1 fifo_1/read_count
  In2 fifo_2/read_count
  dout hub_0/sts_data
}
