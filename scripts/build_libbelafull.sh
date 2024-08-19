#!/bin/bash -e

source build_settings
BBB_ADDRESS=root@$BBB_HOSTNAME

rsync \
--timeout=10 \
-avzP  /tmp/CustomMakefile* \
$BBB_ADDRESS:Bela/

ssh $BBB_ADDRESS "cd Bela && make libbelafull"