<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AcademicController;

/*
|--------------------------------------------------------------------------
| API Routes for School Portal
|--------------------------------------------------------------------------
*/

// Public Routes
Route::post('/login', [AuthController::class, 'login']);

// Protected Routes (Sanctum)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Academic Endpoints
    Route::get('/tugas', [AcademicController::class, 'getTugas']);
    Route::get('/presensi', [AcademicController::class, 'getPresensi']);
    Route::get('/nilai', [AcademicController::class, 'getNilai']);

    Route::post('/logout', [AuthController::class, 'logout']);
});
