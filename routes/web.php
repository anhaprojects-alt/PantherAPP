<?php

use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\MemberController;
use App\Http\Controllers\Admin\SessionController;
use App\Http\Controllers\Api\MemberDocumentController;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => view('welcome'))->name('home');

/*
 * Admin sign-in uses the session based "web" guard, unlike the token based API
 * that the Android app talks to.
 */
Route::middleware('guest')->group(function (): void {
    Route::get('/admin/login', [SessionController::class, 'create'])->name('admin.login');

    Route::post('/admin/login', [SessionController::class, 'store'])
        ->middleware('throttle:6,1')
        ->name('admin.login.store');
});

Route::middleware(['auth', 'admin'])->group(function (): void {
    Route::get('/admin', DashboardController::class)->name('admin.dashboard');

    Route::get('/admin/members', [MemberController::class, 'index'])->name('admin.members.index');
    Route::get('/admin/members/{member}', [MemberController::class, 'show'])->name('admin.members.show');
    Route::post('/admin/members/{member}/approve', [MemberController::class, 'approve'])->name('admin.members.approve');
    Route::post('/admin/members/{member}/reject', [MemberController::class, 'reject'])->name('admin.members.reject');

    /*
     * The uploaded documents live on the private disk. The API controller
     * already streams them for an administrator, so the panel reuses it rather
     * than duplicating the storage logic.
     */
    Route::get('/admin/members/{member}/documents/{type}', [MemberDocumentController::class, 'admin'])
        ->whereIn('type', MemberDocumentController::TYPES)
        ->name('admin.members.documents.show');

    Route::post('/admin/logout', [SessionController::class, 'destroy'])->name('admin.logout');
});
