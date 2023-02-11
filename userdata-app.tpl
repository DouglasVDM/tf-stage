#! /bin/bash
sudo apt update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
sudo apt update
sudo apt-get install docker-ce
sudo systemctl start docker
sudo systemctl enable docker
sudo groupadd docker
sudo usermod -aG docker ubuntu
docker info
sudo apt  install awscli 
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 391551845951.dkr.ecr.us-east-1.amazonaws.com
docker pull 391551845951.dkr.ecr.us-east-1.amazonaws.com/cloud-module:react-app
docker run -d -p 3000:3000 --name react-app 61a6a4a5e217