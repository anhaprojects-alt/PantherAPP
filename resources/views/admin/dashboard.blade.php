@extends('admin.layout')

@section('title', 'Dashboard')
@section('heading', 'Dashboard')
@section('subheading', 'Ringkasan keanggotaan.')

@section('content')
    <div class="stat-grid">
        <article class="stat-card">
            <span class="stat-icon stat-icon--pending" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="9"/>
                    <path d="M12 7.5V12l3 2"/>
                </svg>
            </span>
            <span class="stat-label">Menunggu review</span>
            <span class="stat">{{ $counts['pending'] }}</span>
        </article>

        <article class="stat-card">
            <span class="stat-icon stat-icon--approved" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="9"/>
                    <path d="M8.4 12.4l2.6 2.6 4.6-5.2"/>
                </svg>
            </span>
            <span class="stat-label">Disetujui</span>
            <span class="stat">{{ $counts['approved'] }}</span>
        </article>

        <article class="stat-card">
            <span class="stat-icon stat-icon--rejected" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="9"/>
                    <path d="M9.4 9.4l5.2 5.2M14.6 9.4l-5.2 5.2"/>
                </svg>
            </span>
            <span class="stat-label">Ditolak</span>
            <span class="stat">{{ $counts['rejected'] }}</span>
        </article>
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
                            <td data-label="Nama">{{ $member->user->name }}</td>
                            <td class="muted" data-label="Kontak">{{ $member->user->email }}</td>
                            <td class="muted" data-label="Diajukan">{{ $member->created_at?->translatedFormat('d M Y') }}</td>
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
