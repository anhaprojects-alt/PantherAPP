<?php

namespace App\Http\Resources\Admin;

use App\Models\Member;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Compact view of an application for the review list.
 *
 * @mixin Member
 */
class MemberSummaryResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'member_id' => $this->member_id,
            'status' => $this->status?->value,
            'status_label' => $this->status?->label(),
            'phone' => $this->phone,
            'ktp_number' => $this->ktp_number,
            'sim_number' => $this->sim_number,
            'user' => $this->whenLoaded('user', fn (User $user): array => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ]),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
