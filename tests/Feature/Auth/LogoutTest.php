<?php

namespace Tests\Feature\Auth;

use App\Models\Member;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class LogoutTest extends TestCase
{
    use RefreshDatabase;

    public function test_logging_out_revokes_the_token_that_was_used(): void
    {
        $member = Member::factory()->approved()->create();

        $token = $this->postJson('/api/auth/login', [
            'email' => $member->user->email,
            'password' => 'password',
        ])->json('token');

        $this->assertDatabaseCount('personal_access_tokens', 1);

        $this->withToken($token)
            ->postJson('/api/auth/logout')
            ->assertOk()
            ->assertJsonPath('message', 'Berhasil keluar.');

        $this->assertDatabaseCount('personal_access_tokens', 0);

        // The sanctum guard memoises the resolved user for the lifetime of the
        // test application, so it has to be reset before re-using the token.
        Auth::forgetGuards();

        $this->withToken($token)->getJson('/api/me')->assertUnauthorized();
    }

    public function test_logging_out_keeps_tokens_of_other_devices(): void
    {
        $member = Member::factory()->approved()->create();

        $first = $member->user->createToken('android')->plainTextToken;
        $second = $member->user->createToken('android')->plainTextToken;

        $this->withToken($first)->postJson('/api/auth/logout')->assertOk();

        $this->assertDatabaseCount('personal_access_tokens', 1);
        $this->withToken($second)->getJson('/api/me')->assertOk();
    }
}
