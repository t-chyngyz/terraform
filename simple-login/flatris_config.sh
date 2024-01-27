#! /bin/bash
apt-add-repository ppa:ansible/ansible
apt update && sudo apt install -y ansible git
chown ubuntu:ubunut /etc/ansible
cd /etc/ansible
rm -rf /etc/ansible/*
git clone https://github.com/t-chyngyz/ansible.git . || git pull
ansible-playbook flask-simple-login-local.yml

