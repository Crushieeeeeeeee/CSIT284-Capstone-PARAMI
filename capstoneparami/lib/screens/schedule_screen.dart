import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/game_match.dart';
import '../models/team.dart';
import '../services/firestore_service.dart';
import '../widget/match_card.dart';
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = FirestoreService.instance;
    return StreamBuilder<List<Team>>(
      stream: svc.teamsStream(),
      builder: (context, teamSnap) {
        return StreamBuilder<List<GameMatch>>(
          stream: svc.matchesStream(),
          builder: (context, matchSnap) {
            if (teamSnap.hasError || matchSnap.hasError) {
              return Center(
                child: Text('Error: ${teamSnap.error ?? matchSnap.error}'),
              );
            }
            if (!teamSnap.hasData || !matchSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final teams = {for (final t in teamSnap.data!) t.id: t};
            final matches = matchSnap.data!;
            if (matches.isEmpty) {
              return const Center(child: Text('No matches scheduled yet.'));
            }

            // Group by calendar day (already sorted by startTime).
            final groups = <DateTime, List<GameMatch>>{};
            for (final m in matches) {
              final day = DateTime(
                  m.startTime.year, m.startTime.month, m.startTime.day);
              groups.putIfAbsent(day, () => []).add(m);
            }

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final entry in groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                    child: Text(
                      DateFormat('EEEE, MMM d').format(entry.key),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  for (final m in entry.value)
                    MatchCard(
                      match: m,
                      teamA: teams[m.teamAId],
                      teamB: teams[m.teamBId],
                    ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}