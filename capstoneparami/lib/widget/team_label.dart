import 'package:flutter/material.dart';

import '../models/team.dart';

class TeamLabel extends StatelessWidget {
  final Team? team;
  const TeamLabel({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Color(team?.color ?? 0xFF9E9E9E),
        ),
        const SizedBox(height: 6),
        Text(
          team?.name ?? '?',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}