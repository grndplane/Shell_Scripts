#!/bin/bash

# Dynamically controll FT-991A Radio from qsstv app

rigctld -m 1035 -s 38400 -t 4532 -r /dev/ttyUSB0
