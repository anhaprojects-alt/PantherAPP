<?php

namespace Tests\Feature;

use Tests\TestCase;

class IntroPageTest extends TestCase
{
    public function test_the_intro_page_renders_the_panther_branding(): void
    {
        $response = $this->get('/');

        $response->assertOk()
            ->assertSee('assets/panther.css', false)
            ->assertSee('assets/panther-wordmark.png', false)
            ->assertSee('assets/panther-badge.png', false)
            ->assertSee('Komunitas Panther dalam satu aplikasi')
            ->assertSee(route('admin.login'), false);
    }

    public function test_the_stock_laravel_page_is_gone(): void
    {
        $response = $this->get('/');

        $response->assertOk()
            ->assertDontSee("Let's get started")
            ->assertDontSee('Laracasts')
            ->assertDontSee('Deploy now')
            ->assertDontSee('@fonts');
    }
}
