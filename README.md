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


## Create User and Database

1. Open phpmyadmin by going to IP_Address:9005

2. Create a User Account and Databse with grant all privileges. Make sure that host name is %

3. Copy the credentials to the .env file



## Create a Wordpress App

1. Go to the Apps Folder

   `cd ~/docker-containers/apps`

2. Create a new directory - named it after the domain

   `sudo mkdir lester1.com`

3. Copy docker-compose and .env

   `sudo cp {docker-compose,.env} lester1.com/.`

4. Go to that folder and edit `.env` . Add the credentials early created with phpmyadmin

5. Then run the docker-compose command

   `sudo docker-compose up -d`



## Setup Proxy

1. Login to proxy manager

2. In your web browser enter [EC2_IP]:81

> Initial Credentials:
> 
> Email: admin@example.com
>
> Password: changeme
>
3. Go to Hosts -> Proxy then Add proxy hosts


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

## Problems Encountered in phpmyadmin

Unknown collation: utf8mb4_0900_ai_ci

Replace the below string on .sql file:

> ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
>
With this:

> ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
