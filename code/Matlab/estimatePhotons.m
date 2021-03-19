function photons = estimatePhotons(pulses, pctTimeHi, samplePeriod)

switch nargin
    case 2
        samplePeriod = 1;
end

normalizedpulses = pulses/samplePeriod;
load('CalibrationFits.mat');
if (pctTimeHi < crossover_TimeHi(1))
    photons = pulses;
else
    if (pctTimeHi < crossover_TimeHi(2))
        effPower = interp1(fitPulses(1:lowcut), fitPower(1:lowcut), normalizedpulses,'linear','extrap');
    elseif (pctTimeHi < crossover_TimeHi(3))
        effPower = interp1(fitTimeHi, fitPower, pctTimeHi,'linear','extrap');
    else
        effPower = interp1(fitPulses(highcut:end), fitPower(highcut:end), normalizedpulses,'linear','extrap');
    end
    photons = effPower*photons_counted_per_nW;
end
    
