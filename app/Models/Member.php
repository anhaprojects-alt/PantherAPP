<?php

namespace App\Models;

use App\Enums\MemberStatus;
use Database\Factories\MemberFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class Member extends Model
{
    /** @use HasFactory<MemberFactory> */
    use HasFactory;

    /**
     * The status, member number and approval timestamps are driven by the
     * server state machine (markAsApproved / markAsRejected) and are
     * deliberately left out of the mass assignable attributes.
     *
     * @var list<string>
     */
    protected $fillable = [
        'phone',
        'ktp_number',
        'sim_number',
        'ktp_path',
        'sim_path',
        'payment_path',
        'profile_photo_path',
        'status',
        'religion',
        'gender',
        'marital_status',
        'address',
        'latitude',
        'longitude',
        'job',
        'company',
        'company_address',
        'vehicle_type',
        'vehicle_color',
        'vehicle_year',
        'chassis_number',
        'engine_number',
        'tax_due_date',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'status' => MemberStatus::class,
            'approved_at' => 'datetime',
            'rejected_at' => 'datetime',
            'tax_due_date' => 'date',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Limit the query to applications that still await review.
     */
    public function scopePending(Builder $query): void
    {
        $query->where('status', MemberStatus::Pending);
    }

    /**
     * Number of members per status, keyed by the status value.
     *
     * @return array<string, int>
     */
    public static function statusCounts(): array
    {
        $counts = static::query()
            ->selectRaw('status, count(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status');

        $totals = [];

        foreach (MemberStatus::cases() as $case) {
            $totals[$case->value] = (int) ($counts[$case->value] ?? 0);
        }

        return $totals;
    }

    /**
     * Issue a member number that the unique index will accept.
     *
     * The numbers are random, so retry whenever the index rejects one.
     */
    public static function nextMemberNumber(): string
    {
        do {
            $memberId = 'PM-'.strtoupper(Str::random(8));
        } while (static::query()->where('member_id', $memberId)->exists());

        return $memberId;
    }

    public function isApproved(): bool
    {
        return $this->status === MemberStatus::Approved;
    }

    /**
     * Grant membership and record the member number that was issued.
     */
    public function markAsApproved(string $memberId): void
    {
        $this->forceFill([
            'status' => MemberStatus::Approved,
            'member_id' => $this->member_id ?? $memberId,
            'approved_at' => now(),
            'rejected_at' => null,
            'rejected_reason' => null,
        ])->save();
    }

    /**
     * Reject the application and store the reason shown to the applicant.
     */
    public function markAsRejected(string $reason): void
    {
        $this->forceFill([
            'status' => MemberStatus::Rejected,
            'rejected_at' => now(),
            'rejected_reason' => $reason,
        ])->save();
    }

    /**
     * Resolve the stored path of one of the uploaded identity documents.
     */
    public function documentPath(string $type): ?string
    {
        return match ($type) {
            'ktp' => $this->ktp_path,
            'sim' => $this->sim_path,
            'payment' => $this->payment_path,
            default => null,
        };
    }

    /**
     * Publicly reachable URL of the profile photo, when one was uploaded.
     */
    public function profilePhotoUrl(): ?string
    {
        if ($this->profile_photo_path === null) {
            return null;
        }

        return Storage::disk('public')->url($this->profile_photo_path);
    }
}
