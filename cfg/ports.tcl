create_bd_port -dir O spi_cfg_sclk
create_bd_port -dir O spi_cfg_mosi
create_bd_port -dir I spi_cfg_miso
create_bd_port -dir O spi_cfg_ss
create_bd_port -dir O spi_cfg_ss1
create_bd_port -dir O spi_cfg_ss2

create_bd_port -dir O spi_adc_sclk
create_bd_port -dir O spi_adc_mosi
create_bd_port -dir I spi_adc_miso
create_bd_port -dir O spi_adc_ss

create_bd_port -dir O -from 3 -to 0 spi_dac

create_bd_port -dir I adc_0_clk_n
create_bd_port -dir I adc_0_clk_p

create_bd_port -dir I adc_1_clk_n
create_bd_port -dir I adc_1_clk_p

create_bd_port -dir I -from 6 -to 0 adc_0_n
create_bd_port -dir I -from 6 -to 0 adc_0_p

create_bd_port -dir I -from 6 -to 0 adc_1_n
create_bd_port -dir I -from 6 -to 0 adc_1_p

create_bd_port -dir I -from 6 -to 0 adc_2_n
create_bd_port -dir I -from 6 -to 0 adc_2_p

create_bd_port -dir I -from 6 -to 0 adc_3_n
create_bd_port -dir I -from 6 -to 0 adc_3_p

create_bd_port -dir IO -from 7 -to 0 exp_n
create_bd_port -dir IO -from 7 -to 0 exp_p
