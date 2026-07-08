<?php

declare(strict_types=1);

namespace App\Repositories;

use PDO;

class VendorRepository
{
    public function __construct(private readonly PDO $db)
    {
    }

    /** Public listing: approved + active vendors only, with computed rating. */
    public function listApproved(?string $search = null): array
    {
        $sql = 'SELECT v.id, v.name, v.location, v.opening_hours, v.image_url, v.prep_time_mins,
                       v.is_active, v.status,
                       ROUND(AVG(r.rating), 1) AS rating,
                       COUNT(r.id) AS review_count
                FROM vendors v
                LEFT JOIN reviews r ON r.vendor_id = v.id
                WHERE v.status = 'approved' AND v.is_active = 1';

        $params = [];

        if ($search !== null && $search !== '') {
            $sql .= ' AND v.name LIKE :search';
            $params['search'] = '%' . $search . '%';
        }

        $sql .= ' GROUP BY v.id ORDER BY v.name ASC';

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    }

    public function findApprovedById(int $id): ?array
    {
        $stmt = $this->db->prepare(
            'SELECT v.id, v.name, v.location, v.opening_hours, v.image_url, v.prep_time_mins,
                    v.is_active, v.status,
                    ROUND(AVG(r.rating), 1) AS rating,
                    COUNT(r.id) AS review_count
             FROM vendors v
             LEFT JOIN reviews r ON r.vendor_id = v.id
             WHERE v.id = :id AND v.status = 'approved' AND v.is_active = 1
             GROUP BY v.id'
        );
        $stmt->execute(['id' => $id]);

        $vendor = $stmt->fetch();

        return $vendor === false ? null : $vendor;
    }

    /** Any status - used for ownership checks and vendor/admin management. */
    public function findById(int $id): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM vendors WHERE id = :id LIMIT 1');
        $stmt->execute(['id' => $id]);

        $vendor = $stmt->fetch();

        return $vendor === false ? null : $vendor;
    }

    public function findByOwner(int $ownerId): array
    {
        $stmt = $this->db->prepare('SELECT * FROM vendors WHERE owner_id = :owner_id');
        $stmt->execute(['owner_id' => $ownerId]);

        return $stmt->fetchAll();
    }

    public function findPending(): array
    {
        $stmt = $this->db->query("SELECT * FROM vendors WHERE status = 'pending' ORDER BY created_at ASC");

        return $stmt->fetchAll();
    }

    public function create(
        int $ownerId,
        string $name,
        string $location,
        ?string $openingHours,
        ?string $imageUrl,
        ?int $prepTimeMins
    ): int {
        $stmt = $this->db->prepare(
            'INSERT INTO vendors (owner_id, name, location, opening_hours, image_url, prep_time_mins, is_active, status)
             VALUES (:owner_id, :name, :location, :opening_hours, :image_url, :prep_time_mins, 1, 'pending')'
        );

        $stmt->execute([
            'owner_id' => $ownerId,
            'name' => $name,
            'location' => $location,
            'opening_hours' => $openingHours,
            'image_url' => $imageUrl,
            'prep_time_mins' => $prepTimeMins,
        ]);

        return (int) $this->db->lastInsertId();
    }

    public function update(int $id, array $fields): void
    {
        if ($fields === []) {
            return;
        }

        $set = implode(', ', array_map(static fn (string $col) => "{$col} = :{$col}", array_keys($fields)));

        $stmt = $this->db->prepare("UPDATE vendors SET {$set} WHERE id = :id");
        $stmt->execute([...$fields, 'id' => $id]);
    }

    public function delete(int $id): void
    {
        $stmt = $this->db->prepare('DELETE FROM vendors WHERE id = :id');
        $stmt->execute(['id' => $id]);
    }

    public function updateStatus(int $id, string $status): void
    {
        $stmt = $this->db->prepare('UPDATE vendors SET status = :status WHERE id = :id');
        $stmt->execute(['status' => $status, 'id' => $id]);
    }
}
