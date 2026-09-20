<?php

namespace Tests\Feature\Member;

use App\Enums\MemberStatus;
use App\Models\Member;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProfileTest extends TestCase
{
    use RefreshDatabase;

    public function test_a_member_can_read_its_own_profile(): void
    {
        $member = Member::factory()->approved()->create();
        Sanctum::actingAs($member->user);

        $response = $this->getJson('/api/me');

        $response->assertOk()
            ->assertJsonPath('email', $member->user->email)
            ->assertJsonPath('member.member_id', $member->member_id)
            ->assertJsonPath('member.status', MemberStatus::Approved->value);
    }

    public function test_a_member_can_update_its_profile(): void
    {
        $member = Member::factory()->approved()->create();
        Sanctum::actingAs($member->user);

        $response = $this->putJson('/api/me/profile', [
            'religion' => 'Islam',
            'gender' => 'male',
            'marital_status' => 'married',
            'address' => 'Jl. Merdeka 1',
            'latitude' => -6.2,
            'longitude' => 106.8,
            'job' => 'Karyawan',
            'vehicle_type' => 'Motor',
            'vehicle_year' => 2020,
            'tax_due_date' => '2027-01-15',
        ]);

        $response->assertOk()
            ->assertJsonPath('member.religion', 'Islam')
            ->assertJsonPath('member.tax_due_date', '2027-01-15');

        $this->assertDatabaseHas('members', [
            'id' => $member->id,
            'religion' => 'Islam',
            'status' => MemberStatus::Approved->value,
        ]);
    }

    public function test_profile_updates_are_validated(): void
    {
        $member = Member::factory()->approved()->create();
        Sanctum::actingAs($member->user);

        $this->putJson('/api/me/profile', [
            'gender' => 'unknown',
            'latitude' => 120,
            'vehicle_year' => 1800,
        ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['gender', 'latitude', 'vehicle_year']);
    }

    public function test_a_member_can_replace_and_remove_the_profile_photo(): void
    {
        Storage::fake('public');

        $member = Member::factory()->approved()->create();
        Sanctum::actingAs($member->user);

        $this->postJson('/api/me/avatar', [
            'avatar' => UploadedFile::fake()->image('avatar.jpg'),
        ])->assertOk();

        $path = $member->fresh()->profile_photo_path;

        $this->assertNotNull($path);
        Storage::disk('public')->assertExists($path);

        $this->postJson('/api/me/avatar', [
            'avatar' => UploadedFile::fake()->image('avatar-2.jpg'),
        ])->assertOk();

        $secondPath = $member->fresh()->profile_photo_path;

        $this->assertNotNull($secondPath);
        $this->assertNotSame($path, $secondPath);
        Storage::disk('public')->assertMissing($path);

        $this->deleteJson('/api/me/avatar')->assertOk();

        $this->assertNull($member->fresh()->profile_photo_path);
        Storage::disk('public')->assertMissing($secondPath);
    }

    public function test_the_profile_photo_must_be_an_image(): void
    {
        Storage::fake('public');

        $member = Member::factory()->approved()->create();
        Sanctum::actingAs($member->user);

        $this->postJson('/api/me/avatar', [
            'avatar' => UploadedFile::fake()->create('document.pdf', 100, 'application/pdf'),
        ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('avatar');
    }

    public function test_a_user_without_a_member_record_gets_a_not_found_response(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->getJson('/api/me')->assertOk();
        $this->putJson('/api/me/profile', ['job' => 'Karyawan'])->assertNotFound();
        $this->postJson('/api/me/avatar', [
            'avatar' => UploadedFile::fake()->image('avatar.jpg'),
        ])->assertNotFound();
    }

    public function test_an_authenticated_request_is_required(): void
    {
        $this->getJson('/api/me')->assertUnauthorized();
        $this->putJson('/api/me/profile', ['job' => 'Karyawan'])->assertUnauthorized();
    }
}
