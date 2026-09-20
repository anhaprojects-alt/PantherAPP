<?php

namespace App\Http\Controllers\Admin;

use App\Enums\MemberStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\RejectMemberRequest;
use App\Models\Member;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class MemberController extends Controller
{
    /**
     * Document labels keyed by the type used in storage and in the routes.
     *
     * @var array<string, string>
     */
    private const DOCUMENT_LABELS = [
        'ktp' => 'KTP',
        'sim' => 'SIM',
        'payment' => 'Bukti pembayaran',
    ];

    /**
     * Applications and members, newest first, optionally filtered.
     */
    public function index(Request $request): View
    {
        $status = MemberStatus::tryFrom((string) $request->query('status', ''));
        $search = trim((string) $request->query('q', ''));

        $members = Member::query()
            ->with('user')
            ->when($status !== null, fn ($query) => $query->where('status', $status))
            ->when($search !== '', fn ($query) => $query->where(fn ($query) => $query
                ->where('member_id', 'like', "%{$search}%")
                ->orWhere('phone', 'like', "%{$search}%")
                ->orWhere('ktp_number', 'like', "%{$search}%")
                ->orWhereHas('user', fn ($query) => $query
                    ->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%"))))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return view('admin.members.index', [
            'members' => $members,
            'status' => $status,
            'search' => $search,
            'counts' => Member::statusCounts(),
        ]);
    }

    /**
     * Full application, including the documents an administrator may open.
     */
    public function show(Member $member): View
    {
        $member->load('user');

        $documents = [];

        foreach (self::DOCUMENT_LABELS as $type => $label) {
            $path = $member->documentPath($type);

            $documents[$type] = [
                'label' => $label,
                'available' => $path !== null && Storage::disk('private')->exists($path),
            ];
        }

        return view('admin.members.show', [
            'member' => $member,
            'documents' => $documents,
            'counts' => Member::statusCounts(),
        ]);
    }

    /**
     * Grant membership and issue a member number.
     */
    public function approve(Member $member): RedirectResponse
    {
        if ($member->isApproved()) {
            return back()->with('status', 'Member '.$member->member_id.' sudah disetujui sebelumnya.');
        }

        $member->markAsApproved(Member::nextMemberNumber());

        return redirect()
            ->route('admin.members.show', $member)
            ->with('status', 'Pengajuan disetujui. Nomor anggota: '.$member->member_id.'.');
    }

    /**
     * Reject an application with a reason for the applicant.
     */
    public function reject(RejectMemberRequest $request, Member $member): RedirectResponse
    {
        if ($member->status->isRejected()) {
            return back()->with('status', 'Pengajuan ini sudah ditolak.');
        }

        $member->markAsRejected($request->reason());

        return redirect()
            ->route('admin.members.show', $member)
            ->with('status', 'Pengajuan ditolak.');
    }
}
