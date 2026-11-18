import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/game_match.dart';
import '../models/team.dart';
import 'status_badge.dart';
import 'team_label.dart';

class MatchCard extends StatelessWidget {
  final GameMatch match;
  final Team? teamA;
  final Team? teamB;

  const MatchCard({
    super.key,
    required this.match,
    required this.teamA,
    required this.teamB,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLive = match.status == MatchStatus.live;
    final showScore = match.status != MatchStatus.upcoming;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('h:mm a').format(match.startTime),
                    style: Theme.of(context).textTheme.labelLarge),
                StatusBadge(status: match.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TeamLabel(team: teamA)),
                Text(
                  showScore ? '${match.scoreA}  -  ${match.scoreB}' : 'vs',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isLive ? scheme.primary : null,
                      ),
                ),
                Expanded(child: TeamLabel(team: teamB)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}