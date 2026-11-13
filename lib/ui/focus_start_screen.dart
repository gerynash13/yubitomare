import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../storage.dart';
import 'focus_session_screen.dart';
import 'theme.dart';
import 'tomarin_ui.dart';

class FocusStartScreen extends StatefulWidget {
  const FocusStartScreen({super.key});

  @override
  State<FocusStartScreen> createState() => _FocusStartScreenState();
}

class _FocusStartScreenState extends State<FocusStartScreen> {
  final _goalCtl = TextEditingController();
  List<Task> _tasks = [];
  int? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _goalCtl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final all = await Store.loadTasks();
    if (!mounted) return;
    setState(() {
      _tasks = all.where((t) => !t.done).toList();
      _selected = _tasks.isEmpty ? null : 0;
    });
  }

  void _start() {
    final task = _selected == null ? '' : _tasks[_selected!].text;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FocusSessionScreen(task: task, goal: _goalCtl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            children: [
              const Center(child: TomarinSprite(Pose.sleepy, height: 130)),
              const SizedBox(height: 12),
              Center(child: Text(l.fsTitle, style: T.shout(26))),
              const SizedBox(height: 18),
              if (_tasks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: T.paperLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l.fsNoTasks,
                    style: T.body(14, color: T.inkSoft, weight: FontWeight.w600),
                  ),
                ),
              for (var i = 0; i < _tasks.length; i++) _taskCard(i),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: T.paperLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: T.line),
                ),
                child: TextField(
                  controller: _goalCtl,
                  style: T.body(15),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.edit_note, color: T.persimmonDeep),
                    hintText: l.fsGoalHint,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _start,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: T.persimmon,
                    foregroundColor: T.ink,
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  child: Text(l.fsStart, style: T.shout(20)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.fsNote,
                textAlign: TextAlign.center,
                style: T.body(12, color: T.inkSoft),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _taskCard(int i) {
    final selected = _selected == i;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected ? T.paperHigh : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? T.vermilion : Colors.transparent, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selected = i),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? T.vermilion : T.line,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(_tasks[i].text, style: T.body(16, weight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}