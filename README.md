sudo apt update && sudo apt upgrade -y

sudo apt install docker.io

sudo apt install docker-compose

Go to the dockercontainer/nginx-proxy-manager folder

Run command
sudo docker-compose up -d

On Security groups open port All TCP from anywhere

Login to proxy manager

add proxy hosts



## How to See DB Credentials
sudo docker exec -it container_name env

# to see container
sudo docker-compose ps

sudo docker exec -it lester2.com_db mysql -u root
