function micromoles_per_square_meter_per_s_per_photons_counted = RadSensitivityConstantCalculator(Pulses, PctTimeHi, Photodiode_Power)

load('CalibrationFits.mat')
Detector_Aperture = 0.0095; %Diameter in meters
Detector_Area = pi * (Detector_Aperture/2)^2; %m^2
c = 3e8; %Speed of light, m/s
h = 6.626e-34; %Plank's constant, m^2*kg/s
N_A = 6.022e23; %Avogadro's number, mole^-1
lambda = 470e-9; %Wavelength, m
E_photon = h*c/lambda; %Joules

Photons = estimatePhotons(Pulses,PctTimeHi);

fprintf(1, "MPPC Pulses at PctTimeHi = 1: %d\n",Photons);
fprintf(1, "Photodiode Power (nW) at PctTimeHi = 1: %d\n",Photodiode_Power);
fprintf(1, "MPPC Photons detected per Photodiode nW: %d\n\n",photons_counted_per_nW);

fprintf(1, "Photodiode surface area (m^2): %d\n", Detector_Area);
nW_per_square_meter_per_photon_counted = 1/(photons_counted_per_nW*Detector_Area);
fprintf(1, "Photodiode Irradiance (nW/m^2) per MPPC Photon detected: %d\n\n", nW_per_square_meter_per_photon_counted);

fprintf(1, "Photons per nW at 470 nm: %d\n", 1e-9/E_photon);
moles_incident_per_s_per_nW = (1e-9)/(E_photon*N_A); % [E/s] / [E*mole^-1] = [mole/s]
fprintf(1, "microMoles of photons per nW at 470 nm: %d\n",(1e6)*moles_incident_per_s_per_nW);
fprintf(1, "Photodiode Irradiance (microMoles of photons/s*m^2) per MPPC Photon detected: %d\n",(1e6)*moles_incident_per_s_per_nW*nW_per_square_meter_per_photon_counted);

moles_per_square_meter_per_s_per_nW = moles_incident_per_s_per_nW / Detector_Area;

micromoles_per_square_meter_per_s_per_photons_counted =  (1e6)*moles_per_square_meter_per_s_per_nW / photons_counted_per_nW;