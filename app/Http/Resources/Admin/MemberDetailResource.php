<?php

namespace App\Http\Resources\Admin;

use App\Http\Resources\MemberResource;
use App\Models\Member;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Full application as seen by an administrator, including the uploaded
 * identity documents. Those documents are only reachable through the
 * authenticated endpoints behind the links below.
 *
 * @mixin Member
 */
class MemberDetailResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            ...(new MemberResource($this->resource))->resolve($request),
            'user' => $this->whenLoaded('user', fn (User $user): array => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ]),
            'documents' => [
                'ktp' => route('admin.members.documents.show', ['member' => $this->id, 'type' => 'ktp']),
                'sim' => route('admin.members.documents.show', ['member' => $this->id, 'type' => 'sim']),
                'payment' => route('admin.members.documents.show', ['member' => $this->id, 'type' => 'payment']),
            ],
        ];
    }
}
