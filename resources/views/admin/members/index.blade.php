@extends('admin.layout')

@section('title', 'Member')
@section('heading', 'Member')
@section('subheading', 'Semua pengajuan dan anggota terdaftar.')

@section('content')
    @php
        $tabs = [
            '' => ['label' => 'Semua', 'total' => array_sum($counts)],
            'pending' => ['label' => 'Menunggu review', 'total' => $counts['pending']],
            'approved' => ['label' => 'Disetujui', 'total' => $counts['approved']],
            'rejected' => ['label' => 'Ditolak', 'total' => $counts['rejected']],
        ];
    @endphp

    <div class="filter-bar">
        <div class="chips">
            @foreach ($tabs as $value => $tab)
                <a
                    class="chip @if (($status?->value ?? '') === $value) is-active @endif"
                    href="{{ route('admin.members.index', array_filter(['status' => $value, 'q' => $search ?: null])) }}"
                >
                    {{ $tab['label'] }} <span class="chip-count">{{ $tab['total'] }}</span>
                </a>
            @endforeach
        </div>

        <form class="search" method="GET" action="{{ route('admin.members.index') }}">
            @if ($status)
                <input type="hidden" name="status" value="{{ $status->value }}">
            @endif
            <input class="input" type="search" name="q" value="{{ $search }}" placeholder="Cari nama, email, HP, KTP">
            <button class="btn btn-ghost" type="submit">Cari</button>
        </form>
    </div>

    @if ($members->isEmpty())
        <div class="card">
            <p class="muted">Tidak ada data yang cocok.</p>
        </div>
    @else
        <div class="card">
            <table class="table">
                <thead>
                    <tr>
                        <th>Nama</th>
                        <th>Nomor anggota</th>
                        <th>Telepon</th>
                        <th>Status</th>
                        <th>Diajukan</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($members as $member)
                        <tr>
                            <td>
                                {{ $member->user->name }}
                                <div class="muted small">{{ $member->user->email }}</div>
                            </td>
                            <td>{{ $member->member_id ?? '—' }}</td>
                            <td class="muted">{{ $member->phone ?: '—' }}</td>
                            <td>
                                <span class="badge badge-{{ $member->status->value }}">{{ $member->status->label() }}</span>
                            </td>
                            <td class="muted">{{ $member->created_at?->translatedFormat('d M Y') }}</td>
                            <td class="table-action">
                                <a class="btn btn-ghost" href="{{ route('admin.members.show', $member) }}">Detail</a>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        @if ($members->hasPages())
            <div class="pager">
                @if ($members->onFirstPage())
                    <span class="pager-off">&larr; Sebelumnya</span>
                @else
                    <a class="btn btn-ghost" href="{{ $members->previousPageUrl() }}">&larr; Sebelumnya</a>
                @endif

                <span class="muted">Halaman {{ $members->currentPage() }} dari {{ $members->lastPage() }}</span>

                @if ($members->hasMorePages())
                    <a class="btn btn-ghost" href="{{ $members->nextPageUrl() }}">Berikutnya &rarr;</a>
                @else
                    <span class="pager-off">Berikutnya &rarr;</span>
                @endif
            </div>
        @endif
    @endif
@endsection
