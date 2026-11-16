import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bond.dart';
import '../debug_page.dart';
import '../intercept_log.dart';
import '../l10n/app_localizations.dart';
import '../settings_screen.dart';
import '../storage.dart';
import '../tracker_config.dart';
import 'theme.dart';
import 'tomarin_ui.dart';

enum _Status { running, paused, missing }

class TodayScreen extends StatefulWidget {
  final VoidCallback onStartFocus;
  const TodayScreen({super.key, required this.onStartFocus});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with WidgetsBindingObserver {
  static const _channel = MethodChannel('detox_pet/usage');
  final _addCtl = TextEditingController();

  List<Task> _tasks = []; // every task, saved as a whole
  BondState _bond = BondState();
  int _passes = 0;
  int _appCount = 0;
  _Status _status = _Status.paused;

  /// Undone tasks, plus tasks finished today. Tasks finished on an earlier day
  /// stay in storage (for the Record tab later) but leave this list.
  List<Task> get _visibleTasks {
    final today = Store.todayKey();
    return _tasks.where((t) => !t.done || t.doneOn == today).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _addCtl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from a settings page: check the status again.
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final tasks = await Store.loadTasks();
    // Tasks finished before "finished on" existed: count them as finished today.
    final today = Store.todayKey();
    var migrated = false;
    for (final t in tasks) {
      if (t.done && t.doneOn == null) {
        t.doneOn = today;
        migrated = true;
      }
    }
    if (migrated) await Store.saveTasks(tasks);

    final bond = await Bond.load();
    final passes = await InterceptLog.passesToday();
    final cfg = await TrackerConfig.load();
    final usage = await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;
    final overlay = await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final running = prefs.getBool('tracker_running') ?? false;
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _bond = bond;
      _passes = passes;
      _appCount = cfg.apps.length;
      _status = (!usage || !overlay)
          ? _Status.missing
          : (running ? _Status.running : _Status.paused);
    });
  }

  Future<void> _statusAction() async {
    if (_status == _Status.missing) {
      final usage = await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;
      await _channel.invokeMethod(usage ? 'openOverlaySettings' : 'openUsageSettings');
    } else if (_status == _Status.paused) {
      await _channel.invokeMethod('startTracker');
      await Future.delayed(const Duration(milliseconds: 700));
      _load();
    }
  }

  /// Pausing loosens the guard, so Tomarin asks first. "Never mind" is the loud button.
  Future<void> _confirmPause() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.pauseTitle),
        content: Text(l.pauseBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.pauseConfirm),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.pauseCancel),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _channel.invokeMethod('stopTracker');
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) _load();
  }

  Future<void> _add() async {
    final text = _addCtl.text.trim();
    if (text.isEmpty) return;
    setState(() => _tasks.add(Task(text)));
    _addCtl.clear();
    await Store.saveTasks(_tasks);
  }

  Future<void> _remove(Task t) async {
    setState(() => _tasks.remove(t));
    await Store.saveTasks(_tasks);
  }

  Future<void> _toggle(Task t) async {
    if (t.done) return; // finished tasks are final
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.taskDoneTitle),
        content: Text(l.taskDoneBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.taskDoneNot),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.taskDoneYes),
          ),
        ],
      ),
    );
    if (ok != true || !mounted || t.done) return;
    setState(() {
      t.done = true;
      t.doneOn = Store.todayKey();
    });
    await Store.saveTasks(_tasks);
    final r = await Bond.addTaskDone();
    final bond = await Bond.load();
    if (!mounted) return;
    setState(() => _bond = bond);
    if (r.gained > 0) {
      final msg = r.leveledUp
          ? '${l.bondGainSmall(r.gained)}  ${l.bondUp}'
          : l.bondGainSmall(r.gained);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  /// Long press on an unfinished task: edit or delete. Finished tasks are a record
  /// of the day and cannot be changed.
  Future<void> _showTaskMenu(Task t) async {
    if (t.done) return;
    HapticFeedback.mediumImpact();
    final l = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: T.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                t.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: T.body(16, weight: FontWeight.w800),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l.taskEdit, style: T.body(16, weight: FontWeight.w700)),
              onTap: () => Navigator.pop(sheetCtx, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: T.vermilion),
              title: Text(
                l.taskDelete,
                style: T.body(16, color: T.vermilion, weight: FontWeight.w700),
              ),
              onTap: () => Navigator.pop(sheetCtx, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'delete') await _remove(t);
    if (action == 'edit') await _edit(t);
  }

  Future<void> _edit(Task t) async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => _EditTaskDialog(initial: t.text),
    );
    if (text == null || text.trim().isEmpty) return;
    setState(() => t.text = text.trim());
    await Store.saveTasks(_tasks);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final level = Bond.levelFor(_bond.points);
    final nextTask = _tasks.where((t) => !t.done).map((t) => t.text).firstOrNull;
    final now = DateTime.now();
    final shown = _visibleTasks;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _header(l),
        if (_status == _Status.running)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _confirmPause,
              icon: const Icon(Icons.pause_circle_outline, size: 18),
              label: Text(
                l.statusPause,
                style: T.body(12, weight: FontWeight.w700),
              ),
              style: TextButton.styleFrom(
                foregroundColor: T.inkSoft,
                visualDensity: VisualDensity.compact,
              ),
            ),
          )
        else ...[
          const SizedBox(height: 8),
          _statusStrip(l),
        ],
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: _Tag(
                text: l.todayBond(level + 1, l.bondLevelName(level.toString())),
                icon: Icons.favorite_border,
                color: T.persimmon.withValues(alpha: 0.4),
                angle: -0.03,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _Tag(
                text: l.interceptTag(_passes, InterceptLog.dailyPasses),
                icon: Icons.timer_outlined,
                color: T.paperHigh,
                angle: 0.03,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _BondBranch(progress: Bond.progress(_bond.points)),
        const SizedBox(height: 4),
        PaperCard(
          tape: true,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: T.paperHigh,
                child: Icon(Icons.priority_high, size: 18, color: T.vermilion),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.todayNagTitle, style: T.shout(20, color: T.vermilion)),
                    const SizedBox(height: 4),
                    Text(
                      nextTask == null ? l.todayNagEmpty : l.todayNag(nextTask),
                      style: T.body(14, color: T.inkSoft, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Container(width: 6, height: 22, color: T.vermilion),
            const SizedBox(width: 8),
            Text(l.todayTasksTitle, style: T.shout(19)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: T.paperHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${now.month}/${now.day}',
                style: T.body(12, color: T.vermilion, weight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_tasks.any((t) => !t.done))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l.taskHint, style: T.body(12, color: T.inkSoft)),
          ),
        for (final t in shown) _taskRow(l, t),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
          decoration: BoxDecoration(
            color: T.paperLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: T.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addCtl,
                  onSubmitted: (_) => _add(),
                  style: T.body(15),
                  decoration: InputDecoration(
                    hintText: l.addTaskLabel,
                    border: InputBorder.none,
                  ),
                ),
              ),
              FilledButton(
                onPressed: _add,
                style: FilledButton.styleFrom(backgroundColor: T.persimmon, foregroundColor: T.ink),
                child: Text(l.todayAdd, style: T.body(14, weight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 78,
          child: ElevatedButton(
            onPressed: widget.onStartFocus,
            style: ElevatedButton.styleFrom(
              backgroundColor: T.persimmon,
              foregroundColor: T.ink,
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(39)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.hourglass_empty),
                    const SizedBox(width: 8),
                    Text(l.todayStartFocus, style: T.shout(22)),
                  ],
                ),
                Text(l.todayStartFocusSub, style: T.body(12, weight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(AppLocalizations l) {
    final (chip, color) = switch (_status) {
      _Status.running => (l.statusRunning(_appCount), T.persimmonDeep),
      _Status.paused => (l.statusPaused, T.inkSoft),
      _Status.missing => (l.statusMissing, T.vermilion),
    };
    return Row(
      children: [
        // Long-press the logo for the developer page (permissions, test buttons).
        GestureDetector(
          onLongPress: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DebugPage()),
          ),
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: T.persimmon,
            child: Icon(Icons.location_on, color: T.ink),
          ),
        ),
        const SizedBox(width: 10),
        Text(l.appTitle, style: T.shout(20)),
        const SizedBox(width: 8),
        // The chip takes whatever room is left and shortens its text if it must,
        // so the row can never overflow.
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: T.paperLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: T.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      chip,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: T.body(12, color: color, weight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SettingsScreen()))
              .then((_) => _load()),
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: T.vermilion,
            child: Icon(Icons.person_outline, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _statusStrip(AppLocalizations l) {
    final missing = _status == _Status.missing;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: missing ? T.paperHigh : T.paperLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: missing ? T.vermilion : T.line),
      ),
      child: Row(
        children: [
          Icon(
            missing ? Icons.warning_amber_rounded : Icons.pause_circle_outline,
            color: missing ? T.vermilion : T.inkSoft,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              missing ? l.statusMissingSub : l.statusPausedSub,
              style: T.body(13, weight: FontWeight.w700),
            ),
          ),
          FilledButton(
            onPressed: _statusAction,
            style: FilledButton.styleFrom(
              backgroundColor: missing ? T.vermilion : T.persimmon,
              foregroundColor: missing ? Colors.white : T.ink,
            ),
            child: Text(
              missing ? l.statusFix : l.statusResume,
              style: T.body(13, weight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskRow(AppLocalizations l, Task t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: t.done ? T.paperLow : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: t.done ? null : () => _toggle(t),
        onLongPress: t.done ? null : () => _showTaskMenu(t),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.done ? T.vermilion : Colors.transparent,
                  border: Border.all(color: t.done ? T.vermilion : T.line, width: 2),
                ),
                child: t.done
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.text,
                  style: T.body(16, weight: FontWeight.w700).copyWith(
                    decoration: t.done ? TextDecoration.lineThrough : null,
                    color: t.done ? T.inkSoft : T.ink,
                  ),
                ),
              ),
              if (t.done) HankoStamp(text: l.todayDoneStamp, size: 46, angle: -0.2),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small dialog that owns its own text controller (so it is disposed safely).
class _EditTaskDialog extends StatefulWidget {
  final String initial;
  const _EditTaskDialog({required this.initial});

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  late final TextEditingController _ctl =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.taskEditTitle),
      content: TextField(
        controller: _ctl,
        autofocus: true,
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctl.text),
          child: Text(l.taskSave),
        ),
      ],
    );
  }
}

/// A small tilted label. Its text shortens instead of overflowing.
class _Tag extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final double angle;
  const _Tag({
    required this.text,
    required this.icon,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: T.vermilion),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: T.body(12, color: T.ink, weight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The branch that doubles as the bond bar. Tomarin sits further along as the bond grows.
class _BondBranch extends StatelessWidget {
  final double progress;
  const _BondBranch({required this.progress});

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, box) {
        const bird = 96.0;
        final left = (box.maxWidth - bird) * p;
        return SizedBox(
          height: bird + 6,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(height: 12, color: T.paperHigh),
                      FractionallySizedBox(
                        widthFactor: p,
                        alignment: Alignment.centerLeft,
                        child: Container(height: 12, color: const Color(0xFF8A5A2B)),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: left,
                bottom: 8,
                child: const TomarinSprite(Pose.neutral, height: bird),
              ),
            ],
          ),
        );
      },
    );
  }
}