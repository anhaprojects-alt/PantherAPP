<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Member\UpdateAvatarRequest;
use App\Http\Requests\Member\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class MemberController extends Controller
{
    /**
     * Current user together with the attached member profile.
     */
    public function show(Request $request): JsonResponse
    {
        return response()->json(
            (new UserResource($request->user()->load('member')))->resolve($request)
        );
    }

    /**
     * Update the part of the profile a member maintains itself.
     */
    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $user = $request->user();
        $member = $user->member()->first();

        abort_if($member === null, 404, 'Data member tidak ditemukan.');

        $member->update($request->validated());

        return response()->json(
            (new UserResource($user->load('member')))->resolve($request)
        );
    }

    /**
     * Replace the profile photo and drop the previous file.
     */
    public function updateAvatar(UpdateAvatarRequest $request): JsonResponse
    {
        $user = $request->user();
        $member = $user->member()->first();

        abort_if($member === null, 404, 'Data member tidak ditemukan.');

        $previousPath = $member->profile_photo_path;
        $member->update([
            'profile_photo_path' => $request->file('avatar')->store("avatars/{$user->id}", 'public'),
        ]);

        if ($previousPath !== null) {
            Storage::disk('public')->delete($previousPath);
        }

        return response()->json(
            (new UserResource($user->load('member')))->resolve($request)
        );
    }

    /**
     * Remove the profile photo of the current member.
     */
    public function destroyAvatar(Request $request): JsonResponse
    {
        $user = $request->user();
        $member = $user->member()->first();

        abort_if($member === null, 404, 'Data member tidak ditemukan.');

        if ($member->profile_photo_path !== null) {
            Storage::disk('public')->delete($member->profile_photo_path);
            $member->update(['profile_photo_path' => null]);
        }

        return response()->json(
            (new UserResource($user->load('member')))->resolve($request)
        );
    }
}
