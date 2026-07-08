<?php

declare(strict_types=1);

namespace App\Repositories;

use PDO;

class ReviewRepository
{
    public function __construct(private readonly PDO $db)
    {
    }

    public function listByVendor(int $vendorId): array
    {
        $stmt = $this->db->prepare(
            'SELECT r.id, r.rating, r.comment, r.created_at, u.name AS user_name
             FROM reviews r
             JOIN users u ON u.id = r.user_id
             WHERE r.vendor_id = :vendor_id
             ORDER BY r.created_at DESC'
        );
        $stmt->execute(['vendor_id' => $vendorId]);

        return $stmt->fetchAll();
    }

    public function create(int $userId, int $vendorId, int $rating, ?string $comment): int
    {
        $stmt = $this->db->prepare(
            'INSERT INTO reviews (user_id, vendor_id, rating, comment) VALUES (:user_id, :vendor_id, :rating, :comment)'
        );

        $stmt->execute([
            'user_id' => $userId,
            'vendor_id' => $vendorId,
            'rating' => $rating,
            'comment' => $comment,
        ]);

        return (int) $this->db->lastInsertId();
    }

    public function hasCollectedOrder(int $userId, int $vendorId): bool
    {
        $stmt = $this->db->prepare(
            "SELECT 1 FROM orders WHERE user_id = :user_id AND vendor_id = :vendor_id AND status = 'collected' LIMIT 1"
        );
        $stmt->execute(['user_id' => $userId, 'vendor_id' => $vendorId]);

        return $stmt->fetch() !== false;
    }
}
