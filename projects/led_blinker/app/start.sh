#! /bin/sh

apps_dir=/media/mmcblk0p1/apps

source $apps_dir/stop.sh

cat $apps_dir/led_blinker/led_blinker.bit > /dev/xdevcfg

$apps_dir/common_tools/setup
