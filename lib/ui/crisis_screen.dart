import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';
import 'tomarin_ui.dart';

/// The screen for "I have felt heavy for a long time".
///
/// Calm on purpose: no anger, no stamps, no points, no counters.
/// Nothing the user does here is saved, scored or remembered.
class CrisisScreen extends StatelessWidget {
  const CrisisScreen({super.key});

  static const _channel = MethodChannel('detox_pet/usage');

  // Free Japanese support lines (Ministry of Health, Labour and Welfare list).
  static const _yorisoiShown = '0120-279-338';
  static const _yorisoiDial = '0120279338';
  static const _inochiShown = '0120-061-338';
  static const _inochiDial = '0120061338';

  // Opens the phone app with the number filled in. The user decides whether to call.
  Future<void> _dial(String number) => _channel.invokeMethod('dial', {'number': number});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.crisisTitle, style: T.body(19, weight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: T.paper,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              Container(
                width: 170,
                height: 170,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: T.paperMid,
                ),
                child: const Center(child: TomarinSprite(Pose.gentle, height: 140)),
              ),
              const SizedBox(height: 20),
              Text(
                l.sincere1,
                textAlign: TextAlign.center,
                style: T.body(22, weight: FontWeight.w800, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: T.paperLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l.sincere2,
                  style: T.body(17, weight: FontWeight.w600, height: 1.7),
                ),
              ),
              const SizedBox(height: 18),
              _HotlineCard(
                name: l.crisisHotline1,
                badge: l.crisisFree24,
                number: _yorisoiShown,
                callLabel: l.crisisCall,
                onCall: () => _dial(_yorisoiDial),
              ),
              const SizedBox(height: 12),
              _HotlineCard(
                name: l.crisisHotline2,
                badge: l.crisisFree24Sos,
                number: _inochiShown,
                callLabel: l.crisisCall,
                onCall: () => _dial(_inochiDial),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: T.paperHigh,
                  foregroundColor: T.ink,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
                child: Text(l.crisisOk, style: T.body(16, weight: FontWeight.w700)),
              ),
              const SizedBox(height: 20),
              Text(
                l.sincere4,
                textAlign: TextAlign.center,
                style: T.note(16, color: T.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HotlineCard extends StatelessWidget {
  final String name;
  final String badge;
  final String number;
  final String callLabel;
  final VoidCallback onCall;

  const _HotlineCard({
    required this.name,
    required this.badge,
    required this.number,
    required this.callLabel,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: T.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: T.body(18, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: T.paperMid,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge,
              style: T.body(12, color: T.inkSoft, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.call, color: T.inkSoft),
              const SizedBox(width: 8),
              Expanded(
                child: Text(number, style: T.body(24, weight: FontWeight.w800)),
              ),
              FilledButton(
                onPressed: onCall,
                style: FilledButton.styleFrom(
                  backgroundColor: T.paperHigh,
                  foregroundColor: T.vermilion,
                ),
                child: Text(callLabel, style: T.body(14, weight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}