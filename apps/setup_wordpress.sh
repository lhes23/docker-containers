#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <domain> <wp_port>"
    exit 1
fi

DOMAIN=$1
WP_PORT=$2
# PMA_PORT=$((WP_PORT + 1000))

# Replace dots with underscores for database and user names
DB_NAME="${DOMAIN//./_}_wp"
DB_USER="${DOMAIN//./_}_wp"
DB_PASSWORD=$(openssl rand -base64 12)
DB_ROOT_PASSWORD="root"  # Use the same root password as in your docker-compose.yml

# Directory where files will be copied
TARGET_DIR="./${DOMAIN}"

# Create the target directory if it does not exist
mkdir -p "$TARGET_DIR"

# Navigate to the target directory
cd "$TARGET_DIR" || exit

mkdir -p wordpress
chmod -R 755 wordpress

# Create a docker-compose.yml for custom configuration
cat <<EOL > docker-compose.yml
services:
  # wp_db:
  #     # image: mysql:5.7
  #     image: mariadb
  #     container_name: ${DOMAIN}_wp_db
  #     command: "--default-authentication-plugin=mysql_native_password"
  #     volumes:
  #       - dbdata:/var/lib/mysql
  #     restart: unless-stopped
  #     environment:
  #       MYSQL_ROOT_PASSWORD: root
  #     networks:
  #       - network

  # phpmyadmin:
  #   image: phpmyadmin
  #   container_name: ${DOMAIN}_wp_pma
  #   depends_on:
  #     - wp_db
  #   restart: unless-stopped
  #   ports:
  #     - "${PMA_PORT}:80"
  #   environment:
  #     PMA_HOST: wp_db
  #     MYSQL_ROOT_PASSWORD: root
  #     UPLOAD_LIMIT: 300M
  #   networks:
  #     - network

  wordpress:
    image: wordpress:latest
    container_name: ${DOMAIN}_wp
    depends_on:
        - wp_db
    volumes:
      - ./wordpress:/var/www/html
      - ../../nginx-proxy-manager/php/php.ini:/usr/local/etc/php/conf.d/php.ini
    ports:
      - "${WP_PORT}:80"
    restart: unless-stopped
    environment:
      WORDPRESS_DB_HOST: wp_db:3306
      WORDPRESS_DB_NAME: ${DB_NAME}
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASSWORD}
    networks:
      - network

volumes:
  dbdata:

networks:
  network:
    name: wp_nginx_network
    external: true
EOL

# Start the Docker containers
docker-compose up -d

# Wait for MariaDB to initialize properly
until docker exec wp_db mariadb -u root -p$DB_ROOT_PASSWORD -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for MariaDB to start..."
    sleep 5
done


echo "Creating database and user for WordPress..."

# Create the database and user
docker exec wp_db mariadb -u root -p$DB_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
docker exec wp_db mariadb -u root -p$DB_ROOT_PASSWORD -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"
docker exec wp_db mariadb -u root -p$DB_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
docker exec wp_db mariadb -u root -p$DB_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

echo "Database and user for WordPress has been created."


# Create the Nginx configuration file
cd ../../nginx-proxy-manager

cat <<EOL > conf.d/${DOMAIN}.conf
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
# docker-compose exec certbot certbot certonly --webroot --webroot-path=/var/www/certbot -d ${DOMAIN} -d www.${DOMAIN} --email admin@lester1.com --agree-tos --no-eff-email

# Restart Nginx to apply changes
docker exec wp_nginx nginx -s reload

echo "WordPress setup is complete for ${DOMAIN}."

# Go back to the original directory
cd - || exit
