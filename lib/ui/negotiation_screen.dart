import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'crisis_screen.dart';
import 'theme.dart';
import 'tomarin_ui.dart';

/// Shown after the user taps a pass. A pass is only granted after an honest reason.
///  - [onConfirm]: the user picked a reason and promised (the reason id is the same
///    one the check-in log already uses: tired, bored, auto or notif)
///  - [onBack]: the user changed their mind and goes back
class NegotiationScreen extends StatefulWidget {
  final int minutes;
  final void Function(String reason) onConfirm;
  final VoidCallback onBack;

  const NegotiationScreen({
    super.key,
    required this.minutes,
    required this.onConfirm,
    required this.onBack,
  });

  @override
  State<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends State<NegotiationScreen> {
  String? _reason;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final m = widget.minutes;
    final chosen = _reason != null;

    final reasons = <(String, String, String, IconData)>[
      ('tired', l.ciTired, l.negSubTired, Icons.coffee_outlined),
      ('bored', l.ciBored, l.negSubBored, Icons.schedule),
      ('auto', l.ciAuto, l.negSubAuto, Icons.phone_android),
      ('notif', l.ciNotif, l.negSubNotif, Icons.notifications_none),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Column(
                  children: [
                    _Pill(l.negTag(m)),
                    const SizedBox(height: 14),
                    SpeechBubble(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l.negQuestion(m),
                            textAlign: TextAlign.center,
                            style: T.shout(19),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.negSub(m),
                            textAlign: TextAlign.center,
                            style: T.body(15, color: T.inkSoft, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        const TomarinSprite(Pose.negotiating, height: 190),
                        Positioned(
                          right: 40,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: T.paperHigh,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(l.negHmm, style: T.shout(14, color: T.vermilion)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: chosen ? T.persimmon : T.persimmonDeep,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          chosen ? l.negStatusDone : l.negStatusWaiting,
                          style: T.body(13, color: T.persimmonDeep, weight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(l.negReasonTitle, style: T.body(19, weight: FontWeight.w800)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: T.paperHigh,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l.negRequired,
                            style: T.body(11, color: T.vermilion, weight: FontWeight.w800),
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            l.negLater,
                            textAlign: TextAlign.right,
                            style: T.body(11, color: T.inkSoft),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        for (final r in reasons)
                          _ReasonCard(
                            title: r.$2,
                            subtitle: r.$3,
                            icon: r.$4,
                            selected: _reason == r.$1,
                            onTap: () => setState(() => _reason = r.$1),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Not a reason for a pass: a quiet way to say "this is bigger than scrolling".
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CrisisScreen()),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: T.inkSoft,
                          side: const BorderSide(color: T.line),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(l.hardHeavy, style: T.body(15, weight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: chosen ? () => widget.onConfirm(_reason!) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: T.vermilion,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: T.vermilion.withValues(alpha: 0.35),
                        disabledForegroundColor: Colors.white70,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.handshake_outlined),
                          const SizedBox(width: 8),
                          Text(
                            l.negPromise(m),
                            style: T.body(17, color: Colors.white, weight: FontWeight.w800),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l.negPinky,
                              style: T.body(11, color: Colors.white, weight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onBack,
                    child: Text(
                      l.negBackOut,
                      style: T.body(14, color: T.ink, weight: FontWeight.w700).copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    l.negFootnote(m),
                    textAlign: TextAlign.center,
                    style: T.body(11, color: T.inkSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: T.persimmon.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_note, size: 18, color: T.persimmonDeep),
          const SizedBox(width: 6),
          Text(text, style: T.body(13, color: T.persimmonDeep, weight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ReasonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ReasonCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? T.paperHigh : Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? T.vermilion : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: T.paperMid,
                    child: Icon(icon, size: 20, color: T.persimmonDeep),
                  ),
                  if (selected) const Icon(Icons.check_circle, color: T.vermilion),
                ],
              ),
              const Spacer(),
              Text(title, style: T.body(15, weight: FontWeight.w800, height: 1.25)),
              const SizedBox(height: 2),
              Text(subtitle, style: T.body(12, color: T.inkSoft, height: 1.25)),
            ],
          ),
        ),
      ),
    );
  }
}