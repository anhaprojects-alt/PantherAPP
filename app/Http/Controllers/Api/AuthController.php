<?php

namespace App\Http\Controllers\Api;

use App\Enums\MemberStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\Member;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    /**
     * Accept a new application and store the uploaded identity documents.
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $data = $request->validated();

        $member = DB::transaction(function () use ($request, $data): Member {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => $data['password'],
            ]);

            return $user->member()->create([
                'phone' => $data['phone'],
                'ktp_number' => $data['ktp_number'],
                'sim_number' => $data['sim_number'],
                'status' => MemberStatus::Pending,
                'ktp_path' => $request->file('ktp')->store((string) $user->id, 'private'),
                'sim_path' => $request->file('sim')->store((string) $user->id, 'private'),
                'payment_path' => $request->file('payment')->store((string) $user->id, 'private'),
            ]);
        });

        return response()->json([
            'message' => 'Pendaftaran berhasil dan sedang direview.',
            'status' => $member->status?->value,
        ], 201);
    }

    /**
     * Exchange credentials for an API token.
     *
     * Only approved members (and administrators) may sign in; applicants
     * without a member record are refused as well.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $user = $request->authenticate();
        $user->loadMissing('member');

        $member = $user->member;
        $status = $member?->status;

        if (! $user->is_admin && ! $status?->isApproved()) {
            return response()->json([
                'message' => match ($status) {
                    MemberStatus::Rejected => 'Pendaftaran Anda ditolak oleh admin.',
                    MemberStatus::Pending => 'Pendaftaran Anda masih menunggu persetujuan admin.',
                    default => 'Akun Anda belum terdaftar sebagai member.',
                },
                'status' => $status?->value,
                'reason' => $member?->rejected_reason,
            ], 403);
        }

        return response()->json([
            'token' => $user->createToken('android')->plainTextToken,
            'user' => (new UserResource($user))->resolve($request),
        ]);
    }

    /**
     * Revoke the token that was used for the current request.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json(['message' => 'Berhasil keluar.']);
    }
}
