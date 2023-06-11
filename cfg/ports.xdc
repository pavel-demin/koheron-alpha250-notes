# Koheron ALPHA250-4 constraints file

set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPPOWERDOWN ENABLE [current_design]

# Clocks (Bank 34)

set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports clk_gen_*]

set_property PACKAGE_PIN U19 [get_ports clk_gen_in_clk_n] ;# MRCC
set_property PACKAGE_PIN U18 [get_ports clk_gen_in_clk_p] ;# MRCC

set_property PACKAGE_PIN U15 [get_ports clk_gen_out_n] ;# SRCC
set_property PACKAGE_PIN U14 [get_ports clk_gen_out_p] ;# SRCC

# Configuration SPI (Bank 34)

set_property IOSTANDARD LVCMOS18 [get_ports spi_cfg_*]

set_property PACKAGE_PIN W16 [get_ports spi_cfg_sclk]
set_property PACKAGE_PIN R16 [get_ports spi_cfg_mosi]
set_property PACKAGE_PIN R17 [get_ports spi_cfg_miso]

set_property PACKAGE_PIN T12 [get_ports spi_cfg_ss]
set_property PACKAGE_PIN U12 [get_ports spi_cfg_ss1]
set_property PACKAGE_PIN V16 [get_ports spi_cfg_ss2]

# Precision DAC (Bank 34)

set_property IOSTANDARD LVCMOS18 [get_ports {spi_dac[*]}]

set_property PACKAGE_PIN V18 [get_ports {spi_dac[0]}]
set_property PACKAGE_PIN T17 [get_ports {spi_dac[1]}]
set_property PACKAGE_PIN V17 [get_ports {spi_dac[2]}]
set_property PACKAGE_PIN R18 [get_ports {spi_dac[3]}]

# Precision ADC (Bank 34)

set_property IOSTANDARD LVCMOS18 [get_ports spi_adc_*]

set_property PACKAGE_PIN V13 [get_ports spi_adc_sclk]
set_property PACKAGE_PIN T11 [get_ports spi_adc_mosi]
set_property PACKAGE_PIN T10 [get_ports spi_adc_miso]

set_property PACKAGE_PIN U13 [get_ports spi_adc_ss]

# Expansion connector IOs (Bank 35)

