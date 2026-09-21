import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/akademis_bloc.dart';
import '../../../../injection_container.dart';

class TugasScreen extends StatelessWidget {
  const TugasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AkademisBloc>()..add(GetTugasRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Daftar Tugas')),
        body: BlocBuilder<AkademisBloc, AkademisState>(
          builder: (context, state) {
            if (state is AkademisLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AkademisLoaded) {
              return ListView.builder(
                itemCount: state.tugasList.length,
                itemBuilder: (context, index) {
                  final tugas = state.tugasList[index];
                  return ListTile(
                    title: Text(tugas.title),
                    subtitle: Text(tugas.description),
                    trailing: Icon(
                      tugas.isCompleted ? Icons.check_circle : Icons.pending,
                      color: tugas.isCompleted ? Colors.green : Colors.orange,
                    ),
                  );
                },
              );
            } else if (state is AkademisError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Belum ada data'));
          },
        ),
      ),
    );
  }
}
