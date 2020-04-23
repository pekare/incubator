#!/bin/bash

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install -y docker-ce
sudo systemctl start docker


# run gobuster
ENDPOINT=http://10.10.180.182:3333
WORDLIST=directory-list-2.3-medium.txt
docker run -it --rm -v /usr/share/wordlists/dirbuster:/wordlists trickest/gobuster -u $ENDPOINT -w /wordlists/$WORDLIST
