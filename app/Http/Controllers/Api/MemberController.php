<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MemberController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        return response()->json($request->user()->load('member'));
    }

    public function update(Request $request): JsonResponse
    {
        $data = $request->validate([
            'religion' => ['nullable', 'string', 'max:40'],
            'gender' => ['nullable', 'in:male,female'],
            'marital_status' => ['nullable', 'in:single,married'],
            'address' => ['nullable', 'string', 'max:1000'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'job' => ['nullable', 'string', 'max:120'],
            'company' => ['nullable', 'string', 'max:160'],
            'company_address' => ['nullable', 'string', 'max:1000'],
            'vehicle_type' => ['nullable', 'string', 'max:80'],
            'vehicle_color' => ['nullable', 'string', 'max:40'],
            'vehicle_year' => ['nullable', 'integer', 'between:1900,2100'],
            'chassis_number' => ['nullable', 'string', 'max:80'],
            'engine_number' => ['nullable', 'string', 'max:80'],
            'tax_due_date' => ['nullable', 'date'],
        ]);

        $request->user()->member()->update($data);
        return response()->json($request->user()->fresh()->load('member'));
    }
}
