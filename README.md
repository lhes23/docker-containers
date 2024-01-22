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

> Go to the dockercontainer/nginx-proxy-manager folder

`cd docker-container/nginx-proxy-manager`

> Run command

`sudo docker-compose up -d`

> On Security groups open port All TCP from anywhere

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

`sudo docker exec -it container_name env`

## to see container

`sudo docker-compose ps`

## Enter Mysql in a container

`sudo docker exec -it lester2.com_db mysql -u root`
