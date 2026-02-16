#!/bin/bash

echo "=========================================="
echo "  Web Stack Installer (Manual Control)"
echo "  PHP 7.2-8.4 | MySQL | Nginx | Composer"
echo "  PostgreSQL | MongoDB (local) | Redis"
echo "=========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Detect Ubuntu codename (Linux Mint uses its own codename, repos need Ubuntu's)
get_ubuntu_codename() {
    if grep -q UBUNTU_CODENAME /etc/os-release 2>/dev/null; then
        grep UBUNTU_CODENAME /etc/os-release | cut -d= -f2
    else
        lsb_release -cs
    fi
}
UBUNTU_CODENAME=$(get_ubuntu_codename)
echo -e "${CYAN}Detected Ubuntu codename: ${UBUNTU_CODENAME}${NC}"

# ==========================================
# [1/5] Dependencies
# ==========================================
echo -e "${YELLOW}[1/5] Installing dependencies...${NC}"
sudo apt update
sudo apt install -y software-properties-common apt-transport-https lsb-release ca-certificates curl wget gnupg2

# ==========================================
# [2/5] Repositories (PHP + Nginx + MySQL)
# ==========================================
echo -e "${YELLOW}[2/5] Adding repositories...${NC}"
sudo add-apt-repository ppa:ondrej/php -y

# MySQL repo
cd /tmp
wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb
sudo DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.29-1_all.deb
sudo apt update

# Nginx repo
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu ${UBUNTU_CODENAME} nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
sudo apt update

# ==========================================
# [3/5] PHP 7.2–8.4
# ==========================================
echo -e "${YELLOW}[3/5] Installing PHP 7.2 to 8.4...${NC}"
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

# ==========================================
# [4/5] Nginx + Composer
# ==========================================
echo -e "${YELLOW}[4/5] Installing Nginx & Composer...${NC}"

# Nginx
if command -v nginx &>/dev/null; then
    echo -e "  ${GREEN}✓ Nginx already installed, skipping.${NC}"
else
    sudo apt install -y nginx
    sudo systemctl stop nginx
    sudo systemctl disable nginx
    echo -e "  ${GREEN}✓ Nginx installed (stopped & disabled).${NC}"
fi

# Composer
if command -v composer &>/dev/null; then
    echo -e "  ${GREEN}✓ Composer already installed, skipping.${NC}"
else
    php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
    sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm /tmp/composer-setup.php
    echo -e "  ${GREEN}✓ Composer installed.${NC}"
fi

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
sudo chmod +x /usr/local/bin/db-setup

# ==========================================
# [5/5] Databases (MySQL, PostgreSQL, MongoDB, Redis, Compass)
# ==========================================
echo -e "${YELLOW}[5/5] Installing & configuring databases...${NC}"
db-setup install

# ==========================================
# Verify
# ==========================================
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
echo -n "  MySQL:       "; command -v mysql &>/dev/null && echo -e "${GREEN}✓${NC} $(which mysql)" || echo -e "${RED}✗ not found${NC}"
echo -n "  Nginx:       "; command -v nginx &>/dev/null && echo -e "${GREEN}✓${NC} $(which nginx)" || echo -e "${RED}✗ not found${NC}"
echo -n "  Composer:    "; command -v composer &>/dev/null && echo -e "${GREEN}✓${NC} $(which composer)" || echo -e "${RED}✗ not found${NC}"
echo -n "  PostgreSQL:  "; command -v psql &>/dev/null && echo -e "${GREEN}✓${NC} $(which psql)" || echo -e "${RED}✗ not found${NC}"
echo -n "  MongoDB:     "; command -v mongod &>/dev/null && echo -e "${GREEN}✓${NC} $(which mongod)" || echo -e "${RED}✗ not found${NC}"
echo -n "  Compass:     "; command -v mongodb-compass &>/dev/null && echo -e "${GREEN}✓${NC} $(which mongodb-compass)" || echo -e "${RED}✗ not found${NC}"
echo -n "  pgAdmin:     "; dpkg -l pgadmin4-desktop 2>/dev/null | grep -q '^ii' && echo -e "${GREEN}✓${NC} pgadmin4" || echo -e "${RED}✗ not found${NC}"
echo -n "  Redis:       "; command -v redis-server &>/dev/null && echo -e "${GREEN}✓${NC} $(which redis-server)" || echo -e "${RED}✗ not found${NC}"
echo ""
echo "Control Commands:"
echo "  web-ctl all start       # Start all services"
echo "  web-ctl all stop        # Stop all services"
echo "  web-ctl mysql start     # Start MySQL only"
echo "  web-ctl pg start        # Start PostgreSQL only"
echo "  web-ctl mongo start     # Start MongoDB only"
echo "  web-ctl redis start     # Start Redis only"
echo "  db-setup all            # Install + setup all DBs"
echo "  db-setup setup          # Re-setup all DB credentials"
echo "  php-switch 8.3          # Switch PHP version"
echo ""
echo "Manual Start/Stop:"
echo "  sudo systemctl start|stop mysql"
echo "  sudo systemctl start|stop nginx"
echo "  sudo systemctl start|stop php8.3-fpm"
echo "  sudo systemctl start|stop postgresql"
echo "  sudo systemctl start|stop mongod"
echo "  sudo systemctl start|stop redis-server"
echo ""
echo -e "${YELLOW}Note: No services auto-start on boot.${NC}"
echo -e "${YELLOW}All DB passwords set to '1' — run 'db-setup setup' to reconfigure.${NC}"
