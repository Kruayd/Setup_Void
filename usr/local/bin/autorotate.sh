#!/bin/bash

export DISPLAY=':0'
export XAUTHORITY="/home/kruayd/.Xauthority"

rotate="/usr/local/bin/rotate-all.sh"
rotatepen="/usr/loca/bin/rotatepen.sh"
rotateer="/usr/loca/bin/rotateer.sh"
current="none"
lastr="none"
pen="none"
eraser="none"

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

	if [[ $pen == "none"]]
	then
		xinput list | grep "CUST0000:00 04F3:2A4B Pen (0)" && pen="detected" && $rotatepen $current
	fi
	if [[ $eraser == "none"]]
	then
		xinput list | grep "CUST0000:00 04F3:2A4B Eraser (0)" && eraser="detected" && $rotateer $current
	fi

	if [[ $lastr != $current ]]
	then
		echo "auto-rotating $current"
		$rotate $current
		lastr=$current
	fi

done
