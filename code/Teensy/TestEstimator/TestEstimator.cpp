#include <iostream>
#include <math.h>
#include "PhotonEstimation.h"
#include "TestEstimator.h"

int main(int, char**) {
    int err[30] = {0};
    int ests[30] = {0};
    int logfreqs[2] = {0,3};
    int freqs[2] = {1, 1000};
    std::cout << "Hello, world!\n";
    for (int j=0; j<2; j++) {
        for (int i=0; i<30; i++) {
            ests[i] = Photon_Estimator(exp_pulses[i]/freqs[j], exp_time_hi[i]/freqs[j],logfreqs[j]);
            err[i] = exp_photons[i]/freqs[j] - ests[i];
            printf("%d ",err[i]);
        }
        printf("\n");
    }
}
