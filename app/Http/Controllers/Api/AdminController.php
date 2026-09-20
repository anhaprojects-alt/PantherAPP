<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Member;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Str;

class AdminController extends Controller
{
    public function pending(): JsonResponse
    {
        return response()->json(Member::with('user')->where('status', 'pending')->latest()->paginate(25));
    }

    public function approve(Member $member): JsonResponse
    {
        abort_if($member->status !== 'pending', 422, 'Member sudah diproses.');
        $member->update(['status' => 'approved', 'member_id' => 'PM-'.strtoupper(Str::random(8)), 'approved_at' => now()]);
        return response()->json($member->fresh()->load('user'));
    }
}
