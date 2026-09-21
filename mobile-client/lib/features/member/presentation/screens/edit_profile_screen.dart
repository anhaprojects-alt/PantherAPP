import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/member_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _religion;
  late final TextEditingController _address;
  late final TextEditingController _job;
  late final TextEditingController _company;
  late final TextEditingController _companyAddress;
  late final TextEditingController _vehicleType;
  late final TextEditingController _vehicleColor;
  late final TextEditingController _vehicleYear;
  late final TextEditingController _chassisNumber;
  late final TextEditingController _engineNumber;
  late final TextEditingController _taxDueDate;

  String? _gender;
  String? _marital;

  @override
  void initState() {
    super.initState();
    final member = (context.read<MemberBloc>().state is MemberLoaded)
        ? (context.read<MemberBloc>().state as MemberLoaded).user.member
        : null;

    _religion = TextEditingController(text: member?.religion ?? '');
    _address = TextEditingController(text: member?.address ?? '');
    _job = TextEditingController(text: member?.job ?? '');
    _company = TextEditingController(text: member?.company ?? '');
    _companyAddress = TextEditingController(text: member?.companyAddress ?? '');
    _vehicleType = TextEditingController(text: member?.vehicleType ?? '');
    _vehicleColor = TextEditingController(text: member?.vehicleColor ?? '');
    _vehicleYear =
        TextEditingController(text: member?.vehicleYear?.toString() ?? '');
    _chassisNumber = TextEditingController(text: member?.chassisNumber ?? '');
    _engineNumber = TextEditingController(text: member?.engineNumber ?? '');
    _taxDueDate = TextEditingController(text: member?.taxDueDate ?? '');
    _gender = member?.gender;
    _marital = member?.maritalStatus;
  }

  @override
  void dispose() {
    for (final c in [
      _religion, _address, _job, _company, _companyAddress,
      _vehicleType, _vehicleColor, _vehicleYear, _chassisNumber,
      _engineNumber, _taxDueDate,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final fields = <String, dynamic>{
      'religion': _religion.text.trim(),
      'gender': _gender,
      'marital_status': _marital,
      'address': _address.text.trim(),
      'job': _job.text.trim(),
      'company': _company.text.trim(),
      'company_address': _companyAddress.text.trim(),
      'vehicle_type': _vehicleType.text.trim(),
      'vehicle_color': _vehicleColor.text.trim(),
      'vehicle_year': _vehicleYear.text.trim().isEmpty
          ? null
          : int.tryParse(_vehicleYear.text.trim()),
      'chassis_number': _chassisNumber.text.trim(),
      'engine_number': _engineNumber.text.trim(),
      'tax_due_date': _taxDueDate.text.trim(),
    };
    context.read<MemberBloc>().add(SaveProfile(fields));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: BlocListener<MemberBloc, MemberState>(
        listener: (context, state) {
          if (state is MemberLoaded) {
            Navigator.pop(context, true);
          } else if (state is MemberError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _field(_religion, 'Agama'),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _marital,
                decoration: const InputDecoration(labelText: 'Status pernikahan'),
                items: const [
                  DropdownMenuItem(value: 'single', child: Text('Belum menikah')),
                  DropdownMenuItem(value: 'married', child: Text('Menikah')),
                ],
                onChanged: (v) => setState(() => _marital = v),
              ),
              const SizedBox(height: 16),
              _field(_address, 'Alamat'),
              _field(_job, 'Pekerjaan'),
              _field(_company, 'Perusahaan'),
              _field(_companyAddress, 'Alamat perusahaan'),
              _field(_vehicleType, 'Tipe kendaraan'),
              _field(_vehicleColor, 'Warna kendaraan'),
              _field(_vehicleYear, 'Tahun kendaraan', number: true),
              _field(_chassisNumber, 'Nomor rangka'),
              _field(_engineNumber, 'Nomor mesin'),
              _field(_taxDueDate, 'Jatuh tempo pajak (YYYY-MM-DD)'),
              const SizedBox(height: 24),
              BlocBuilder<MemberBloc, MemberState>(
                builder: (context, state) {
                  final loading = state is MemberLoading;
                  return ElevatedButton(
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Simpan'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (number) {
          final v = controller.text.trim();
          if (number is String && v.isNotEmpty && int.tryParse(v) == null) {
            return 'Harus angka';
          }
          return null;
        },
      ),
    );
  }
}
