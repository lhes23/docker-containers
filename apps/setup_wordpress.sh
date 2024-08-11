#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <domain> <wp_port>"
    exit 1
fi

# Assign arguments to variables
DOMAIN=$1
WP_PORT=$2

# Directory where files will be copied
TARGET_DIR="./${DOMAIN}"

# Create the target directory if it does not exist
mkdir -p "$TARGET_DIR"

# Copy .env and docker-compose.yml to the target directory
# cp .env docker-compose.yml "$TARGET_DIR"

# Navigate to the target directory
cd "$TARGET_DIR" || exit

mkdir -p wordpress
chmod -R 755 wordpress

# Create a docker-compose.override.yml for custom configuration
cat <<EOL > docker-compose.yml
services:
  wordpress:
    image: wordpress:latest
    container_name: ${DOMAIN}_wp
    volumes:
      - ./wordpress:/var/www/html
      - ../../nginx-proxy-manager/php/php.ini:/usr/local/etc/php/conf.d/php.ini
    ports:
      - "${WP_PORT}:80"
    restart: unless-stopped
    environment:
      WORDPRESS_DB_HOST: wp_db:3306
      WORDPRESS_DB_NAME: ${DOMAIN}_wp
      WORDPRESS_DB_USER: ${DOMAIN}_wp
      WORDPRESS_DB_PASSWORD: ${DOMAIN}
    networks:
      - network

networks:
  network:
    name: wp_nginx_network
    external: true
EOL

# Start the Docker containers
docker-compose up -d

# Create the database and user
DB_NAME="${DOMAIN}_wp"
DB_USER="${DOMAIN}_wp"
DB_PASSWORD="${DOMAIN}"
DB_ROOT_PASSWORD="root"  # Use the same root password as in your docker-compose.yml

echo "Creating database and user for WordPress..."

docker exec wp_db mysql -u root -p"$DB_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
docker exec wp_db mysql -u root -p"$DB_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"
docker exec wp_db mysql -u root -p"$DB_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
docker exec wp_db mysql -u root -p"$DB_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"


# Create the Nginx configuration file
cat <<EOL > ../../nginx-proxy-manager/conf.d/${DOMAIN}.conf
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};
    # return 301 https://\$host\$request_uri;  # Redirect HTTP to HTTPS

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        proxy_pass http://${DOMAIN}_wp:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}


# server {
#     listen 443 ssl;
#     server_name ${DOMAIN} www.${DOMAIN};

#     ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
#     ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
#     ssl_trusted_certificate /etc/letsencrypt/live/${DOMAIN}/chain.pem;

#     location / {
#         proxy_pass http://${DOMAIN}_wp:80;
#         proxy_set_header Host \$host;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#     }

#     location /.well-known/acme-challenge/ {
#         root /var/www/certbot;
#     }
# }

EOL

# Run Certbot to obtain the certificate
cd ../../nginx-proxy-manager
# docker-compose exec certbot certbot certonly --webroot --webroot-path=/var/www/certbot -d ${DOMAIN} -d www.${DOMAIN} --email admin@lester1.com --agree-tos --no-eff-email

# Restart Nginx to apply changes
docker exec wp_nginx nginx -s reload

# Print completion message
echo "Setup complete for ${DOMAIN}. WordPress is running, and SSL certificates have been obtained."

# Go back to the original directory
cd - || exit
