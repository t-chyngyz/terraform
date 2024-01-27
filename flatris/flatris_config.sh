#! /bin/bash
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt update && sudo apt install -y yarn
mkdir -p /opt/flatris
cd /opt/flatris/
git clone https://github.com/skidding/flatris.git . || git pull
cp /opt/flatris/.env.example.js /opt/flatris/.env
chown -R ubuntu:ubuntu /opt/flatris/
su - ubuntu -c "cd /opt/flatris/ && yarn install"
su - ubuntu -c "cd /opt/flatris/ && yarn test"
su - ubuntu -c "cd /opt/flatris/ && cp .env.example.js .env"
su - ubuntu -c "cd /opt/flatris/ && yarn build"
su - ubuntu -c "cd /opt/flatris/ && nohup yarn start &"