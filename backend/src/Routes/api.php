<?php

declare(strict_types=1);

use App\Controllers\AdminController;
use App\Controllers\AuthController;
use App\Controllers\MenuItemController;
use App\Controllers\OrderController;
use App\Controllers\ReviewController;
use App\Controllers\VendorController;
use App\Middleware\JwtAuthMiddleware;
use App\Middleware\RoleMiddleware;
use Psr\Http\Message\ResponseFactoryInterface;
use Slim\App;

return function (App $app): void {
    $responseFactory = $app->getContainer()->get(ResponseFactoryInterface::class);

    // Route middleware executes in the order the LAST ->add() call runs FIRST,
    // so JwtAuthMiddleware (populates user_id/user_role) must be added after
    // RoleMiddleware (which reads those attributes) for each protected route.
    $role = static fn (array $roles) => new RoleMiddleware($roles, $responseFactory);

    $app->group('/api/auth', function ($group) {
        $group->post('/register', [AuthController::class, 'register']);
        $group->post('/login', [AuthController::class, 'login']);

        $group->get('/me', [AuthController::class, 'me'])
            ->add(JwtAuthMiddleware::class);
    });

    // Vendors
    $app->get('/api/vendors', [VendorController::class, 'index']);
    $app->get('/api/vendors/mine', [VendorController::class, 'mine'])
        ->add($role(['vendor']))
        ->add(JwtAuthMiddleware::class);
    $app->get('/api/vendors/{id}', [VendorController::class, 'show']);
    $app->post('/api/vendors', [VendorController::class, 'create'])
        ->add($role(['vendor']))
        ->add(JwtAuthMiddleware::class);
    $app->put('/api/vendors/{id}', [VendorController::class, 'update'])
        ->add($role(['vendor', 'admin']))
        ->add(JwtAuthMiddleware::class);
    $app->delete('/api/vendors/{id}', [VendorController::class, 'delete'])
        ->add($role(['admin']))
        ->add(JwtAuthMiddleware::class);

    // Menu items
    $app->get('/api/vendors/{id}/menu-items', [MenuItemController::class, 'byVendor']);
    $app->post('/api/vendors/{id}/menu-items', [MenuItemController::class, 'create'])
        ->add($role(['vendor']))
        ->add(JwtAuthMiddleware::class);
    $app->put('/api/menu-items/{id}', [MenuItemController::class, 'update'])
        ->add($role(['vendor', 'admin']))
        ->add(JwtAuthMiddleware::class);
    $app->delete('/api/menu-items/{id}', [MenuItemController::class, 'delete'])
        ->add($role(['vendor', 'admin']))
        ->add(JwtAuthMiddleware::class);

    // Orders
    $app->post('/api/orders', [OrderController::class, 'create'])
        ->add($role(['customer']))
        ->add(JwtAuthMiddleware::class);
    $app->get('/api/orders', [OrderController::class, 'index'])
        ->add(JwtAuthMiddleware::class);
    $app->get('/api/orders/{id}', [OrderController::class, 'show'])
        ->add(JwtAuthMiddleware::class);
    $app->patch('/api/orders/{id}/status', [OrderController::class, 'updateStatus'])
        ->add($role(['vendor', 'admin']))
        ->add(JwtAuthMiddleware::class);
    $app->patch('/api/orders/{id}/cancel', [OrderController::class, 'cancel'])
        ->add($role(['customer']))
        ->add(JwtAuthMiddleware::class);

    // Reviews
    $app->get('/api/vendors/{id}/reviews', [ReviewController::class, 'index']);
    $app->post('/api/vendors/{id}/reviews', [ReviewController::class, 'create'])
        ->add($role(['customer']))
        ->add(JwtAuthMiddleware::class);

    // Admin
    $app->get('/api/admin/vendors', [AdminController::class, 'allVendors'])
        ->add($role(['admin']))
        ->add(JwtAuthMiddleware::class);
    $app->get('/api/admin/vendors/pending', [AdminController::class, 'pendingVendors'])
        ->add($role(['admin']))
        ->add(JwtAuthMiddleware::class);
    $app->patch('/api/admin/vendors/{id}/approve', [AdminController::class, 'approveVendor'])
        ->add($role(['admin']))
        ->add(JwtAuthMiddleware::class);
    $app->patch('/api/admin/vendors/{id}/suspend', [AdminController::class, 'suspendVendor'])
        ->add($role(['admin']))
        ->add(JwtAuthMiddleware::class);
    $app->get('/api/admin/analytics/summary', [AdminController::class, 'analyticsSummary'])
        ->add($role(['admin']))
        ->add(JwtAuthMiddleware::class);
};
