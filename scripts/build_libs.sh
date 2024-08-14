#!/bin/bash -e

source build_settings
BBB_ADDRESS=root@$BBB_HOSTNAME


ssh $BBB_ADDRESS "cd Bela && make coreclean"
ssh $BBB_ADDRESS "cd Bela && rm -f lib/*"
ssh $BBB_ADDRESS "cd Bela && make lib"
ssh $BBB_ADDRESS "cd Bela && make -f Makefile.libraries cleanall"
ssh $BBB_ADDRESS "cd Bela && make -f Makefile.libraries all"