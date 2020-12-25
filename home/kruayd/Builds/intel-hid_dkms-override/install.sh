#!/bin/bash

sudo make dkmsinstall && sudo rmmod intel-hid && sudo modprobe intel-hid
