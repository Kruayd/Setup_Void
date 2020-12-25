#!/bin/bash

rotate="/usr/local/bin/rotate-all.sh"
current="none"
lastr="none"

accelx=$(find /sys/devices/ -iname *accel_x_raw | grep HID-SENSOR-200073.12)
accely=$(find /sys/devices/ -iname *accel_y_raw | grep HID-SENSOR-200073.12)

while true; do

	sleep 0.1

	commandx=$(cat $accelx)
	commandy=$(cat $accely)

	if [[ $commandx -gt 600000 ]]
	then
		current="ccw"
	elif [[ $commandx -lt -600000 ]]
	then
		current="cw"
	elif [[ $commandy -gt 750000 ]]
	then
		current="half"
	elif [[ $commandy -lt -750000 ]]
	then
		current="none"
	fi

	if [[ $lastr != $current ]]
	then
		echo "auto-rotating $current"
		$rotate $current
		lastr=$current
	fi

done
