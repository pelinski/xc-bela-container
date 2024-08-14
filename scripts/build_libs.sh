#!/bin/bash -e

source build_settings
BBB_ADDRESS=root@$BBB_HOSTNAME

ssh $BBB_ADDRESS "cd Bela && make lib"
ssh $BBB_ADDRESS "cd Bela && make -f Makefile.libraries all"

# check for clock skew and rebuild if necessary
ssh $BBB_ADDRESS "cd Bela && make lib 2>&1 | tee logfile || exit 1;
grep -q \"skew detected\" logfile && { echo CLOCK SKEW DETECTED. CLEANING CORE AND TRYING AGAIN && make coreclean && make lib; } || exit 0;"
ssh $BBB_ADDRESS "cd Bela && make -f Makefile.libraries all 2>&1 | tee logfile || exit 1;
grep -q \"skew detected\" logfile && { echo CLOCK SKEW DETECTED. CLEANING LIBRARIES AND TRYING AGAIN && make -f Makefile.libraries cleanall && make -f Makefile.libraries all; } || exit 0;"