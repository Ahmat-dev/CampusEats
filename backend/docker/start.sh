#!/bin/bash
set -e

PORT="${PORT:-80}"

sed -ri "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -ri "s/:80>/:${PORT}>/" /etc/apache2/sites-available/000-default.conf

php bin/migrate.php --seed

exec apache2-foreground
