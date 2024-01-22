# How to create a Multi Wordpress Hosting on AWS EC2 Instance

## Install docker container to AWS EC2 Ubuntu

> Create a new Instance on AWS EC2
>
> Update and upgrade
>
> Then Install docker and docker-compose

`sudo apt update && sudo apt upgrade -y`

`sudo apt install docker.io`

`sudo apt install docker-compose`

## Setup Github connection

`ssh-keygen -t rsa`

`cat /home/ubuntu/.ssh/id_rsa.pub`

> Copy the id_rsa.pub to github Settings -> SSH and GPG keys

`git clone git@github.com:lhes23/docker-containers.git`

> Go to the docker-container/nginx-proxy-manager folder

`cd docker-container/nginx-proxy-manager`

> Run command

`sudo docker-compose up -d`

> On Security groups open port All TCP from anywhere


## Create a Wordpress App

> Go to the Apps Folder

`cd ~/docker-containers/apps`

> Create a new directory - named it after the domain

`sudo mkdir lester1.com`

> Copy docker-compose and .env

`sudo cp {docker-compose,.env} lester1.com/.`

> Go to that folder and edit .env
>
> Then run the docker-compose



## Setup Proxy

> Login to proxy manager
> 
> In your web browser enter [EC2_IP]:81
>
> Initial Credentials:
> 
> Email: admin@example.com
>
> Password: changeme
>
> Go to Hosts -> Proxy then Add proxy hosts


## How to See DB Credentials

> sudo docker exec -it container_name env
>
> sudo docker exec -it container_name_or_id bash

`sudo docker exec -it wp_lester1.com_db env`

## to see container

`sudo docker-compose ps`

## Enter Mysql in a container

`sudo docker exec -it lester2.com_db mysql -u root`

## See User in a DB

`SELECT host, user FROM mysql.user;`
