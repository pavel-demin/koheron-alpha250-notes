source /opt/Xilinx/2025.1/Vitis/settings64.sh

JOBS=`nproc 2> /dev/null || echo 1`

make NAME=led_blinker all

PRJS="adc_recorder playground scanner"

printf "%s\n" $PRJS | xargs -n 1 -P $JOBS -I {} make NAME={} bit

sudo sh scripts/alpine.sh
