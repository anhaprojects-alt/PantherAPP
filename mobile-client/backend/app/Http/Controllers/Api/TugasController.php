<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tugas;
use Illuminate\Http\Request;

class TugasController extends Controller
{
    public function index(Request $request)
    {
        $tugas = Tugas::where('user_id', $request->user()->id)->get();
        return response()->json($tugas);
    }

    public function store(Request $request)
    {
        $request->validate([
            'judul' => 'required|string|max:255',
            'deadline' => 'required|date',
        ]);

        $tugas = Tugas::create([
            'judul' => $request->judul,
            'deskripsi' => $request->deskripsi,
            'deadline' => $request->deadline,
            'user_id' => $request->user()->id,
        ]);

        return response()->json($tugas, 201);
    }
}
