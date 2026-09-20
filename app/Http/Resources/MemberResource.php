<?php

namespace App\Http\Resources;

use App\Models\Member;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Profile of a member as seen by the member itself.
 *
 * @mixin Member
 */
class MemberResource extends JsonResource
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
            'religion' => $this->religion,
            'gender' => $this->gender,
            'marital_status' => $this->marital_status,
            'address' => $this->address,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'job' => $this->job,
            'company' => $this->company,
            'company_address' => $this->company_address,
            'vehicle_type' => $this->vehicle_type,
            'vehicle_color' => $this->vehicle_color,
            'vehicle_year' => $this->vehicle_year,
            'chassis_number' => $this->chassis_number,
            'engine_number' => $this->engine_number,
            'tax_due_date' => $this->tax_due_date?->toDateString(),
            'profile_photo_url' => $this->profilePhotoUrl(),
            'approved_at' => $this->approved_at?->toIso8601String(),
            'rejected_at' => $this->rejected_at?->toIso8601String(),
            'rejected_reason' => $this->rejected_reason,
        ];
    }
}
