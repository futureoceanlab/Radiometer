# Radiometer

Radiometer control code that runs on RPI at the moment

Steps for preparing a RPI to run this code:
(0) setup a wifi connection following:
	https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md

(1) install openmp
	sudo apt-get install libomp-dev

(2) install wiringpi
	sudo apt-get install wiringpi

To compile:
gcc -Wall -fopenmp -lwiringPi -o radiometer radiometer.c -lrt 


for some reason, for wifi access, I also need to run
sudo wpa_cli -i wlan0 reconfigure 
upon log in...
