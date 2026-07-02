<?php
/**
 * Database.php
 * Team Apex | CampusEats PR3
 * Author: Muaz Ibne Ahmed - Database Administrator & Security Lead
 *
 * Single shared PDO connection, configured defensively:
 *  - ERRMODE_EXCEPTION so failures surface instead of failing silently
 *  - Emulated prepares OFF so MySQL performs *real* prepared statements
 *    (this is what actually prevents SQL injection at the protocol level)
 */

declare(strict_types=1);

namespace App;

use PDO;
use PDOException;

class Database
{
    private static ?PDO $instance = null;

    public static function connect(): PDO
    {
        if (self::$instance === null) {
            $host = getenv('DB_HOST') ?: '127.0.0.1';
            $db   = getenv('DB_NAME') ?: 'campuseats';
            $user = getenv('DB_USER') ?: 'campuseats_app';
            $pass = getenv('DB_PASS') ?: '';
            $charset = 'utf8mb4';

            $dsn = "mysql:host={$host};dbname={$db};charset={$charset}";

            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false, // real prepared statements
            ];

            try {
                self::$instance = new PDO($dsn, $user, $pass, $options);
            } catch (PDOException $e) {
                // Never leak DSN/credentials or raw driver error to the client
                error_log('DB connection failed: ' . $e->getMessage());
                throw new PDOException('Database connection failed.');
            }
        }

        return self::$instance;
    }
}
