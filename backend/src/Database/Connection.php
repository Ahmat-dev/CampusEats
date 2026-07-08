<?php

declare(strict_types=1);

namespace App\Database;

use PDO;

class Connection
{
    private static ?PDO $instance = null;

    public static function get(array $settings): PDO
    {
        if (self::$instance === null) {
            $db = $settings['db'];
            $dsn = sprintf(
                'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
                $db['host'],
                $db['port'],
                $db['name']
            );

            self::$instance = new PDO($dsn, $db['user'], $db['pass'], [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false,
                PDO::MYSQL_ATTR_SSL_CA       => true,
            ]);
        }

        return self::$instance;
    }
}