set_property IOSTANDARD LVCMOS18 [get_ports {exp_n[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {exp_p[*]}]

set_property PACKAGE_PIN J14 [get_ports {exp_n[0]}]
set_property PACKAGE_PIN K14 [get_ports {exp_p[0]}]
set_property PACKAGE_PIN L15 [get_ports {exp_n[1]}]
set_property PACKAGE_PIN L14 [get_ports {exp_p[1]}]
set_property PACKAGE_PIN M15 [get_ports {exp_n[2]}]
set_property PACKAGE_PIN M14 [get_ports {exp_p[2]}]
set_property PACKAGE_PIN J19 [get_ports {exp_n[3]}]
set_property PACKAGE_PIN K19 [get_ports {exp_p[3]}]
set_property PACKAGE_PIN L20 [get_ports {exp_n[4]}]
set_property PACKAGE_PIN L19 [get_ports {exp_p[4]}]
set_property PACKAGE_PIN H17 [get_ports {exp_n[5]}]
set_property PACKAGE_PIN H16 [get_ports {exp_p[5]}]
set_property PACKAGE_PIN M20 [get_ports {exp_n[6]}]
set_property PACKAGE_PIN M19 [get_ports {exp_p[6]}]
set_property PACKAGE_PIN N16 [get_ports {exp_n[7]}]
set_property PACKAGE_PIN N15 [get_ports {exp_p[7]}]

# ADC

set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports adc_0_clk_*]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports adc_1_clk_*]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {adc_0_n[*]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {adc_0_p[*]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {adc_1_n[*]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {adc_1_p[*]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {adc_2_n[*]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {adc_2_p[*]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {adc_3_n[*]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {adc_3_p[*]}]

set_property PACKAGE_PIN K18 [get_ports adc_0_clk_n] ;# MRCC
set_property PACKAGE_PIN K17 [get_ports adc_0_clk_p] ;# MRCC

set_property PACKAGE_PIN P19 [get_ports adc_1_clk_n] ;# MRCC
set_property PACKAGE_PIN N18 [get_ports adc_1_clk_p] ;# MRCC

# Channel 0
set_property PACKAGE_PIN F20 [get_ports {adc_0_n[0]}]
set_property PACKAGE_PIN F19 [get_ports {adc_0_p[0]}]
set_property PACKAGE_PIN L17 [get_ports {adc_0_n[1]}]
set_property PACKAGE_PIN L16 [get_ports {adc_0_p[1]}]
set_property PACKAGE_PIN D20 [get_ports {adc_0_n[2]}]
set_property PACKAGE_PIN D19 [get_ports {adc_0_p[2]}]
set_property PACKAGE_PIN B20 [get_ports {adc_0_n[3]}]
set_property PACKAGE_PIN C20 [get_ports {adc_0_p[3]}]
set_property PACKAGE_PIN F17 [get_ports {adc_0_n[4]}]
set_property PACKAGE_PIN F16 [get_ports {adc_0_p[4]}]
set_property PACKAGE_PIN A20 [get_ports {adc_0_n[5]}]
set_property PACKAGE_PIN B19 [get_ports {adc_0_p[5]}]
set_property PACKAGE_PIN E19 [get_ports {adc_0_n[6]}]
set_property PACKAGE_PIN E18 [get_ports {adc_0_p[6]}]

# Channel 1
set_property PACKAGE_PIN G15 [get_ports {adc_1_n[0]}]
set_property PACKAGE_PIN H15 [get_ports {adc_1_p[0]}]
set_property PACKAGE_PIN M18 [get_ports {adc_1_n[1]}]
set_property PACKAGE_PIN M17 [get_ports {adc_1_p[1]}]
set_property PACKAGE_PIN H18 [get_ports {adc_1_n[2]}]
set_property PACKAGE_PIN J18 [get_ports {adc_1_p[2]}]
set_property PACKAGE_PIN H20 [get_ports {adc_1_n[3]}]
set_property PACKAGE_PIN J20 [get_ports {adc_1_p[3]}]
set_property PACKAGE_PIN J16 [get_ports {adc_1_n[4]}]
set_property PACKAGE_PIN K16 [get_ports {adc_1_p[4]}]
set_property PACKAGE_PIN G18 [get_ports {adc_1_n[5]}]
set_property PACKAGE_PIN G17 [get_ports {adc_1_p[5]}]
set_property PACKAGE_PIN G20 [get_ports {adc_1_n[6]}]
set_property PACKAGE_PIN G19 [get_ports {adc_1_p[6]}]

# Channel 2
set_property PACKAGE_PIN U17 [get_ports {adc_2_n[0]}]
set_property PACKAGE_PIN T16 [get_ports {adc_2_p[0]}]
set_property PACKAGE_PIN Y19 [get_ports {adc_2_n[1]}]
set_property PACKAGE_PIN Y18 [get_ports {adc_2_p[1]}]
set_property PACKAGE_PIN P16 [get_ports {adc_2_n[2]}]
set_property PACKAGE_PIN P15 [get_ports {adc_2_p[2]}]
set_property PACKAGE_PIN W19 [get_ports {adc_2_n[3]}]
set_property PACKAGE_PIN W18 [get_ports {adc_2_p[3]}]
set_property PACKAGE_PIN P18 [get_ports {adc_2_n[4]}]
set_property PACKAGE_PIN N17 [get_ports {adc_2_p[4]}]
set_property PACKAGE_PIN W20 [get_ports {adc_2_n[5]}]
set_property PACKAGE_PIN V20 [get_ports {adc_2_p[5]}]
set_property PACKAGE_PIN U20 [get_ports {adc_2_n[6]}]
set_property PACKAGE_PIN T20 [get_ports {adc_2_p[6]}]

# Channel 3
set_property PACKAGE_PIN W13 [get_ports {adc_3_n[0]}]
set_property PACKAGE_PIN V12 [get_ports {adc_3_p[0]}]
set_property PACKAGE_PIN Y14 [get_ports {adc_3_n[1]}]
set_property PACKAGE_PIN W14 [get_ports {adc_3_p[1]}]
set_property PACKAGE_PIN P20 [get_ports {adc_3_n[2]}] ;# SRCC
set_property PACKAGE_PIN N20 [get_ports {adc_3_p[2]}] ;# SRCC
set_property PACKAGE_PIN R14 [get_ports {adc_3_n[3]}]
set_property PACKAGE_PIN P14 [get_ports {adc_3_p[3]}]
set_property PACKAGE_PIN W15 [get_ports {adc_3_n[4]}]
set_property PACKAGE_PIN V15 [get_ports {adc_3_p[4]}]
set_property PACKAGE_PIN T15 [get_ports {adc_3_n[5]}]
set_property PACKAGE_PIN T14 [get_ports {adc_3_p[5]}]
set_property PACKAGE_PIN Y17 [get_ports {adc_3_n[6]}]
set_property PACKAGE_PIN Y16 [get_ports {adc_3_p[6]}]

# XADC

set_property PACKAGE_PIN K9  [get_ports Vp_Vn_v_p]
set_property PACKAGE_PIN L10 [get_ports Vp_Vn_v_n]
