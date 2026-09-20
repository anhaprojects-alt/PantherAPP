@extends('admin.layout')

@section('title', 'Detail pengajuan')

@section('heading')
    {{ $member->user->name }}
@endsection

@section('subheading')
    Pengajuan #{{ $member->id }} &middot; {{ $member->status->label() }}
@endsection

@section('content')
    <div class="card">
        <div class="detail-head">
            <div>
                <span class="badge badge-{{ $member->status->value }}">{{ $member->status->label() }}</span>

                @if ($member->member_id)
                    <span class="member-number">Nomor anggota: <strong>{{ $member->member_id }}</strong></span>
                @endif
            </div>

            <a class="btn btn-ghost" href="{{ route('admin.members.index') }}">&larr; Kembali ke daftar</a>
        </div>

        @if ($member->status->isApproved())
            <p class="muted">Disetujui pada {{ $member->approved_at?->translatedFormat('d F Y H:i') }}.</p>
        @else
            <form class="action-form" method="POST" action="{{ route('admin.members.approve', $member) }}">
                @csrf
                <button class="btn btn-primary" type="submit">Setujui &amp; terbitkan nomor anggota</button>
            </form>
        @endif

        @if ($member->status->isRejected())
            <p class="muted">
                Ditolak pada {{ $member->rejected_at?->translatedFormat('d F Y H:i') }}:
                &ldquo;{{ $member->rejected_reason }}&rdquo;
            </p>
        @else
            <form class="reject-form" method="POST" action="{{ route('admin.members.reject', $member) }}">
                @csrf

                <label class="label" for="reason">Alasan penolakan (dikirim ke pemohon)</label>
                <textarea class="input textarea" id="reason" name="reason" rows="3" maxlength="500" required>{{ old('reason') }}</textarea>

                @error('reason')
                    <p class="field-error">{{ $message }}</p>
                @enderror

                <button class="btn btn-danger" type="submit">Tolak pengajuan</button>
            </form>
        @endif
    </div>

    <div class="card">
        <h2 class="card-title">Data anggota</h2>

        <dl class="kv">
            <div><dt>Email</dt><dd>{{ $member->user->email }}</dd></div>
            <div><dt>Telepon</dt><dd>{{ $member->phone ?: '—' }}</dd></div>
            <div><dt>No. KTP</dt><dd>{{ $member->ktp_number ?: '—' }}</dd></div>
            <div><dt>No. SIM</dt><dd>{{ $member->sim_number ?: '—' }}</dd></div>
            <div><dt>Jenis kelamin</dt><dd>{{ $member->gender ?: '—' }}</dd></div>
            <div><dt>Agama</dt><dd>{{ $member->religion ?: '—' }}</dd></div>
            <div><dt>Status pernikahan</dt><dd>{{ $member->marital_status ?: '—' }}</dd></div>
            <div><dt>Pekerjaan</dt><dd>{{ $member->job ?: '—' }}{{ $member->company ? ' · '.$member->company : '' }}</dd></div>
            <div><dt>Alamat</dt><dd>{{ $member->address ?: '—' }}</dd></div>
            <div>
                <dt>Kendaraan</dt>
                <dd>{{ trim(($member->vehicle_type ?? '').' '.($member->vehicle_color ?? '').' '.($member->vehicle_year ?? '')) ?: '—' }}</dd>
            </div>
            <div><dt>No. rangka / mesin</dt><dd>{{ $member->chassis_number ?: '—' }} / {{ $member->engine_number ?: '—' }}</dd></div>
            <div><dt>Pajak berikutnya</dt><dd>{{ $member->tax_due_date?->translatedFormat('d F Y') ?? '—' }}</dd></div>
        </dl>
    </div>

    <div class="card">
        <h2 class="card-title">Dokumen unggahan</h2>

        <ul class="doc-list">
            @foreach ($documents as $type => $document)
                <li>
                    <span>{{ $document['label'] }}</span>

                    @if ($document['available'])
                        <a
                            class="btn btn-ghost"
                            target="_blank"
                            rel="noopener"
                            href="{{ route('admin.members.documents.show', [$member, $type]) }}"
                        >Buka</a>
                    @else
                        <span class="muted small">Belum diunggah</span>
                    @endif
                </li>
            @endforeach
        </ul>
    </div>
@endsection
