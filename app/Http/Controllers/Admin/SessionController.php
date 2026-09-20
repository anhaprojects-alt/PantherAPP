<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\AdminLoginRequest;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class SessionController extends Controller
{
    /**
     * Show the sign-in form for administrators.
     */
    public function create(): View
    {
        return view('admin.login');
    }

    /**
     * Start an authenticated session for an administrator.
     */
    public function store(AdminLoginRequest $request): RedirectResponse
    {
        $request->authenticate();

        // Rotate the session id so a fixated session cannot survive sign-in.
        $request->session()->regenerate();

        return redirect()->intended(route('admin.dashboard'));
    }

    /**
     * End the authenticated session.
     */
    public function destroy(Request $request): RedirectResponse
    {
        Auth::guard('web')->logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login');
    }
}
