# Linux Mint PHP Development Setup: Switch PHP Versions 7.2-8.4, Nginx, MySQL, PostgreSQL, MongoDB, Redis — Manual Service Control

> Manual-control web development stack for Ubuntu — PHP 7.2–8.4, MySQL, Nginx, Composer, PostgreSQL, MongoDB, MongoDB Compass, and Redis.

## Installation

```bash
cd ~/web-stack
chmod +x install.sh
./install.sh
```

The installer will:
1. Install dependencies and add PHP/Nginx/MySQL repositories
2. Install **PHP 7.2–8.4** (FPM + CLI + common extensions)
3. Install **Nginx** and **Composer**
4. Copy helper scripts to `/usr/local/bin/`
5. Run `db-setup install` → installs & configures all databases

> **Skip-if-installed:** Each service is checked before installation. If it's already present, the installer skips it.

## Database Setup (`db-setup`)

The `db-setup` script handles **both installation and credential setup** for all databases. It is called automatically by `install.sh` but can be run independently anytime.

```bash
db-setup all            # Install + setup everything
db-setup install        # Install all databases only
db-setup setup          # Re-setup credentials for all databases
db-setup mysql          # Install + setup MySQL
db-setup pg             # Install + setup PostgreSQL + pgAdmin
db-setup mongo          # Install + setup MongoDB + Compass
db-setup redis          # Install + setup Redis
db-setup pgadmin        # Install pgAdmin 4 only
db-setup compass        # Install MongoDB Compass only
```

**Default credentials (password `1` for all):**

| Service | User | Password | Connect |
|---|---|---|---|
| MySQL | `root` | `1` | `mysql -u root -p` |
| PostgreSQL | `postgres` | `1` | `psql -U postgres -h localhost` |
| MongoDB | `admin` | `1` | `mongosh -u admin -p --authenticationDatabase admin` |
| Redis | — | — | `redis-cli` |

**MongoDB Compass** (GUI) is installed alongside MongoDB. Launch with `mongodb-compass`.

**pgAdmin 4** (GUI) is installed alongside PostgreSQL. Launch with `pgadmin4`.

To change the MySQL password later:

```sql
mysql -u root -p
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'your_password';
FLUSH PRIVILEGES;
```

## Commands

### Switch PHP Version

```bash
php-switch 8.3
php-switch 7.4
```

### Control Services (`web-ctl`)

| Command | Description |
|---|---|
| `web-ctl all start` | Start MySQL, Nginx, PHP-FPM, PostgreSQL, MongoDB, Redis |
| `web-ctl all stop` | Stop all services |
| `web-ctl all restart` | Restart all services |
| `web-ctl all status` | Show status of all services |
| `web-ctl mysql start` | Start MySQL only |
| `web-ctl mysql stop` | Stop MySQL only |
| `web-ctl nginx start` | Start Nginx only |
| `web-ctl nginx stop` | Stop Nginx only |
| `web-ctl nginx restart` | Restart Nginx only |
| `web-ctl nginx reload` | Reload Nginx config |
| `web-ctl nginx test` | Test Nginx config |
| `web-ctl php start` | Start PHP-FPM (current version) |
| `web-ctl php stop` | Stop PHP-FPM (current version) |
| `web-ctl php list` | List installed PHP versions |
| `web-ctl pg start` | Start PostgreSQL only |
| `web-ctl pg stop` | Stop PostgreSQL only |
| `web-ctl mongo start` | Start MongoDB only |
| `web-ctl mongo stop` | Stop MongoDB only |
| `web-ctl redis start` | Start Redis only |
| `web-ctl redis stop` | Stop Redis only |

Available services: `mysql`, `nginx`, `php`, `pg` (PostgreSQL), `mongo` (MongoDB), `redis`, `all`.

Available actions: `start`, `stop`, `restart`, `status`, `enable`, `disable` (plus `reload` and `test` for Nginx).

### Create an Nginx Site (Laravel)

```bash
nginx-laravel myapp.local 8.3 /var/www/myapp/public
```

Then add the domain to your hosts file:

```bash
sudo nano /etc/hosts
# 127.0.0.1 myapp.local
```

## Manual Start/Stop for Each Service

All services are installed **stopped and disabled** (no auto-start on boot). Use `web-ctl` or `systemctl` directly:

### MySQL

```bash
web-ctl mysql start       # or: sudo systemctl start mysql
web-ctl mysql stop        # or: sudo systemctl stop mysql
web-ctl mysql status
mysql -u root -p          # Connect (password: 1)
```

### Nginx

```bash
web-ctl nginx start       # or: sudo systemctl start nginx
web-ctl nginx stop        # or: sudo systemctl stop nginx
web-ctl nginx restart
web-ctl nginx reload      # Reload config without restart
web-ctl nginx test        # Test config syntax
```

### PHP-FPM

```bash
web-ctl php start         # or: sudo systemctl start php8.3-fpm
web-ctl php stop          # or: sudo systemctl stop php8.3-fpm
web-ctl php status
web-ctl php list          # List installed PHP versions
```

### PostgreSQL

```bash
web-ctl pg start          # or: sudo systemctl start postgresql
web-ctl pg stop           # or: sudo systemctl stop postgresql
web-ctl pg status
sudo -u postgres psql     # Connect to PostgreSQL shell
pgadmin4                  # Launch GUI
```

### MongoDB (Local)

```bash
web-ctl mongo start       # or: sudo systemctl start mongod
web-ctl mongo stop        # or: sudo systemctl stop mongod
web-ctl mongo status
mongosh                   # Connect (no auth)
mongosh -u admin -p --authenticationDatabase admin  # With auth
mongodb-compass           # Launch GUI
```

### Redis

```bash
web-ctl redis start       # or: sudo systemctl start redis-server
web-ctl redis stop        # or: sudo systemctl stop redis-server
web-ctl redis status
redis-cli                 # Connect
```

## Example Workflow

```bash
# 1. Start services
web-ctl all start

# 2. Switch to PHP 8.3
php-switch 8.3

# 3. Create a Laravel site
nginx-laravel blog.local 8.3 ~/Projects/blog/public

# 4. Add domain to /etc/hosts
sudo nano /etc/hosts
# 127.0.0.1 blog.local

# 5. Restart Nginx
web-ctl nginx restart

# 6. Done — open http://blog.local
```

## File Locations

| Path | Description |
|---|---|
| `/etc/nginx/sites-available/` | Nginx site configs |
| `/etc/php/{version}/fpm/` | PHP-FPM configs |
| `/var/lib/mysql/` | MySQL data |
| `/var/lib/postgresql/` | PostgreSQL data |
| `/var/lib/mongodb/` | MongoDB data |
| `/etc/mongod.conf` | MongoDB config |
| `/etc/redis/redis.conf` | Redis config |
| `/var/lib/redis/` | Redis data |
| `/var/log/nginx/` | Nginx logs |
| `/var/log/postgresql/` | PostgreSQL logs |
| `/var/log/mongodb/` | MongoDB logs |
| `/var/log/redis/` | Redis logs |
| `/var/log/php*-fpm.log` | PHP-FPM logs |

## Post-Install Quick Start

```bash
web-ctl all start                                        # Start all services
php-switch 8.3                                           # Use PHP 8.3
nginx-laravel app.local 8.3 ~/Projects/myapp/public      # Create site
sudo mysql                                               # MySQL root (auth_socket, no password)
sudo -u postgres psql                                    # PostgreSQL shell
redis-cli                                                # Redis shell
```

## License

This project is provided as-is for local development use.
