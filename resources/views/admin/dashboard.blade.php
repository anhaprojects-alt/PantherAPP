@extends('admin.layout')

@section('title', 'Dashboard')
@section('heading', 'Dashboard')
@section('subheading', 'Ringkasan keanggotaan.')

@section('content')
    <div class="stat-grid">
        <div class="stat-card">
            <span class="stat-label">Menunggu review</span>
            <span class="stat">{{ $counts['pending'] }}</span>
        </div>

        <div class="stat-card">
            <span class="stat-label">Disetujui</span>
            <span class="stat">{{ $counts['approved'] }}</span>
        </div>

        <div class="stat-card">
            <span class="stat-label">Ditolak</span>
            <span class="stat">{{ $counts['rejected'] }}</span>
        </div>
    </div>

    <div class="card">
        <h2 class="card-title">Pengajuan terbaru yang menunggu review</h2>

        @if ($latestPending->isEmpty())
            <p class="muted">Tidak ada pengajuan yang menunggu review.</p>
        @else
            <table class="table">
                <thead>
                    <tr>
                        <th>Nama</th>
                        <th>Kontak</th>
                        <th>Diajukan</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($latestPending as $member)
                        <tr>
                            <td>{{ $member->user->name }}</td>
                            <td class="muted">{{ $member->user->email }}</td>
                            <td class="muted">{{ $member->created_at?->translatedFormat('d M Y') }}</td>
                            <td class="table-action">
                                <a class="btn btn-ghost" href="{{ route('admin.members.show', $member) }}">Tinjau</a>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>

            <p class="card-foot">
                <a href="{{ route('admin.members.index', ['status' => 'pending']) }}">Lihat semua pengajuan &rarr;</a>
            </p>
        @endif
    </div>
@endsection
