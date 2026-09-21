import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../bloc/admin_bloc.dart';
import '../../domain/models/admin_member.dart';

class AdminDetailScreen extends StatefulWidget {
  const AdminDetailScreen({super.key, required this.id});

  final int id;

  @override
  State<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends State<AdminDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AdminBloc>().add(LoadDetail(widget.id)),
    );
  }

  Future<void> _approve(AdminMember member) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Setujui pendaftaran?'),
        content: Text('Member ${member.userName ?? '-'} akan mendapat nomor anggota.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Setujui')),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<AdminBloc>().add(ApproveMember(member.id));
    }
  }

  Future<void> _reject(AdminMember member) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Tolak pendaftaran'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Alasan penolakan'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Batal')),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogCtx).pop(controller.text.trim()),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (reason != null && reason.isNotEmpty && mounted) {
      context.read<AdminBloc>().add(RejectMember(member.id, reason));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pendaftaran')),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminUnauthenticated) {
            context.read<AuthBloc>().add(LogoutRequested());
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AdminDetailLoaded) {
            return _Detail(member: state.member, onApprove: _approve, onReject: _reject);
          }
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.member,
    required this.onApprove,
    required this.onReject,
  });

  final AdminMember member;
  final Future<void> Function(AdminMember) onApprove;
  final Future<void> Function(AdminMember) onReject;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(member.userName ?? '-', style: Theme.of(context).textTheme.titleLarge),
        Text(member.userEmail ?? '', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        Chip(label: Text(member.statusLabel ?? member.status ?? '-')),
        const SizedBox(height: 16),
        _info('No. HP', member.phone),
        _info('Nomor KTP', member.ktpNumber),
        _info('Nomor SIM', member.simNumber),
        _info('Agama', member.religion),
        _info('Gender', member.gender),
        _info('Status nikah', member.maritalStatus),
        _info('Alamat', member.address),
        _info('Pekerjaan', member.job),
        _info('Perusahaan', member.company),
        _info('Kendaraan', member.vehicleType),
        _info('Warna', member.vehicleColor),
        _info('Tahun', member.vehicleYear?.toString()),
        _info('Nomor rangka', member.chassisNumber),
        _info('Nomor mesin', member.engineNumber),
        _info('Jatuh tempo pajak', member.taxDueDate),
        const SizedBox(height: 16),
        const Text('Dokumen', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['ktp', 'sim', 'payment']
              .map((t) => ActionChip(
                    label: Text(t.toUpperCase()),
                    avatar: const Icon(Icons.image, size: 18),
                    onPressed: () => _openDocument(context, t),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),
        if (member.isPending) ...[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            icon: const Icon(Icons.check),
            label: const Text('Setujui'),
            onPressed: () => onApprove(member),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            icon: const Icon(Icons.close),
            label: const Text('Tolak'),
            onPressed: () => onReject(member),
          ),
        ] else
          Center(child: Text('Sudah diproses: ${member.statusLabel ?? member.status}')),
      ],
    );
  }

  void _openDocument(BuildContext context, String type) {
    context.read<AdminBloc>().add(ViewMemberDocument(member.id, type));
    showDialog(
      context: context,
      builder: (_) => BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          final bytes = (state is AdminDocumentLoaded) ? state.bytes : null;
          return AlertDialog(
            title: Text('Dokumen ${type.toUpperCase()}'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: bytes == null
                  ? const Center(child: CircularProgressIndicator())
                  : InteractiveViewer(child: Image.memory(bytes)),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
            ],
          );
        },
      ),
    );
  }

  Widget _info(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text((value == null || value.isEmpty) ? '-' : value)),
        ],
      ),
    );
  }
}
