import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../bloc/admin_bloc.dart';
import '../../domain/models/admin_member.dart';
import 'admin_detail_screen.dart';

class AdminPendingScreen extends StatefulWidget {
  const AdminPendingScreen({super.key});

  @override
  State<AdminPendingScreen> createState() => _AdminPendingScreenState();
}

class _AdminPendingScreenState extends State<AdminPendingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AdminBloc>().add(LoadPending()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pendaftaran Menunggu')),
      body: BlocListener<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminUnauthenticated) {
            context.read<AuthBloc>().add(LogoutRequested());
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async => context.read<AdminBloc>().add(LoadPending()),
          child: BlocBuilder<AdminBloc, AdminState>(
            builder: (context, state) {
              if (state is AdminLoading || state is AdminInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AdminError) {
                return ListView(
                  children: [
                    const SizedBox(height: 120),
                    Center(child: Text(state.message)),
                  ],
                );
              }
              if (state is AdminListLoaded) {
                if (state.items.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('Tidak ada pendaftaran baru.')),
                    ],
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _ApplicantCard(applicant: item);
                  },
                );
              }
              return ListView(children: const [SizedBox(height: 200)]);
            },
          ),
        ),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({required this.applicant});

  final AdminApplicant applicant;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(applicant.name ?? 'Tanpa nama'),
        subtitle: Text('${applicant.email ?? '-'}\nHP: ${applicant.phone ?? '-'}'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Muat detail spesifik lalu buka layar review.
          context.read<AdminBloc>().add(LoadDetail(applicant.id));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDetailScreen(id: applicant.id),
            ),
          );
        },
      ),
    );
  }
}
