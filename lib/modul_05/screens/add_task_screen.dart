import 'package:flutter/material.dart';
import 'package:poliwangi_academic_dashboard/modul_05/models/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _prioritasController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _prioritasController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final Task taskBaru = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      course: _courseController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
      prioritas: int.tryParse(_prioritasController.text.trim()) ?? 2,
    );

    Navigator.of(context).pop(taskBaru);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tugas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // const Text(
              //   'Tambah Tugas',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              // ),
              const SizedBox(height: 20),
              _buildField(
                label: 'Judul',
                controller: _titleController,
                hint: 'Mengerjakan tugas modul 05',
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tugas wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Kursus',
                controller: _courseController,
                hint: 'Pemrograman Perangkat Bergerak',
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kursus wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Prioritas',
                controller: _prioritasController,
                hint: '3',
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Prioritas wajib diisi';
                  }
                  final int? sks = int.tryParse(value.trim());
                  if (sks == null || sks < 1 || sks > 3) {
                    return 'Masukkan angka 1 sampai 3';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _simpan,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          key: _fieldKey(label),
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  ValueKey<String> _fieldKey(String label) => ValueKey<String>('field_$label');
}
