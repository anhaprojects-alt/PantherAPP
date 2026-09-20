<?php

namespace Tests\Feature\Admin;

use App\Models\Member;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class AdminLoginTest extends TestCase
{
    use RefreshDatabase;

    public function test_guests_see_the_sign_in_form(): void
    {
        $this->get('/admin/login')
            ->assertOk()
            ->assertSee('Masuk Admin')
            ->assertSee(route('admin.login.store'), false);
    }

    public function test_guests_are_redirected_to_the_sign_in_form(): void
    {
        $this->get('/admin')->assertRedirect(route('admin.login'));
    }

    public function test_an_administrator_can_sign_in(): void
    {
        $admin = User::factory()->admin()->create(['password' => 'rahasia-sekali']);

        $this->post('/admin/login', ['email' => $admin->email, 'password' => 'rahasia-sekali'])
            ->assertRedirect(route('admin.dashboard'));

        $this->assertAuthenticatedAs($admin);
    }

    public function test_the_email_is_matched_case_insensitively(): void
    {
        $admin = User::factory()->admin()->create([
            'email' => 'admin@panther.test',
            'password' => 'rahasia-sekali',
        ]);

        $this->post('/admin/login', ['email' => '  ADMIN@Panther.test  ', 'password' => 'rahasia-sekali'])
            ->assertRedirect(route('admin.dashboard'));

        $this->assertAuthenticatedAs($admin);
    }

    public function test_a_member_without_admin_rights_cannot_sign_in(): void
    {
        $member = User::factory()->member()->create(['password' => 'rahasia-sekali']);

        $this->post('/admin/login', ['email' => $member->email, 'password' => 'rahasia-sekali'])
            ->assertSessionHasErrors('email');

        $this->assertGuest();
    }

    public function test_a_wrong_password_is_rejected(): void
    {
        $admin = User::factory()->admin()->create(['password' => 'rahasia-sekali']);

        $this->post('/admin/login', ['email' => $admin->email, 'password' => 'salah'])
            ->assertSessionHasErrors('email');

        $this->assertGuest();
    }

    public function test_the_form_does_not_reveal_whether_an_account_exists(): void
    {
        User::factory()->admin()->create([
            'email' => 'admin@panther.test',
            'password' => 'rahasia-sekali',
        ]);

        $this->post('/admin/login', ['email' => 'admin@panther.test', 'password' => 'salah'])
            ->assertSessionHasErrors(['email' => 'Email atau password salah.']);

        $this->post('/admin/login', ['email' => 'tidak-ada@panther.test', 'password' => 'salah'])
            ->assertSessionHasErrors(['email' => 'Email atau password salah.']);
    }

    public function test_an_authenticated_administrator_is_sent_to_the_panel(): void
    {
        $this->actingAs(User::factory()->admin()->create())
            ->get('/admin/login')
            ->assertRedirect(route('admin.dashboard'));
    }

    public function test_an_administrator_can_sign_out(): void
    {
        $this->actingAs(User::factory()->admin()->create())
            ->post('/admin/logout')
            ->assertRedirect(route('admin.login'));

        $this->assertGuest();
    }

    public function test_an_administrator_sees_the_panel_with_the_pending_count(): void
    {
        Member::factory()->create();
        Member::factory()->approved()->create();

        $this->actingAs(User::factory()->admin()->create())
            ->get('/admin')
            ->assertOk()
            ->assertSee('Menunggu review')
            ->assertViewHas('counts', fn (array $counts): bool => $counts['pending'] === 1);
    }

    public function test_a_signed_in_member_cannot_open_the_panel(): void
    {
        $this->actingAs(User::factory()->member()->create())
            ->get('/admin')
            ->assertForbidden();
    }

    public function test_repeated_failures_are_rate_limited(): void
    {
        $admin = User::factory()->admin()->create(['password' => 'rahasia-sekali']);

        for ($attempt = 0; $attempt < 6; $attempt++) {
            $this->post('/admin/login', ['email' => $admin->email, 'password' => 'salah'])
                ->assertSessionHasErrors('email');
        }

        $this->post('/admin/login', ['email' => $admin->email, 'password' => 'salah'])
            ->assertStatus(429);
    }

    /**
     * Production runs the database session driver while the suite runs on the array
     * driver, so without this test the real session path would never be exercised.
     */
    public function test_the_panel_works_on_the_database_session_driver(): void
    {
        config()->set('session.driver', 'database');
        app('session')->forgetDrivers();

        $admin = User::factory()->admin()->create(['password' => 'rahasia-sekali']);

        $this->get('/admin/login')->assertOk();

        $this->post('/admin/login', ['email' => $admin->email, 'password' => 'rahasia-sekali'])
            ->assertRedirect(route('admin.dashboard'));

        $this->assertAuthenticatedAs($admin);
        $this->assertGreaterThanOrEqual(1, DB::table('sessions')->count());

        $this->get('/admin')->assertOk();
    }
}
