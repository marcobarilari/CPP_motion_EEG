# RDK motion EEG

**WARNING**

The time of presentation of the different stimuli is not yet what it is supposed to be: Don't be alarmed.

___

Script for EEG experiments on motion: frequency tagging and ERP

Main function is `MotionEEG.m`.

Remember to switch `SkipSyncTest` and `Cfg.debug` off at the top of this function.

It calls `ExpDesign.m` to set up the configuration (`Cfg`) which means that most tweaking has to be done in `ExpDesign.m`.

`ExpDesign.m` also creates the sequences of stimuli to be presented and returns them to `MotionEEG.m`.

`MotionEEG.m` then calls `DoDotMo.m` which will display one 'trial' of dots (static or moving) and then wait for an ISI.

A trial of of dot motion is defined by a motion speed, motion direction, duration,


## TO DO
- [ ] need to add trial nature (target or not) in the sequences and add this to the log
- [ ] collect several responses per trial

### DoDotMo
- [ ] time of presentation does not match actual presented time

** this previous point is still the most problematic **

- [ ] fix inhomogeneous dot density in direction opposite of motion
- [ ] express lifetime of dots on seconds and not in number of killed by frame

#### for ERP
- [ ] generate the proper stim sequences (ISI, duration, speed, direction)
- [ ] improve log
