#!/bin/sh
sudo dnf install -y ansible
ansible-playbook -v -K ./bootstrapsystem.playbook.yml ./bootstrapuser.playbook.yml
