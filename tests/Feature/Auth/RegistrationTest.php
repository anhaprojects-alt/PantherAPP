<?php

namespace Tests\Feature\Auth;

use App\Enums\MemberStatus;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class RegistrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_an_applicant_can_register_with_identity_documents(): void
    {
        Storage::fake('private');

        $response = $this->postJson('/api/auth/register', $this->application());

        $response->assertCreated()
            ->assertJsonPath('status', MemberStatus::Pending->value);

        $user = User::where('email', 'budi@example.com')->firstOrFail();
        $member = $user->member;

        $this->assertNotNull($member);
        $this->assertSame(MemberStatus::Pending, $member->status);
        $this->assertStringStartsWith($user->id.'/', $member->ktp_path);

        foreach ([$member->ktp_path, $member->sim_path, $member->payment_path] as $path) {
            $this->assertNotNull($path);
            Storage::disk('private')->assertExists($path);
        }
    }

    public function test_the_identity_documents_are_required(): void
    {
        Storage::fake('private');

        $this->postJson('/api/auth/register', $this->application([
            'ktp' => null,
            'sim' => null,
            'payment' => null,
        ]))
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['ktp', 'sim', 'payment']);

        $this->assertDatabaseCount('users', 0);
        $this->assertDatabaseCount('members', 0);
    }

    public function test_a_duplicate_email_is_rejected(): void
    {
        Storage::fake('private');

        User::factory()->create(['email' => 'budi@example.com']);

        $this->postJson('/api/auth/register', $this->application())
            ->assertUnprocessable()
            ->assertJsonValidationErrors('email');

        $this->assertDatabaseCount('members', 0);
    }

    public function test_a_weak_password_is_rejected(): void
    {
        Storage::fake('private');

        $this->postJson('/api/auth/register', $this->application([
            'password' => 'secret',
            'password_confirmation' => 'secret',
        ]))
            ->assertUnprocessable()
            ->assertJsonValidationErrors('password');
    }

    public function test_registration_is_rate_limited_per_ip_address(): void
    {
        Storage::fake('private');

        for ($attempt = 1; $attempt <= 5; $attempt++) {
            $this->postJson('/api/auth/register', $this->application([
                'email' => "budi{$attempt}@example.com",
            ]))->assertCreated();
        }

        $this->postJson('/api/auth/register', $this->application([
            'email' => 'budi6@example.com',
        ]))->assertTooManyRequests();

        $this->assertDatabaseCount('users', 5);
    }

    /**
     * A complete registration payload.
     *
     * @param  array<string, mixed>  $overrides
     * @return array<string, mixed>
     */
    private function application(array $overrides = []): array
    {
        return array_merge([
            'name' => 'Budi Santoso',
            'email' => 'budi@example.com',
            'password' => 'Rahasia12345',
            'password_confirmation' => 'Rahasia12345',
            'phone' => '081234567890',
            'ktp_number' => '3201234567890001',
            'sim_number' => '123456789012',
            'ktp' => UploadedFile::fake()->image('ktp.jpg'),
            'sim' => UploadedFile::fake()->image('sim.jpg'),
            'payment' => UploadedFile::fake()->image('payment.jpg'),
        ], $overrides);
    }
}
