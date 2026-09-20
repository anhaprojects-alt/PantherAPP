<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Member;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email:rfc,dns', 'max:255', 'unique:users,email'],
            'password' => ['required', 'confirmed', Password::min(10)->mixedCase()->numbers()],
            'phone' => ['required', 'string', 'max:30'],
            'ktp_number' => ['required', 'string', 'max:32'],
            'sim_number' => ['required', 'string', 'max:32'],
            'ktp' => ['required', 'file', 'image', 'max:5120'],
            'sim' => ['required', 'file', 'image', 'max:5120'],
            'payment' => ['required', 'file', 'image', 'max:5120'],
        ]);

        $member = DB::transaction(function () use ($data, $request) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
            ]);

            return $user->member()->create([
                'phone' => $data['phone'],
                'ktp_number' => $data['ktp_number'],
                'sim_number' => $data['sim_number'],
                'ktp_path' => $request->file('ktp')->store("members/{$user->id}", 'private'),
                'sim_path' => $request->file('sim')->store("members/{$user->id}", 'private'),
                'payment_path' => $request->file('payment')->store("members/{$user->id}", 'private'),
            ]);
        });

        return response()->json(['message' => 'Pendaftaran berhasil dan sedang direview.', 'status' => $member->status], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate(['email' => ['required', 'email'], 'password' => ['required', 'string']]);
        $user = User::where('email', $credentials['email'])->first();

        if (! $user || ! Hash::check($credentials['password'], $user->password)) {
            return response()->json(['message' => 'Email atau password salah.'], 422);
        }

        return response()->json(['token' => $user->createToken('android')->plainTextToken, 'user' => $user->load('member')]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();
        return response()->json(['message' => 'Berhasil keluar.']);
    }
}
