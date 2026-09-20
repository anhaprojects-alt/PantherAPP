<?php

namespace App\Http\Controllers\Api;

use App\Enums\MemberStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\RejectMemberRequest;
use App\Http\Resources\Admin\MemberDetailResource;
use App\Http\Resources\Admin\MemberSummaryResource;
use App\Models\Member;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    /**
     * Applications that still await review, newest first.
     */
    public function pending(Request $request): JsonResponse
    {
        $members = Member::query()
            ->with('user')
            ->pending()
            ->latest()
            ->paginate(25);

        $members->through(
            fn (Member $member): array => (new MemberSummaryResource($member))->resolve($request)
        );

        return response()->json($members->toArray());
    }

    /**
     * Full application, including links to the uploaded documents.
     */
    public function show(Request $request, Member $member): JsonResponse
    {
        return response()->json(
            (new MemberDetailResource($member->load('user')))->resolve($request)
        );
    }

    /**
     * Grant membership and issue a member number.
     *
     * Applications that were rejected earlier can be approved this way too.
     */
    public function approve(Request $request, Member $member): JsonResponse
    {
        abort_if($member->isApproved(), 422, 'Member sudah disetujui.');

        $member->markAsApproved(Member::nextMemberNumber());

        return response()->json(
            (new MemberDetailResource($member->load('user')))->resolve($request)
        );
    }

    /**
     * Reject an application and record the reason for the applicant.
     */
    public function reject(RejectMemberRequest $request, Member $member): JsonResponse
    {
        abort_if($member->status === MemberStatus::Rejected, 422, 'Member sudah ditolak.');

        $member->markAsRejected($request->reason());

        return response()->json(
            (new MemberDetailResource($member->load('user')))->resolve($request)
        );
    }
}
