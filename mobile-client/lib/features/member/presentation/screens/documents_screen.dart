import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/member_bloc.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  static const _labels = {
    'ktp': 'KTP',
    'sim': 'SIM',
    'payment': 'Bukti Pembayaran',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dokumen Saya')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Dokumen hanya dapat dibuka lewat koneksi terautentikasi.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ..._labels.entries.map(
            (e) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.description),
                title: Text(e.value),
                trailing: const Icon(Icons.visibility),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _DocumentViewer(type: e.key, label: e.value),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentViewer extends StatefulWidget {
  const _DocumentViewer({required this.type, required this.label});

  final String type;
  final String label;

  @override
  State<_DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<_DocumentViewer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MemberBloc>().add(ViewDocument(widget.type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.label)),
      body: BlocConsumer<MemberBloc, MemberState>(
        listenWhen: (prev, curr) => curr is MemberError,
        listener: (context, state) {
          if (state is MemberError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is DocumentLoaded && state.type == widget.type) {
            return InteractiveViewer(
              child: Image.memory(state.bytes, fit: BoxFit.contain),
            );
          }
          if (state is MemberLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MemberError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  TextButton(
                    onPressed: () =>
                        context.read<MemberBloc>().add(ViewDocument(widget.type)),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Memuat dokumen...'));
        },
      ),
    );
  }
}
