<?php

namespace App\Http\Requests\Member;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
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
        ];
    }
}
