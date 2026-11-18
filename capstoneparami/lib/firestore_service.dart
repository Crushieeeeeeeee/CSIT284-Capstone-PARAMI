import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/game_match.dart';
import '../models/team.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _teams => _db.collection('teams');
  CollectionReference<Map<String, dynamic>> get _matches => _db.collection('matches');

  Stream<List<Team>> teamsStream() =>
      _teams.snapshots().map((s) => s.docs.map(Team.fromDoc).toList());

  Stream<List<GameMatch>> matchesStream() => _matches
      .orderBy('startTime')
      .snapshots()
      .map((s) => s.docs.map(GameMatch.fromDoc).toList());

  Future<void> updateMatch(
    String matchId, {
    required int scoreA,
    required int scoreB,
    required MatchStatus status,
  }) {
    return _matches.doc(matchId).update({
      'scoreA': scoreA,
      'scoreB': scoreB,
      'status': status.value,
    });
  }

  /// Adds sample teams and matches once. Does nothing if teams already exist.
  Future<bool> seedIfEmpty() async {
    final existing = await _teams.limit(1).get();
    if (existing.docs.isNotEmpty) return false;

    final teams = <String, Team>{
      'red': const Team(id: 'red', name: 'Red Dragons', color: 0xFFD32F2F),
      'blue': const Team(id: 'blue', name: 'Blue Eagles', color: 0xFF1976D2),
      'green': const Team(id: 'green', name: 'Green Hornets', color: 0xFF388E3C),
      'yellow': const Team(id: 'yellow', name: 'Yellow Tigers', color: 0xFFFBC02D),
    };

    final batch = _db.batch();
    teams.forEach((id, t) => batch.set(_teams.doc(id), t.toMap()));

    final base = DateTime.now();
    DateTime at(int dayOffset, int hour) =>
        DateTime(base.year, base.month, base.day + dayOffset, hour);

    final fixtures = <(String, String, DateTime)>[
      ('red', 'blue', at(0, 14)),
      ('green', 'yellow', at(0, 16)),
      ('red', 'green', at(1, 14)),
      ('blue', 'yellow', at(1, 16)),
      ('red', 'yellow', at(2, 14)),
      ('blue', 'green', at(2, 16)),
    ];
    for (final f in fixtures) {
      batch.set(
        _matches.doc(),
        GameMatch(
          id: '',
          teamAId: f.$1,
          teamBId: f.$2,
          scoreA: 0,
          scoreB: 0,
          startTime: f.$3,
          status: MatchStatus.upcoming,
        ).toMap(),
      );
    }
    await batch.commit();
    return true;
  }
}