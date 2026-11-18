import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String name;
  final int color; // ARGB int, e.g. 0xFFD32F2F

  const Team({required this.id, required this.name, required this.color});

  factory Team.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Team(
      id: doc.id,
      name: d['name'] as String? ?? 'Unknown',
      color: (d['color'] as num?)?.toInt() ?? 0xFF607D8B,
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'color': color};
}