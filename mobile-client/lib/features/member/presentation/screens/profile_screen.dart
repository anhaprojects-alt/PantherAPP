import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/models/member_model.dart';
import '../../../auth/domain/models/user_model.dart';
import '../bloc/member_bloc.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final saved = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              if (saved == true && context.mounted) {
                context.read<MemberBloc>().add(LoadProfile());
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<MemberBloc, MemberState>(
        builder: (context, state) {
          if (state is MemberLoaded) {
            return _ProfileBody(user: state.user);
          }
          if (state is MemberLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MemberError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user});

  final UserModel user;

  Future<void> _changePhoto(BuildContext context) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    if (picked != null && context.mounted) {
      context.read<MemberBloc>().add(SetAvatar(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final member = user.member;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: (member?.profilePhotoUrl != null)
                    ? NetworkImage(member!.profilePhotoUrl!)
                    : null,
                child: (member?.profilePhotoUrl == null)
                    ? const Icon(Icons.person, size: 48, color: Colors.white)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: FloatingActionButton(
                  heroTag: 'avatar',
                  mini: true,
                  onPressed: () => _changePhoto(context),
                  child: const Icon(Icons.camera_alt, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(child: Text(user.name, style: Theme.of(context).textTheme.titleLarge)),
        Center(child: Text(user.email, style: Theme.of(context).textTheme.bodyMedium)),
        const SizedBox(height: 24),
        if (member != null) ..._detailGroups(context, member),
      ],
    );
  }

  List<Widget> _detailGroups(BuildContext context, MemberModel m) {
    return [
      _section(context, 'Kontak', [
        _row('No. HP', m.phone),
        _row('Nomor KTP', m.ktpNumber),
        _row('Nomor SIM', m.simNumber),
      ]),
      _section(context, 'Pribadi', [
        _row('Agama', m.religion),
        _row('Gender', m.gender),
        _row('Status pernikahan', m.maritalStatus),
        _row('Alamat', m.address),
      ]),
      _section(context, 'Pekerjaan', [
        _row('Pekerjaan', m.job),
        _row('Perusahaan', m.company),
        _row('Alamat perusahaan', m.companyAddress),
      ]),
      _section(context, 'Kendaraan', [
        _row('Tipe', m.vehicleType),
        _row('Warna', m.vehicleColor),
        _row('Tahun', m.vehicleYear?.toString()),
        _row('Nomor rangka', m.chassisNumber),
        _row('Nomor mesin', m.engineNumber),
        _row('Jatuh tempo pajak', m.taxDueDate),
      ]),
    ];
  }

  Widget _section(BuildContext context, String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: rows),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(
            child: Text(
              (value == null || value.isEmpty) ? '-' : value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
