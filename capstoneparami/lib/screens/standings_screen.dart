import 'package:flutter/material.dart';

import '../models/game_match.dart';
import '../models/standing.dart';
import '../models/team.dart';
import '../services/firestore_service.dart';

class StandingsScreen extends StatelessWidget {
  const StandingsScreen({super.key});

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
            final rows = computeStandings(teamSnap.data!, matchSnap.data!);
            if (rows.isEmpty) {
              return const Center(child: Text('No teams yet.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('Team')),
                      DataColumn(label: Text('P'), numeric: true),
                      DataColumn(label: Text('W'), numeric: true),
                      DataColumn(label: Text('L'), numeric: true),
                      DataColumn(label: Text('+/-'), numeric: true),
                      DataColumn(label: Text('Pts'), numeric: true),
                    ],
                    rows: [
                      for (var i = 0; i < rows.length; i++)
                        DataRow(cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Row(children: [
                            CircleAvatar(
                              radius: 8,
                              backgroundColor: Color(rows[i].team.color),
                            ),
                            const SizedBox(width: 8),
                            Text(rows[i].team.name),
                          ])),
                          DataCell(Text('${rows[i].played}')),
                          DataCell(Text('${rows[i].wins}')),
                          DataCell(Text('${rows[i].losses}')),
                          DataCell(Text(rows[i].diff > 0
                              ? '+${rows[i].diff}'
                              : '${rows[i].diff}')),
                          DataCell(Text('${rows[i].points}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                        ]),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}