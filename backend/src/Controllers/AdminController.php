<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\VendorRepository;
use App\Support\Response;
use PDO;
use Psr\Http\Message\ResponseInterface as PsrResponse;
use Psr\Http\Message\ServerRequestInterface as Request;
use Respect\Validation\Exceptions\NestedValidationException;
use Respect\Validation\Validator as v;

class AdminController
{
    public function __construct(
        private readonly VendorRepository $vendors,
        private readonly PDO $db
    ) {
    }

    public function pendingVendors(Request $request, PsrResponse $response): PsrResponse
    {
        $vendors = array_map(static fn (array $v) => [
            'id' => (int) $v['id'],
            'owner_id' => (int) $v['owner_id'],
            'name' => $v['name'],
            'location' => $v['location'],
            'created_at' => $v['created_at'],
        ], $this->vendors->findPending());

        return Response::ok($response, $vendors);
    }

    public function approveVendor(Request $request, PsrResponse $response, array $args): PsrResponse
    {
        $vendor = $this->vendors->findById((int) $args['id']);

        if ($vendor === null) {
            return Response::error($response, 'Vendor not found.', 404);
        }

        $body = (array) $request->getParsedBody();

        try {
            v::key('status', v::in(['approved', 'rejected']))->assert($body);
        } catch (NestedValidationException $e) {
            return Response::error($response, 'Validation failed.', 422, $e->getMessages());
        }

        $this->vendors->updateStatus((int) $args['id'], $body['status']);

        return Response::ok($response, ['id' => (int) $args['id'], 'status' => $body['status']]);
    }

    public function analyticsSummary(Request $request, PsrResponse $response): PsrResponse
    {
        $stmt = $this->db->query(
            "SELECT v.id AS vendor_id, v.name AS vendor_name,
                    COUNT(o.id) AS order_count,
                    COALESCE(SUM(CASE WHEN o.status = 'collected' THEN o.total ELSE 0 END), 0) AS revenue
             FROM vendors v
             LEFT JOIN orders o ON o.vendor_id = v.id
             GROUP BY v.id
             ORDER BY revenue DESC"
        );

        $perVendor = array_map(static fn (array $row) => [
            'vendor_id' => (int) $row['vendor_id'],
            'vendor_name' => $row['vendor_name'],
            'order_count' => (int) $row['order_count'],
            'revenue' => (float) $row['revenue'],
        ], $stmt->fetchAll());

        return Response::ok($response, [
            'total_orders' => array_sum(array_column($perVendor, 'order_count')),
            'total_revenue' => array_sum(array_column($perVendor, 'revenue')),
            'by_vendor' => $perVendor,
        ]);
    }
}
