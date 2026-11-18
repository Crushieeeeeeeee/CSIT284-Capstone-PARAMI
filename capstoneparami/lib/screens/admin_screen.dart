import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/game_match.dart';
import '../models/team.dart';
import '../services/firestore_service.dart';
import '../widget/score_control.dart';
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _svc = FirestoreService.instance;
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Score entry')),
      body: StreamBuilder<List<Team>>(
        stream: _svc.teamsStream(),
        builder: (context, teamSnap) {
          return StreamBuilder<List<GameMatch>>(
            stream: _svc.matchesStream(),
            builder: (context, matchSnap) {
              if (!teamSnap.hasData || !matchSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final teams = {for (final t in teamSnap.data!) t.id: t};
              final matches = matchSnap.data!;

              if (matches.isEmpty) {
                return Center(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Seed sample data'),
                    onPressed: () async {
                      final seeded = await _svc.seedIfEmpty();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(seeded
                            ? 'Sample teams and matches added'
                            : 'Data already exists'),
                      ));
                    },
                  ),
                );
              }

              String label(GameMatch m) =>
                  '${teams[m.teamAId]?.name ?? '?'} vs ${teams[m.teamBId]?.name ?? '?'}'
                  ' · ${DateFormat('MMM d, h:mm a').format(m.startTime)}';

              GameMatch? selected;
              for (final m in matches) {
                if (m.id == _selectedId) selected = m;
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selected?.id,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select match',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final m in matches)
                        DropdownMenuItem(
                          value: m.id,
                          child:
                              Text(label(m), overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (v) => setState(() => _selectedId = v),
                  ),
                  const SizedBox(height: 20),
                  if (selected == null)
                    const Center(child: Text('Pick a match to edit its score.'))
                  else
                    _Editor(
                      key: ValueKey(selected.id),
                      match: selected,
                      teamA: teams[selected.teamAId],
                      teamB: teams[selected.teamBId],
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Editor extends StatefulWidget {
  final GameMatch match;
  final Team? teamA;
  final Team? teamB;
  const _Editor({super.key, required this.match, this.teamA, this.teamB});

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late int _a = widget.match.scoreA;
  late int _b = widget.match.scoreB;
  late MatchStatus _status = widget.match.status;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirestoreService.instance.updateMatch(
        widget.match.id,
        scoreA: _a,
        scoreB: _b,
        status: _status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ScoreControl(
                name: widget.teamA?.name ?? 'Team A',
                value: _a,
                onChanged: (v) => setState(() => _a = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ScoreControl(
                name: widget.teamB?.name ?? 'Team B',
                value: _b,
                onChanged: (v) => setState(() => _b = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<MatchStatus>(
          initialValue: _status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final s in MatchStatus.values)
              DropdownMenuItem(value: s, child: Text(s.label)),
          ],
          onChanged: (v) => setState(() => _status = v ?? _status),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving...' : 'Save'),
          ),
        ),
      ],
    );
  }
}