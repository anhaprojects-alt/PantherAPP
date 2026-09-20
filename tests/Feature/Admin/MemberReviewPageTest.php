<?php

namespace Tests\Feature\Admin;

use App\Enums\MemberStatus;
use App\Models\Member;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class MemberReviewPageTest extends TestCase
{
    use RefreshDatabase;

    private function administrator(): User
    {
        return User::factory()->admin()->create();
    }

    public function test_the_panel_is_closed_to_signed_in_members(): void
    {
        $member = Member::factory()->create();

        $this->actingAs($member->user)->get(route('admin.members.index'))->assertForbidden();
        $this->actingAs($member->user)->get(route('admin.members.show', $member))->assertForbidden();
    }

    public function test_guests_are_redirected_to_the_sign_in_form(): void
    {
        $member = Member::factory()->create();

        $this->get(route('admin.members.index'))->assertRedirect(route('admin.login'));
        $this->get(route('admin.members.show', $member))->assertRedirect(route('admin.login'));
    }

    public function test_members_can_be_filtered_by_status(): void
    {
        $pending = Member::factory()->create();
        $approved = Member::factory()->approved()->create();

        $this->actingAs($this->administrator())
            ->get(route('admin.members.index', ['status' => 'pending']))
            ->assertOk()
            ->assertSee($pending->user->name)
            ->assertDontSee($approved->user->name);
    }

    public function test_members_can_be_searched(): void
    {
        $target = Member::factory()->create();
        $other = Member::factory()->create();

        $this->actingAs($this->administrator())
            ->get(route('admin.members.index', ['q' => $target->user->email]))
            ->assertOk()
            ->assertSee($target->user->name)
            ->assertDontSee($other->user->name);
    }

    public function test_the_detail_page_links_the_uploaded_documents(): void
    {
        Storage::fake('private');

        $member = Member::factory()->create();
        Storage::disk('private')->put($member->ktp_path, 'ktp-image');

        $this->actingAs($this->administrator())
            ->get(route('admin.members.show', $member))
            ->assertOk()
            ->assertSee('KTP')
            ->assertSee(route('admin.members.documents.show', [$member, 'ktp']), false)
            ->assertSee('Belum diunggah');
    }

    public function test_an_administrator_can_open_a_document(): void
    {
        Storage::fake('private');

        $member = Member::factory()->create();
        Storage::disk('private')->put($member->ktp_path, 'ktp-image');

        $this->actingAs($this->administrator())
            ->get(route('admin.members.documents.show', [$member, 'ktp']))
            ->assertDownload();
    }

    public function test_a_document_that_was_never_uploaded_returns_not_found(): void
    {
        Storage::fake('private');

        $member = Member::factory()->create();

        $this->actingAs($this->administrator())
            ->get(route('admin.members.documents.show', [$member, 'sim']))
            ->assertNotFound();
    }

    public function test_an_unknown_document_type_returns_not_found(): void
    {
        $member = Member::factory()->create();

        $this->actingAs($this->administrator())
            ->get(route('admin.members.documents.show', [$member, 'passport']))
            ->assertNotFound();
    }

    public function test_approving_an_application_issues_a_member_number(): void
    {
        $member = Member::factory()->create();

        $this->actingAs($this->administrator())
            ->post(route('admin.members.approve', $member))
            ->assertRedirect(route('admin.members.show', $member));

        $member->refresh();

        $this->assertSame(MemberStatus::Approved, $member->status);
        $this->assertNotNull($member->approved_at);
        $this->assertIsString($member->member_id);
        $this->assertStringStartsWith('PM-', $member->member_id);
    }

    public function test_approving_an_approved_member_keeps_the_original_number(): void
    {
        $member = Member::factory()->approved()->create();
        $original = $member->member_id;

        $this->actingAs($this->administrator())
            ->post(route('admin.members.approve', $member))
            ->assertRedirect();

        $this->assertSame($original, $member->refresh()->member_id);
    }

    public function test_a_rejected_application_can_still_be_approved(): void
    {
        $member = Member::factory()->rejected()->create();

        $this->actingAs($this->administrator())
            ->post(route('admin.members.approve', $member))
            ->assertRedirect();

        $member->refresh();

        $this->assertSame(MemberStatus::Approved, $member->status);
        $this->assertNull($member->rejected_reason);
    }

    public function test_rejecting_requires_a_reason(): void
    {
        $member = Member::factory()->create();

        $this->actingAs($this->administrator())
            ->post(route('admin.members.reject', $member), ['reason' => ''])
            ->assertSessionHasErrors('reason');

        $this->assertSame(MemberStatus::Pending, $member->refresh()->status);
    }

    public function test_rejecting_records_the_reason_for_the_applicant(): void
    {
        $member = Member::factory()->create();

        $this->actingAs($this->administrator())
            ->post(route('admin.members.reject', $member), ['reason' => 'Foto KTP tidak terbaca'])
            ->assertRedirect(route('admin.members.show', $member));

        $member->refresh();

        $this->assertSame(MemberStatus::Rejected, $member->status);
        $this->assertSame('Foto KTP tidak terbaca', $member->rejected_reason);
        $this->assertNotNull($member->rejected_at);
    }

    public function test_the_dashboard_reports_each_status(): void
    {
        Member::factory()->create();
        Member::factory()->approved()->create();
        Member::factory()->rejected()->create();

        $this->actingAs($this->administrator())
            ->get(route('admin.dashboard'))
            ->assertOk()
            ->assertViewHas('counts', fn (array $counts): bool => $counts === [
                'pending' => 1,
                'approved' => 1,
                'rejected' => 1,
            ]);
    }
}
