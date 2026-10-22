import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'storage.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _ctl = TextEditingController();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final t = await Store.loadTasks();
    setState(() => _tasks = t);
  }

  Future<void> _add() async {
    final text = _ctl.text.trim();
    if (text.isEmpty) return;
    setState(() => _tasks.add(Task(text)));
    _ctl.clear();
    await Store.saveTasks(_tasks);
  }

  Future<void> _toggle(Task t) async {
    setState(() => t.done = !t.done);
    await Store.saveTasks(_tasks);
  }

  Future<void> _remove(Task t) async {
    setState(() => _tasks.remove(t));
    await Store.saveTasks(_tasks);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final done = _tasks.where((t) => t.done).length;
    return Scaffold(
      appBar: AppBar(title: Text(l.tasksTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.tasksDone(done, _tasks.length)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctl,
                  decoration: InputDecoration(labelText: l.addTaskLabel),
                  onSubmitted: (_) => _add(),
                ),
              ),
              IconButton(onPressed: _add, icon: const Icon(Icons.add)),
            ]),
            Expanded(
              child: ListView(
                children: _tasks
                    .map((t) => Dismissible(
                          key: ObjectKey(t),
                          onDismissed: (_) => _remove(t),
                          child: CheckboxListTile(
                            value: t.done,
                            onChanged: (_) => _toggle(t),
                            title: Text(
                              t.text,
                              style: TextStyle(
                                decoration:
                                    t.done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}