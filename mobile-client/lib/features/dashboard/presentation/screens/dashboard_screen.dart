import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../member/presentation/bloc/member_bloc.dart';
import '../../../member/presentation/screens/documents_screen.dart';
import '../../../member/presentation/screens/profile_screen.dart';
import '../../../admin/presentation/screens/admin_pending_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MemberBloc>().add(LoadProfile()),
    );
  }

  void _logout() {
    context.read<AuthBloc>().add(LogoutRequested());
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panther Mania'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: BlocListener<MemberBloc, MemberState>(
        listener: (context, state) {
          if (state is MemberUnauthenticated) {
            context.read<AuthBloc>().add(LogoutRequested());
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async => context.read<MemberBloc>().add(LoadProfile()),
          child: BlocBuilder<MemberBloc, MemberState>(
            builder: (context, state) {
              if (state is MemberLoading || state is MemberInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is MemberLoaded) {
                return _content(state.user);
              }
              if (state is MemberError) {
                return ListView(
                  children: [
                    const SizedBox(height: 120),
                    Center(child: Text(state.message)),
                    Center(
                      child: TextButton(
                        onPressed: () => context.read<MemberBloc>().add(LoadProfile()),
                        child: const Text('Coba lagi'),
                      ),
                    ),
                  ],
                );
              }
              return ListView(children: const [SizedBox(height: 200)]);
            },
          ),
        ),
      ),
    );
  }

  Widget _content(UserModel user) {
    final member = user.member;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Halo, ${user.name}!',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _StatusCard(user: user),
        const SizedBox(height: 24),
        _MenuTile(
          icon: Icons.person,
          color: Colors.indigo,
          title: 'Profil Saya',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.description,
          color: Colors.teal,
          title: 'Dokumen Saya',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DocumentsScreen()),
          ),
        ),
        if (user.isAdmin)
          _MenuTile(
            icon: Icons.fact_check,
            color: Colors.orange,
            title: 'Review Pendaftaran',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminPendingScreen()),
            ),
          ),
        if (member == null)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Akun admin tanpa profil member.'),
          ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final member = user.member;
    final color = switch (member?.status) {
      'approved' => Colors.green,
      'rejected' => Colors.red,
      'pending' => Colors.orange,
      _ => Colors.grey,
    };
    final label = member?.statusLabel ?? (user.isAdmin ? 'Administrator' : 'Belum ada status');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Membership',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(label,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (member?.memberId != null) ...[
              const SizedBox(height: 10),
              Text('No. Member: ${member!.memberId}'),
            ],
            if (member?.isRejected == true && member?.rejectedReason != null) ...[
              const SizedBox(height: 6),
              Text('Alasan: ${member!.rejectedReason}',
                  style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
