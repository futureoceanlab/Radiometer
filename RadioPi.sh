#!/bin/bash

echo "Running RadioPi..."
source ./RadioPiExp.sh
sudo nice -n -20 ./RadioPi &
echo "RadioPi Running in bg..."
