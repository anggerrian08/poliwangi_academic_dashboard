import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poliwangi_academic_dashboard/modul_05/models/task.dart';
import 'package:poliwangi_academic_dashboard/modul_05/screens/add_task_screen.dart';
import 'package:poliwangi_academic_dashboard/modul_05/services/task_storage.dart';
import 'package:poliwangi_academic_dashboard/modul_05/widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, this.storage});

  /// Dapat disuntikkan dari luar (widget test atau praktikum keadaan memuat).
  final TaskStorage? storage;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late final TaskStorage _storage = widget.storage ?? const TaskStorage();

  List<Task>? _tugas;
  Object? _error;
  bool _sedangMenyimpan = false;

  @override
  void initState() {
    super.initState();
    unawaited(_muat());
  }

  Future<void> _muat() async {
    setState(() {
      _tugas = null;
      _error = null;
    });

    try {
      final List<Task> hasil = await _storage.muat();
      if (!mounted) return;
      setState(() => _tugas = hasil);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<bool> _simpanDaftar(
    List<Task> daftarBaru, {
    String? pesan,
    List<Task>? daftarSebelumnya,
  }) async {
    final List<Task>? cadangan = daftarSebelumnya ?? _tugas;

    setState(() {
      _tugas = daftarBaru;
      _sedangMenyimpan = true;
    });

    try {
      await _storage.simpan(daftarBaru);
      if (!mounted) return true;
      setState(() => _sedangMenyimpan = false);
      if (pesan != null) _pesan(pesan);
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _tugas = cadangan;
        _sedangMenyimpan = false;
      });
      _pesan('Gagal menyimpan: ${_rapikanPesan(e)}');
      return false;
    }
  }

  Future<void> _ubahStatus(Task tugas) async {
    final List<Task>? sekarang = _tugas;
    if (sekarang == null) return;

    final List<Task> baru = sekarang
        .map((Task t) => t.id == tugas.id ? t.copyWith(done: !t.done) : t)
        .toList(growable: true);

    await _simpanDaftar(baru, daftarSebelumnya: sekarang);
  }

  Future<void> _hapusTugas(Task tugas) async {
    final List<Task>? sekarang = _tugas;
    if (sekarang == null) return;

    final List<Task> baru = sekarang
        .where((Task item) => item.id != tugas.id)
        .toList(growable: true);

    await _simpanDaftar(
      baru,
      pesan: 'Tugas dihapus',
      daftarSebelumnya: sekarang,
    );
  }

  Future<void> _tambahTugas() async {
    final Task? tugasBaru = await Navigator.of(context).push<Task>(
      MaterialPageRoute<Task>(
        builder: (BuildContext context) => const AddTaskScreen(),
      ),
    );

    if (tugasBaru == null) return;

    final List<Task> sekarang = List<Task>.from(
      _tugas ?? <Task>[],
      growable: true,
    );

    await _simpanDaftar(
      <Task>[tugasBaru, ...sekarang],
      pesan: 'Tugas ditambahkan',
      daftarSebelumnya: sekarang,
    );
  }

  void _pesan(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  String _rapikanPesan(Object e) {
    if (e is FormatException) return e.message;
    final String teks = e.toString();
    return teks.startsWith('Exception: ')
        ? teks.substring('Exception: '.length)
        : teks;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _tampilanGagal();
    }

    if (_tugas == null) {
      return _tampilanMemuat();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tugas')),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahTugas,
        child: const Icon(Icons.add),
      ),
      body: _tugas!.isEmpty ? _tampilanKosong() : _tampilanDaftar(),
    );
  }

  Widget _tampilanDaftar() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: _tugas!.length,
      itemBuilder: (BuildContext context, int index) {
        final Task tugas = _tugas![index];
        return TaskTile(
          task: tugas,
          onToggle: _ubahStatus,
          onDelete: _hapusTugas,
        );
      },
    );
  }

  Widget _tampilanKosong() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.task_alt, size: 52),
          SizedBox(height: 16),
          Text(
            'Belum ada tugas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text('Tekan tombol + untuk menambahkan tugas baru.'),
        ],
      ),
    );
  }

  Widget _tampilanGagal() {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tugas')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline, size: 52, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat data tugas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _rapikanPesan(
                  _error ?? const FormatException('Tidak diketahui'),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _muat,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tampilanMemuat() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat tugas dari penyimpanan...'),
          ],
        ),
      ),
    );
  }
}
