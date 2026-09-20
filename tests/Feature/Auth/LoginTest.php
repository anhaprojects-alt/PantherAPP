<?php

namespace Tests\Feature\Auth;

use App\Enums\MemberStatus;
use App\Models\Member;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LoginTest extends TestCase
{
    use RefreshDatabase;

    public function test_an_approved_member_receives_a_token(): void
    {
        $member = Member::factory()->approved()->create();

        $response = $this->postJson('/api/auth/login', $this->credentials($member->user->email));

        $response->assertOk()
            ->assertJsonStructure([
                'token',
                'user' => ['id', 'name', 'email', 'is_admin', 'member' => ['id', 'status', 'status_label']],
            ])
            ->assertJsonPath('user.member.status', MemberStatus::Approved->value);

        $this->assertSame('android', $member->user->tokens()->first()->name);
    }

    public function test_a_pending_applicant_cannot_sign_in(): void
    {
        $member = Member::factory()->create();

        $this->postJson('/api/auth/login', $this->credentials($member->user->email))
            ->assertForbidden()
            ->assertJsonPath('status', MemberStatus::Pending->value)
            ->assertJsonPath('message', 'Pendaftaran Anda masih menunggu persetujuan admin.');
    }

    public function test_a_rejected_applicant_sees_the_rejection_reason(): void
    {
        $member = Member::factory()->rejected('Foto KTP tidak terbaca.')->create();

        $this->postJson('/api/auth/login', $this->credentials($member->user->email))
            ->assertForbidden()
            ->assertJsonPath('status', MemberStatus::Rejected->value)
            ->assertJsonPath('reason', 'Foto KTP tidak terbaca.');
    }

    public function test_a_user_without_a_member_record_cannot_sign_in(): void
    {
        $user = User::factory()->create();

        $this->postJson('/api/auth/login', $this->credentials($user->email))
            ->assertForbidden()
            ->assertJsonPath('message', 'Akun Anda belum terdaftar sebagai member.');
    }

    public function test_an_administrator_without_a_member_record_can_sign_in(): void
    {
        $admin = User::factory()->admin()->create();

        $this->postJson('/api/auth/login', $this->credentials($admin->email))
            ->assertOk()
            ->assertJsonPath('user.is_admin', true);
    }

    public function test_invalid_credentials_are_rejected(): void
    {
        $member = Member::factory()->approved()->create();

        $this->postJson('/api/auth/login', $this->credentials($member->user->email, 'salah-sekali'))
            ->assertUnprocessable()
            ->assertJsonValidationErrors('email');
    }

    public function test_login_is_rate_limited_per_email_address(): void
    {
        $member = Member::factory()->approved()->create();

        for ($attempt = 1; $attempt <= 5; $attempt++) {
            $this->postJson('/api/auth/login', $this->credentials($member->user->email, 'salah-sekali'))
                ->assertUnprocessable();
        }

        $this->postJson('/api/auth/login', $this->credentials($member->user->email))
            ->assertTooManyRequests();
    }

    /**
     * @return array<string, string>
     */
    private function credentials(string $email, string $password = 'password'): array
    {
        return ['email' => $email, 'password' => $password];
    }
}
