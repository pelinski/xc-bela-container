#!/bin/bash

mkdir -p /root/.ssh
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts
echo "export PROMPT_COMMAND='history -a' export HISTFILE=/root/.bash_history" >> /root/.bashrc

source build_settings
BBB_ADDRESS=root@$BBB_HOSTNAME

# set date and build libraries
ssh-keygen -R $1 &> /dev/null || true
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 $BBB_ADDRESS "date -s \"`date '+%Y%m%d %T %z'`\" > /dev/null"

# change Bela branch to dev commit
git clone https://github.com/BelaPlatform/Bela.git /sysroot/root/Bela
cd /sysroot/root/Bela
git remote add board $BBB_ADDRESS:Bela/
git checkout $BELA_COMMIT
git switch -c tmp
ssh $BBB_ADDRESS "cd Bela && git config receive.denyCurrentBranch updateInstead"
git push -f board tmp:tmp
ssh $BBB_ADDRESS "cd Bela && git config --unset receive.denyCurrentBranch"
ssh $BBB_ADDRESS "cd Bela && git checkout tmp"

# pasm
cd /tmp/
git clone https://github.com/giuliomoro/am335x_pru_package
cd am335x_pru_package/pru_sw/utils/pasm_source 
./linuxbuild 
cp ../pasm /usr/local/bin 
rm -rf /tmp/am335x_pru_package