<?php

use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MemberController;
use Illuminate\Support\Facades\Route;

Route::post('/auth/register', [AuthController::class, 'register'])->middleware('throttle:register');
Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:login');

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/me', [MemberController::class, 'show']);
    Route::put('/me/profile', [MemberController::class, 'update']);
    Route::middleware('admin')->prefix('admin')->group(function () {
        Route::get('/members/pending', [AdminController::class, 'pending']);
        Route::post('/members/{member}/approve', [AdminController::class, 'approve']);
    });
});
