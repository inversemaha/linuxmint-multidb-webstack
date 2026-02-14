#!/bin/bash

echo "=========================================="
echo "  Web Stack Installer (Manual Control)"
echo "  PHP 7.2-8.4 | MySQL | Nginx | Composer"
echo "=========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Dependencies
echo -e "${YELLOW}[1/6] Installing dependencies...${NC}"
sudo apt update
sudo apt install -y software-properties-common apt-transport-https lsb-release ca-certificates curl wget gnupg2

# Add Repositories
echo -e "${YELLOW}[2/6] Adding repositories...${NC}"
sudo add-apt-repository ppa:ondrej/php -y

# MySQL repo
cd /tmp
wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb
sudo DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.29-1_all.deb
sudo apt update

# Nginx repo (use Ubuntu codename, not Linux Mint codename)
UBUNTU_CODENAME=$(grep UBUNTU_CODENAME /etc/os-release 2>/dev/null | cut -d= -f2)
[ -z "$UBUNTU_CODENAME" ] && UBUNTU_CODENAME=$(lsb_release -cs)
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu $UBUNTU_CODENAME nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
sudo apt update

# Install PHP Versions
echo -e "${YELLOW}[3/6] Installing PHP 7.2 to 8.4...${NC}"
PHP_VERSIONS="7.2 7.3 7.4 8.0 8.1 8.2 8.3 8.4"
for version in $PHP_VERSIONS; do
    echo "Installing PHP $version..."
    sudo apt install -y \
        php${version}-fpm \
        php${version}-cli \
        php${version}-common \
        php${version}-mysql \
        php${version}-curl \
        php${version}-gd \
        php${version}-mbstring \
        php${version}-xml \
        php${version}-zip \
        php${version}-bcmath \
        php${version}-intl \
        php${version}-opcache \
        php${version}-readline \
        php${version}-imagick \
        php${version}-redis \
        php${version}-sqlite3 \
        php${version}-xdebug 2>/dev/null || echo "Some extensions skipped for $version"
done

# Install MySQL
echo -e "${YELLOW}[4/6] Installing MySQL...${NC}"
sudo apt install -y mysql-server
sudo systemctl stop mysql
sudo systemctl disable mysql

# Install Nginx
echo -e "${YELLOW}[5/6] Installing Nginx...${NC}"
sudo apt install -y nginx
sudo systemctl stop nginx
sudo systemctl disable nginx

# Install Composer
echo -e "${YELLOW}[6/6] Installing Composer...${NC}"
php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm /tmp/composer-setup.php

# Setup PHP alternatives
echo -e "${YELLOW}Setting up PHP alternatives...${NC}"
for version in $PHP_VERSIONS; do
    priority=${version//./}
    sudo update-alternatives --install /usr/bin/php php /usr/bin/php${version} $priority 2>/dev/null || true
done
sudo update-alternatives --set php /usr/bin/php8.3

# Copy scripts to system
echo -e "${YELLOW}Installing control scripts...${NC}"
sudo cp ~/web-stack/scripts/* /usr/local/bin/
sudo chmod +x /usr/local/bin/php-switch
sudo chmod +x /usr/local/bin/web-ctl
sudo chmod +x /usr/local/bin/nginx-laravel

# Verify
echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo "PHP Versions installed:"
for v in $PHP_VERSIONS; do
    if [ -f "/usr/bin/php$v" ]; then
        echo -e "  ${GREEN}✓${NC} PHP $v"
    fi
done
echo ""
echo "Services (Manual Control):"
echo "  MySQL:     $(which mysql)"
echo "  Nginx:     $(which nginx)"
echo "  Composer:  $(which composer)"
echo ""
echo "Control Commands:"
echo "  web-ctl all start       # Start all services"
echo "  web-ctl all stop        # Stop all services"
echo "  php-switch 8.3          # Switch PHP version"
echo ""
echo -e "${YELLOW}Note: No services auto-start on boot.${NC}"
