#!/bin/bash

export DISPLAY=':0'
export XAUTHORITY="/run/user/1000/gdm/Xauthority"

if [[ $# -ne 1 ]]
then
	echo "You need to specify which way to rotate."
	echo "EX: none, half (180 degrees), wc, ccw"
	exit 1
fi

DEFAULTCTM="1 0 0 0 1 0 0 0 1"	#default Coordinate Transformation Matrix
leftr="0 -1 1 1 0 0 0 0 1"
rightr="0 1 0 -1 0 1 0 0 1"
upsider="-1 0 1 0 -1 1 0 0 1"

CTM=$DEFAULTCTM
rotation=$1

if [[ $rotation == "ccw" ]]
then
	CTM=$leftr
	xrandr_action="left"
elif [[ $rotation == "cw" ]]
then
	CTM=$rightr
	xrandr_action="right"
elif [[ $rotation == "none" ]]
then
	CTM=$DEFAULTCTM
	xrandr_action="normal"
elif [[ $rotation == "half" ]]
then
	CTM=$upsider
	xrandr_action="inverted"
fi


xinput set-prop "pointer:CUST0000:00 04F3:2A4B" "Coordinate Transformation Matrix" $CTM
xinput set-prop "keyboard:CUST0000:00 04F3:2A4B" "Coordinate Transformation Matrix" $CTM
xrandr --output eDP1 --rotate $xrandr_action
