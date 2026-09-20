<?php

namespace App\Http\Requests\Auth;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
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
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email:rfc', 'max:255', 'unique:users,email'],
            'password' => ['required', 'confirmed', Password::min(10)->mixedCase()->numbers()],
            'phone' => ['required', 'string', 'max:30'],
            'ktp_number' => ['required', 'string', 'max:32'],
            'sim_number' => ['required', 'string', 'max:32'],
            'ktp' => ['required', 'file', 'image', 'max:5120'],
            'sim' => ['required', 'file', 'image', 'max:5120'],
            'payment' => ['required', 'file', 'image', 'max:5120'],
        ];
    }
}
