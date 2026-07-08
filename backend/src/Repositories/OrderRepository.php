<?php

declare(strict_types=1);

namespace App\Repositories;

use PDO;

class OrderRepository
{
    public function __construct(private readonly PDO $db)
    {
    }

    public function create(int $userId, int $vendorId, float $total, string $pickupAt): int
    {
        $stmt = $this->db->prepare(
            'INSERT INTO orders (user_id, vendor_id, status, total, pickup_at)
             VALUES (:user_id, :vendor_id, 'placed', :total, :pickup_at)'
        );

        $stmt->execute([
            'user_id' => $userId,
            'vendor_id' => $vendorId,
            'total' => $total,
            'pickup_at' => $pickupAt,
        ]);

        return (int) $this->db->lastInsertId();
    }

    public function findById(int $id): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM orders WHERE id = :id LIMIT 1');
        $stmt->execute(['id' => $id]);

        $order = $stmt->fetch();

        return $order === false ? null : $order;
    }

    public function listForCustomer(int $userId, ?string $status, ?string $date): array
    {
        $sql = 'SELECT * FROM orders WHERE user_id = :user_id';
        $params = ['user_id' => $userId];

        if ($status !== null) {
            $sql .= ' AND status = :status';
            $params['status'] = $status;
        }

        if ($date !== null) {
            $sql .= ' AND DATE(created_at) = :date';
            $params['date'] = $date;
        }

        $sql .= ' ORDER BY created_at DESC';

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    }

    /** @param int[] $vendorIds */
    public function listForVendors(array $vendorIds, ?string $status, ?string $date): array
    {
        if ($vendorIds === []) {
            return [];
        }

        $placeholders = implode(',', array_fill(0, count($vendorIds), '?'));
        $sql = "SELECT * FROM orders WHERE vendor_id IN ({$placeholders})";
        $params = $vendorIds;

        if ($status !== null) {
            $sql .= ' AND status = ?';
            $params[] = $status;
        }

        if ($date !== null) {
            $sql .= ' AND DATE(created_at) = ?';
            $params[] = $date;
        }

        $sql .= ' ORDER BY created_at DESC';

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    }

    public function listAll(?string $status, ?string $date): array
    {
        $sql = 'SELECT * FROM orders WHERE 1 = 1';
        $params = [];

        if ($status !== null) {
            $sql .= ' AND status = :status';
            $params['status'] = $status;
        }

        if ($date !== null) {
            $sql .= ' AND DATE(created_at) = :date';
            $params['date'] = $date;
        }

        $sql .= ' ORDER BY created_at DESC';

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    }

    public function updateStatus(int $id, string $status): void
    {
        $stmt = $this->db->prepare('UPDATE orders SET status = :status WHERE id = :id');
        $stmt->execute(['status' => $status, 'id' => $id]);
    }
}
