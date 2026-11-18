import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchStatus { upcoming, live, final_ }

extension MatchStatusX on MatchStatus {
  String get value => switch (this) {
        MatchStatus.upcoming => 'upcoming',
        MatchStatus.live => 'live',
        MatchStatus.final_ => 'final',
      };

  String get label => switch (this) {
        MatchStatus.upcoming => 'Upcoming',
        MatchStatus.live => 'LIVE',
        MatchStatus.final_ => 'Final',
      };

  static MatchStatus parse(String? s) => switch (s) {
        'live' => MatchStatus.live,
        'final' => MatchStatus.final_,
        _ => MatchStatus.upcoming,
      };
}

class GameMatch {
  final String id;
  final String teamAId;
  final String teamBId;
  final int scoreA;
  final int scoreB;
  final DateTime startTime;
  final MatchStatus status;

  const GameMatch({
    required this.id,
    required this.teamAId,
    required this.teamBId,
    required this.scoreA,
    required this.scoreB,
    required this.startTime,
    required this.status,
  });

  factory GameMatch.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['startTime'];
    return GameMatch(
      id: doc.id,
      teamAId: d['teamAId'] as String? ?? '',
      teamBId: d['teamBId'] as String? ?? '',
      scoreA: (d['scoreA'] as num?)?.toInt() ?? 0,
      scoreB: (d['scoreB'] as num?)?.toInt() ?? 0,
      startTime: ts is Timestamp ? ts.toDate() : DateTime.now(),
      status: MatchStatusX.parse(d['status'] as String?),
    );
  }

  Map<String, dynamic> toMap() => {
        'teamAId': teamAId,
        'teamBId': teamBId,
        'scoreA': scoreA,
        'scoreB': scoreB,
        'startTime': Timestamp.fromDate(startTime),
        'status': status.value,
      };
}