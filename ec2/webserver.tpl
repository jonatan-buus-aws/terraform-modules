#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install unattended-upgrades -y
sudo apt install nginx -y
sudo systemctl start nginx