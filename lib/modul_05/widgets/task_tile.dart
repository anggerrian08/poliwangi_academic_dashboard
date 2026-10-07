import 'package:flutter/material.dart';
import 'package:poliwangi_academic_dashboard/modul_05/models/task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final Task task;
  final ValueChanged<Task> onToggle;
  final ValueChanged<Task> onDelete;

  @override
  Widget build(BuildContext context) {
    final DateTime? tanggal = Task.bacaTanggal(task);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: CheckboxListTile(
        value: task.done,
        onChanged: (_) => onToggle(task),
        controlAffinity: ListTileControlAffinity.leading,
        secondary: IconButton(
          onPressed: () => onDelete(task),
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Hapus tugas',
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(task.course),
            if (tanggal != null)
              Text(
                '${tanggal.day}/${tanggal.month}/${tanggal.year}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}
