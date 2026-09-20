<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Member;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Streams the identity documents a member uploaded during registration.
 *
 * The files live on the private disk, outside of any served storage root,
 * so they can only be read through these authorised endpoints.
 */
class MemberDocumentController extends Controller
{
    /**
     * Document types that can be requested.
     *
     * @var list<string>
     */
    public const TYPES = ['ktp', 'sim', 'payment'];

    /**
     * Stream a document of the authenticated member.
     */
    public function own(Request $request, string $type): StreamedResponse
    {
        $member = $request->user()->member;

        abort_if($member === null, 404, 'Data member tidak ditemukan.');

        return $this->stream($member, $type);
    }

    /**
     * Stream a document of the given member for an administrator.
     */
    public function admin(Member $member, string $type): StreamedResponse
    {
        return $this->stream($member, $type);
    }

    private function stream(Member $member, string $type): StreamedResponse
    {
        $path = $member->documentPath($type);

        abort_if(
            $path === null || ! Storage::disk('private')->exists($path),
            404,
            'Dokumen tidak ditemukan.'
        );

        return Storage::disk('private')->download($path);
    }
}
