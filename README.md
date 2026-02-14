# Linux Mint PHP Development Setup: Switch PHP Versions 7.2-8.4, Nginx, MySQL, Manual Service Control

> Manual-control web development stack for Ubuntu — PHP 7.2–8.4, MySQL, Nginx, and Composer.

## Installation

```bash
cd ~/web-stack
chmod +x install.sh
./install.sh
```

The installer will:
1. Add the Ondřej PHP and Nginx mainline repositories
2. Install **PHP 7.2–8.4** (FPM + CLI + common extensions)
3. Install **MySQL** (stopped & disabled by default)
4. Install **Nginx** (stopped & disabled by default)
5. Install **Composer**
6. Copy the helper scripts to `/usr/local/bin/`

## Commands

### Switch PHP Version

```bash
php-switch 8.3
php-switch 7.4
```

### Control Services (`web-ctl`)

| Command | Description |
|---|---|
| `web-ctl all start` | Start MySQL, Nginx, and PHP-FPM |
| `web-ctl all stop` | Stop all services |
| `web-ctl all restart` | Restart all services |
| `web-ctl all status` | Show status of all services |
| `web-ctl mysql start` | Start MySQL only |
| `web-ctl nginx restart` | Restart Nginx only |
| `web-ctl php start` | Start PHP-FPM (current version) |
| `web-ctl php list` | List installed PHP versions |

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
| `/var/log/nginx/` | Nginx logs |
| `/var/log/php*-fpm.log` | PHP-FPM logs |

## Post-Install Quick Start

```bash
web-ctl all start                                        # Start MySQL, Nginx, PHP-FPM
php-switch 8.3                                           # Use PHP 8.3
nginx-laravel app.local 8.3 ~/Projects/myapp/public      # Create site
```

## License

This project is provided as-is for local development use.
