# Radiometer To-Do

## To push to Main

- [x] For optional counter, us define statement and ifdef
- [x] Implement lin/log scaling
- [x] Create estimator function, move dummy to there
- [x] Create lastsec photons (line 1310)
- [x] Update cruise defaults
- [x] Update metafile packet documentation (line 895)
- [x] Preallocate ~24 hours worth of files based on Ns

## Request/Respond

- [ ] Figure out code structure
  - [ ] Packet counter
- [ ] List of Commands
  - [ ] Start/stop logging
  - [ ] Start/stop 20 Hz
  - [ ] Set sampling rate

## Photon Estimator

- [ ] Three zones, conditioned on nTimeHigh

## Peripherals

- [ ] Verify that tilt sensor is enabled and working

## Future Features

- [ ] Move to new SD library
- [ ] Update SD packet structure (include LastSec_Photons)
- [ ] Try out MTP responder
- [ ] Try USB through bulkhead
  - [ ] If doesn't work, add human/robot switch to RS232 line
- [ ] Come back to how we count data packet synchrony
- [ ] Rename 'Ns'
  