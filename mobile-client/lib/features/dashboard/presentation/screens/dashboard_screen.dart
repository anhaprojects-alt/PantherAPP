import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../member/presentation/bloc/member_bloc.dart';
import '../../../member/presentation/screens/documents_screen.dart';
import '../../../member/presentation/screens/profile_screen.dart';
import '../../../admin/presentation/screens/admin_pending_screen.dart';
import '../../../../core/theme/app_theme.dart';

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
      backgroundColor: AppColors.background,
      body: BlocListener<MemberBloc, MemberState>(
        listener: (context, state) {
          if (state is MemberUnauthenticated) {
            _logout();
          }
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: RefreshIndicator(
                onRefresh: () async => context.read<MemberBloc>().add(LoadProfile()),
                child: BlocBuilder<MemberBloc, MemberState>(
                  builder: (context, state) {
                    if (state is MemberLoading || state is MemberInitial) {
                      return const SizedBox(
                        height: 400,
                        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      );
                    }
                    if (state is MemberLoaded) {
                      return _buildMainContent(state.user);
                    }
                    if (state is MemberError) {
                      return _buildErrorState(state.message);
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        centerTitle: false,
        title: const Text(
          'PANTHER MANIA',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        background: const Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Color(0x0DFD0000),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMainContent(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: user.member?.profilePhotoUrl != null
                    ? ClipOval(child: CachedNetworkImage(imageUrl: user.member!.profilePhotoUrl!))
                    : const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${user.name}!',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _Status3DCard(user: user),
          ),

          const SizedBox(height: 32),
          const Text(
            'MENU UTAMA',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildMenuGrid(user),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(UserModel user) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _PremiumMenuCard(
          icon: Icons.account_circle_rounded,
          title: 'Profil Saya',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
        ),
        _PremiumMenuCard(
          icon: Icons.folder_shared_rounded,
          title: 'Dokumen',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen())),
        ),
        if (user.isAdmin)
          _PremiumMenuCard(
            icon: Icons.fact_check_rounded,
            title: 'Reviewer',
            color: Colors.orange.shade700,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPendingScreen())),
          ),
        _PremiumMenuCard(
          icon: Icons.settings_rounded,
          title: 'Pengaturan',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Text(message),
          ElevatedButton(
            onPressed: () => context.read<MemberBloc>().add(LoadProfile()),
            child: const Text('COBA LAGI'),
          ),
        ],
      ),
    );
  }
}

class _Status3DCard extends StatelessWidget {
  final UserModel user;
  const _Status3DCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final member = user.member;
    final bool isApproved = member?.status == 'approved';
    final Color statusColor = isApproved
        ? Colors.green
        : (member?.status == 'rejected' ? Colors.red : Colors.orange);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'KARTU ANGGOTA',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
              GlassContainer(
                height: 30,
                width: 100,
                blur: 10,
                color: statusColor.withOpacity(0.1),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Text(
                    member?.statusLabel?.toUpperCase() ?? 'PENDING',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            member?.memberId ?? 'PM-XXXXXXXX',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.name.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PremiumMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _PremiumMenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.ink.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
