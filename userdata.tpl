#! /bin/bash
sudo apt update -y
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
docker info
aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
docker pull 391551845951.dkr.ecr.us-east-1.amazonaws.com/cloud-module:latest