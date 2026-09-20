<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Route;
use Tests\TestCase;

class RoutingTest extends TestCase
{
    /**
     * Duplicate route names shadow each other silently: route() returns the one
     * registered last, so a new route can quietly hijack an existing URL.
     */
    public function test_route_names_are_unique(): void
    {
        $duplicates = collect(Route::getRoutes()->getRoutes())
            ->map(fn ($route) => $route->getName())
            ->filter()
            ->duplicates()
            ->values();

        $this->assertTrue(
            $duplicates->isEmpty(),
            'Duplicate route names: '.$duplicates->implode(', ')
        );
    }

    public function test_the_api_and_the_web_panel_do_not_share_urls(): void
    {
        $this->assertSame(url('/api/admin/members/1'), route('api.admin.members.show', ['member' => 1]));
        $this->assertSame(url('/admin/members/1'), route('admin.members.show', ['member' => 1]));
    }
}
