<?php

namespace Tests\Feature\Admin;

use App\Enums\MemberStatus;
use App\Models\Member;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MemberReviewTest extends TestCase
{
    use RefreshDatabase;

    public function test_only_administrators_can_review_applications(): void
    {
        $member = Member::factory()->create();
        Sanctum::actingAs($member->user);

        $this->getJson('/api/admin/members/pending')->assertForbidden();
        $this->getJson("/api/admin/members/{$member->id}")->assertForbidden();
        $this->postJson("/api/admin/members/{$member->id}/approve")->assertForbidden();
        $this->postJson("/api/admin/members/{$member->id}/reject")->assertForbidden();
    }

    public function test_guest_requests_are_rejected(): void
    {
        $this->getJson('/api/admin/members/pending')->assertUnauthorized();
    }

    public function test_pending_applications_are_listed_without_document_paths(): void
    {
        $pending = Member::factory()->create();
        Member::factory()->approved()->create();

        Sanctum::actingAs(User::factory()->admin()->create());

        $response = $this->getJson('/api/admin/members/pending');

        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $pending->id)
            ->assertJsonPath('data.0.status', MemberStatus::Pending->value)
            ->assertJsonPath('data.0.user.email', $pending->user->email);

        $this->assertArrayNotHasKey('ktp_path', $response->json('data.0'));
        $this->assertArrayNotHasKey('payment_path', $response->json('data.0'));
    }

    public function test_an_application_can_be_approved(): void
    {
        $member = Member::factory()->create();
        Sanctum::actingAs(User::factory()->admin()->create());

        $response = $this->postJson("/api/admin/members/{$member->id}/approve");

        $response->assertOk()
            ->assertJsonPath('status', MemberStatus::Approved->value)
            ->assertJsonStructure(['member_id', 'user', 'documents' => ['ktp', 'sim', 'payment']]);

        $member->refresh();

        $this->assertTrue($member->isApproved());
        $this->assertStringStartsWith('PM-', (string) $member->member_id);
        $this->assertNotNull($member->approved_at);
    }

    public function test_an_approved_member_cannot_be_approved_twice(): void
    {
        $member = Member::factory()->approved()->create();
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->postJson("/api/admin/members/{$member->id}/approve")->assertStatus(422);
    }

    public function test_a_rejected_application_can_be_approved_afterwards(): void
    {
        $member = Member::factory()->rejected('Foto KTP tidak terbaca.')->create();
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->postJson("/api/admin/members/{$member->id}/approve")->assertOk();

        $member->refresh();

        $this->assertTrue($member->isApproved());
        $this->assertNull($member->rejected_reason);
        $this->assertNull($member->rejected_at);
    }

    public function test_an_application_can_be_rejected_with_a_reason(): void
    {
        $member = Member::factory()->create();
        Sanctum::actingAs(User::factory()->admin()->create());

        $response = $this->postJson("/api/admin/members/{$member->id}/reject", [
            'reason' => 'Foto KTP tidak terbaca.',
        ]);

        $response->assertOk()
            ->assertJsonPath('status', MemberStatus::Rejected->value)
            ->assertJsonPath('rejected_reason', 'Foto KTP tidak terbaca.');

        $member->refresh();

        $this->assertSame(MemberStatus::Rejected, $member->status);
        $this->assertNotNull($member->rejected_at);
    }

    public function test_rejecting_an_application_requires_a_reason(): void
    {
        $member = Member::factory()->create();
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->postJson("/api/admin/members/{$member->id}/reject")
            ->assertUnprocessable()
            ->assertJsonValidationErrors('reason');
    }

    public function test_an_administrator_can_download_uploaded_documents(): void
    {
        Storage::fake('private');

        $member = Member::factory()->create();
        Storage::disk('private')->put($member->ktp_path, 'ktp-content');

        Sanctum::actingAs(User::factory()->admin()->create());

        $this->get("/api/admin/members/{$member->id}/documents/ktp")
            ->assertOk()
            ->assertDownload('ktp.jpg');
    }

    public function test_a_member_can_download_its_own_documents_only(): void
    {
        Storage::fake('private');

        $member = Member::factory()->approved()->create();
        Storage::disk('private')->put($member->ktp_path, 'ktp-content');

        Sanctum::actingAs($member->user);

        $this->get('/api/me/documents/ktp')->assertOk()->assertDownload('ktp.jpg');
        $this->getJson("/api/admin/members/{$member->id}/documents/ktp")->assertForbidden();
        $this->get('/api/me/documents/unknown')->assertNotFound();
    }

    public function test_a_missing_document_is_not_found(): void
    {
        Storage::fake('private');

        $member = Member::factory()->create(['ktp_path' => null]);
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->get("/api/admin/members/{$member->id}/documents/ktp")->assertNotFound();
    }
}
