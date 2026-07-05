<?php

declare(strict_types=1);

namespace App\Middleware;

use Psr\Http\Message\ResponseFactoryInterface;
use Psr\Http\Message\ResponseInterface as PsrResponse;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface as Handler;

class CorsMiddleware implements MiddlewareInterface
{
    public function __construct(
        private readonly string $allowedOrigin,
        private readonly ResponseFactoryInterface $responseFactory
    ) {
    }

    public function process(Request $request, Handler $handler): PsrResponse
    {
        // Preflight requests never reach routing/auth middleware - answered here directly.
        $response = $request->getMethod() === 'OPTIONS'
            ? $this->responseFactory->createResponse()
            : $handler->handle($request);

        // Support a comma-separated list of allowed origins (e.g. Vercel URL +
        // capacitor://localhost for Android builds). Echo back the matching origin
        // so the browser accepts the response; fall back to the first entry when
        // there is no Origin header (e.g. plain curl / server-to-server calls).
        $allowedOrigins = array_map('trim', explode(',', $this->allowedOrigin));
        $requestOrigin  = $request->getHeaderLine('Origin');
        $origin = in_array($requestOrigin, $allowedOrigins, true)
            ? $requestOrigin
            : $allowedOrigins[0];

        return $response
            ->withHeader('Access-Control-Allow-Origin', $origin)
            ->withHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
    }
}
