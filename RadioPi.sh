#!/bin/bash
cd /home/pi/Radiometer
echo "Running RadioPi..."
#source ./RadioPiExp.sh
export OMP_NUM_THREADS=3
export OMP_PLACES=cores
export OMP_PROC_BIND=spread
export OMP_CPU_AFFINITY=3,2,1
export GOMP_CPU_AFFINITY=3,2,1

sudo nice -n -20 ./RadioPi > ERR.txt &
echo "RadioPi Running in Background.."
