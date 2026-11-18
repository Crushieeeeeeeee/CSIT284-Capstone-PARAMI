import 'package:flutter/material.dart';

import '../models/game_match.dart';

class StatusBadge extends StatelessWidget {
  final MatchStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (status) {
      MatchStatus.live => (scheme.error, scheme.onError),
      MatchStatus.final_ => (scheme.surfaceContainerHighest, scheme.onSurface),
      MatchStatus.upcoming =>
        (scheme.secondaryContainer, scheme.onSecondaryContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}