#!/bin/bash
cd /home/pi/Radiometer
echo "Running RadioPi..."
source ./RadioPiExp.sh
sudo nice -n -20 ./RadioPi > ERR.txt &
echo "RadioPi Running in Background.."
