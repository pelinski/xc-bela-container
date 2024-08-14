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
git clone https://github.com/BelaPlatform/Bela.git /tmp/Bela
cd /tmp/Bela
git remote add board $BBB_ADDRESS:Bela/
git checkout $BELA_DEV_COMMIT
git switch -c tmp
ssh $BBB_ADDRESS "cd Bela && git config receive.denyCurrentBranch updateInstead"
git push -f board tmp:tmp
ssh $BBB_ADDRESS "cd Bela && git config --unset receive.denyCurrentBranch"

ssh $BBB_ADDRESS "cd Bela && git checkout tmp"
cd /tmp && rm -rf Bela