# How to create a Multi Wordpress Hosting on AWS EC2 Instance

## Install docker container to AWS EC2 Ubuntu

1. Create a new Instance on AWS EC2. Also create a securiy group. On inbound rules open port All TCP from anywhere

2. Connect to EC21 then Update and upgrade the new Instance

3. Then Install docker and docker-compose

   `sudo apt update && sudo apt upgrade -y`

   `sudo apt install docker.io -y`

   `sudo apt install docker-compose -y`

## Setup Github connection

1. Generate a new SSH key

   `ssh-keygen -t rsa`

2. Copy the id_rsa.pub to github Settings -> SSH and GPG keys

   `cat /home/ubuntu/.ssh/id_rsa.pub`

3. Clone the Repository

   `git clone git@github.com:lhes23/docker-containers.git`

4. Go to the docker-container/nginx-proxy-manager folder and run `docker-compose up -d` command

   `cd docker-container/nginx-proxy-manager`

   `sudo docker-compose up -d`

## Create a Wordpress App

1. Go to the Apps Folder

   `cd ~/docker-containers/apps`

2. Run setup_wordpress.sh with the following arguments

   `./setup_wordpress.sh <domain_name> <port_number>`

## To run certbot

docker-compose exec certbot certbot certonly --webroot --webroot-path=/var/www/certbot -d lester1.com -d www.lester1.com --email admin@lester1.com --agree-tos --no-eff-email
