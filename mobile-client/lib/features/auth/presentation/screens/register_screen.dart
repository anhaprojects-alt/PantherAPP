import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/models/registration_data.dart';
import '../../../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _phone = TextEditingController();
  final _ktpNumber = TextEditingController();
  final _simNumber = TextEditingController();

  final Map<String, XFile?> _documents = {'ktp': null, 'sim': null, 'payment': null};

  @override
  void dispose() {
    for (final c in [
      _name, _email, _password, _confirmPassword, _phone, _ktpNumber, _simNumber
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick(String key) async {
    final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (file != null) {
      setState(() => _documents[key] = file);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_documents['ktp'] == null ||
        _documents['sim'] == null ||
        _documents['payment'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi ketiga dokumen (KTP, SIM, bukti bayar).'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(
      RegisterRequested(
        RegistrationData(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          phone: _phone.text.trim(),
          ktpNumber: _ktpNumber.text.trim(),
          simNumber: _simNumber.text.trim(),
          ktpPath: _documents['ktp']!.path,
          simPath: _documents['sim']!.path,
          paymentPath: _documents['payment']!.path,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PENDAFTARAN MEMBER'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegisterSubmitted) {
            _showSuccessDialog(state.message);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.primary));
          }
        },
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                FadeInDown(
                  child: const Text(
                    'Gabung Komunitas',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                ),
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    'Isi data diri Anda dengan lengkap sesuai identitas resmi.',
                    style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 32),

                _buildSectionTitle('INFORMASI AKUN'),
                _field(_name, 'Nama Lengkap', Icons.person_outline),
                _field(_email, 'Email Address', Icons.email_outlined, type: TextInputType.emailAddress),
                _field(_password, 'Password', Icons.lock_outline, obscure: true),
                _field(_confirmPassword, 'Konfirmasi Password', Icons.lock_reset_rounded, obscure: true),

                const SizedBox(height: 24),
                _buildSectionTitle('DATA IDENTITAS'),
                _field(_phone, 'Nomor HP', Icons.phone_android_rounded, type: TextInputType.phone),
                _field(_ktpNumber, 'Nomor KTP', Icons.badge_outlined, type: TextInputType.number),
                _field(_simNumber, 'Nomor SIM', Icons.drive_eta_outlined),

                const SizedBox(height: 24),
                _buildSectionTitle('UNGGAH DOKUMEN'),
                _docTile('ktp', 'Foto KTP'),
                _docTile('sim', 'Foto SIM'),
                _docTile('payment', 'Bukti Pembayaran Registrasi'),

                const SizedBox(height: 40),
                FadeInUp(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoading;
                      return ElevatedButton(
                        onPressed: loading ? null : _submit,
                        child: loading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('KIRIM PENDAFTARAN'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.primary),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
      {bool obscure = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FadeInLeft(
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: type,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Wajib diisi';
            if (label == 'Email Address' && !v.contains('@')) return 'Email tidak valid';
            if (label == 'Password' && v.length < 10) return 'Minimal 10 karakter';
            return null;
          },
        ),
      ),
    );
  }

  Widget _docTile(String key, String label) {
    final picked = _documents[key];
    return FadeInRight(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: picked != null ? AppColors.primary : AppColors.ink.withOpacity(0.05)),
        ),
        child: ListTile(
          leading: Icon(picked != null ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                       color: picked != null ? Colors.green : AppColors.muted),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(picked == null ? 'Pilih file gambar' : picked.name,
                        style: TextStyle(fontSize: 12, color: picked != null ? AppColors.primary : AppColors.muted)),
          trailing: TextButton(
            onPressed: () => _pick(key),
            child: const Text('PILIH', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ZoomIn(
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 60),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('BERHASIL!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(120, 45)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OKE'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
