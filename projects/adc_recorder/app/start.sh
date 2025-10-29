#! /bin/sh

apps_dir=/media/mmcblk0p1/apps

source $apps_dir/stop.sh

cat $apps_dir/adc_recorder/adc_recorder.bit > /dev/xdevcfg

$apps_dir/common_tools/setup
