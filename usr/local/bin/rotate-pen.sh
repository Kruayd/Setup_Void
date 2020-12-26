#!/bin/bash

if [[ $# -ne 1 ]]
then
        echo "You need to specify which way to rotate."
        echo "EX: none, half (180 degrees), wc, ccw"
        exit 1
fi

DEFAULTCTM="1 0 0 0 1 0 0 0 1"  #default Coordinate Transformation Matrix
leftr="0 -1 1 1 0 0 0 0 1"
rightr="0 1 0 -1 0 1 0 0 1"
upsider="-1 0 1 0 -1 1 0 0 1"

CTM=$DEFAULTCTM
rotation=$1

if [[ $rotation == "ccw" ]]
then
        CTM=$leftr
elif [[ $rotation == "cw" ]]
then
        CTM=$rightr
elif [[ $rotation == "none" ]]
then
        CTM=$DEFAULTCTM
elif [[ $rotation == "half" ]]
then
        CTM=$upsider
fi


xinput set-prop "CUST0000:00 04F3:2A4B Pen (0)" "Coordinate Transformation Matrix" $CTM
