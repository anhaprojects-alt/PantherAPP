<?php

use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MemberController;
use App\Http\Controllers\Api\MemberDocumentController;
use Illuminate\Support\Facades\Route;

Route::post('/auth/register', [AuthController::class, 'register'])
    ->name('auth.register')
    ->middleware('throttle:register');
Route::post('/auth/login', [AuthController::class, 'login'])
    ->name('auth.login')
    ->middleware('throttle:login');

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout'])->name('auth.logout');
    Route::get('/me', [MemberController::class, 'show'])->name('me.show');
    Route::put('/me/profile', [MemberController::class, 'update'])->name('me.profile.update');
    Route::post('/me/avatar', [MemberController::class, 'updateAvatar'])->name('me.avatar.store');
    Route::delete('/me/avatar', [MemberController::class, 'destroyAvatar'])->name('me.avatar.destroy');
    Route::get('/me/documents/{type}', [MemberDocumentController::class, 'own'])
        ->name('me.documents.show')
        ->whereIn('type', MemberDocumentController::TYPES);

    Route::middleware('admin')->prefix('admin')->name('admin.')->group(function () {
        Route::get('/members/pending', [AdminController::class, 'pending'])->name('members.pending');
        Route::get('/members/{member}', [AdminController::class, 'show'])->name('members.show');
        Route::post('/members/{member}/approve', [AdminController::class, 'approve'])->name('members.approve');
        Route::post('/members/{member}/reject', [AdminController::class, 'reject'])->name('members.reject');
        Route::get('/members/{member}/documents/{type}', [MemberDocumentController::class, 'admin'])
            ->name('members.documents.show')
            ->whereIn('type', MemberDocumentController::TYPES);
    });
});
