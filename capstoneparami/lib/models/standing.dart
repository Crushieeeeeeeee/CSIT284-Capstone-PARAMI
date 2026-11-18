import 'game_match.dart';
import 'team.dart';

class Standing {
  final Team team;
  int played = 0;
  int wins = 0;
  int losses = 0;
  int draws = 0;
  int pointsFor = 0;
  int pointsAgainst = 0;

  Standing(this.team);

  int get diff => pointsFor - pointsAgainst;
  int get points => wins * 3 + draws; // win 3, draw 1, loss 0
}

/// Standings from FINAL matches only.
/// Sort: points, then point difference, then points scored, then name.
List<Standing> computeStandings(List<Team> teams, List<GameMatch> matches) {
  final table = {for (final t in teams) t.id: Standing(t)};

  for (final m in matches) {
    if (m.status != MatchStatus.final_) continue;
    final a = table[m.teamAId];
    final b = table[m.teamBId];
    if (a == null || b == null) continue;

    a.played++;
    b.played++;
    a.pointsFor += m.scoreA;
    a.pointsAgainst += m.scoreB;
    b.pointsFor += m.scoreB;
    b.pointsAgainst += m.scoreA;

    if (m.scoreA > m.scoreB) {
      a.wins++;
      b.losses++;
    } else if (m.scoreB > m.scoreA) {
      b.wins++;
      a.losses++;
    } else {
      a.draws++;
      b.draws++;
    }
  }

  final rows = table.values.toList()
    ..sort((x, y) {
      final p = y.points.compareTo(x.points);
      if (p != 0) return p;
      final d = y.diff.compareTo(x.diff);
      if (d != 0) return d;
      final f = y.pointsFor.compareTo(x.pointsFor);
      if (f != 0) return f;
      return x.team.name.compareTo(y.team.name);
    });
  return rows;
}