#include <iostream>
#include <math.h>
#include "PhotonEstimation.h"
#include "TestEstimator.h"

int main(int, char**) {
    int err[30] = {0};
    int ests[30] = {0};
    std::cout << "Hello, world!\n";
    for (int i=0; i<30; i++) {
        ests[i] = Photon_Estimator(exp_pulses[i], exp_time_hi[i],0);
        err[i] = exp_photons[i] - ests[i];
        printf("%d ",err[i]);
    }
}
