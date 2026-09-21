import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/models/registration_data.dart';

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
        const SnackBar(content: Text('Lengkapi ketiga dokumen (KTP, SIM, bukti bayar).')),
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
      appBar: AppBar(title: const Text('Daftar Member')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegisterSubmitted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Pendaftaran terkirim'),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Kembali ke Login'),
                  ),
                ],
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _field(_name, 'Nama lengkap', TextInputType.name),
                _field(_email, 'Email', TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null),
                _field(_password, 'Password', TextInputType.visiblePassword, obscure: true,
                    validator: (v) => (v == null || v.length < 10)
                        ? 'Minimal 10 karakter'
                        : null),
                _field(_confirmPassword, 'Konfirmasi password', TextInputType.visiblePassword,
                    obscure: true,
                    validator: (v) => v != _password.text ? 'Password tidak sama' : null),
                _field(_phone, 'No. HP', TextInputType.phone),
                _field(_ktpNumber, 'Nomor KTP', TextInputType.number),
                _field(_simNumber, 'Nomor SIM', TextInputType.text),
                const SizedBox(height: 8),
                const Text('Unggah dokumen', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _docTile('ktp', 'Foto KTP'),
                _docTile('sim', 'Foto SIM'),
                _docTile('payment', 'Bukti Pembayaran'),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Kirim Pendaftaran'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, TextInputType type,
      {bool obscure = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: validator,
      ),
    );
  }

  Widget _docTile(String key, String label) {
    final picked = _documents[key];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label),
        subtitle: Text(picked == null ? 'Belum dipilih' : picked.name),
        trailing: TextButton(
          onPressed: () => _pick(key),
          child: const Text('Pilih'),
        ),
      ),
    );
  }
}
