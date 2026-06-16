// lib/models/complaint.dart
// ─────────────────────────────────────────────────────────
// Data model matching the Flask /get-complaints response:
// {
//   "complaints": [
//     { "id": 1, "title": "...", "description": "...",
//       "category": "...", "urgency": "...",
//       "location": "...", "likes": 5,
//       "score": 12.4, "created_at": 1700000000 }
//   ]
// }
// ─────────────────────────────────────────────────────────
 
class Complaint {
  final int    id;
  final String title;
  final String description;
  final String category;
  final String urgency;
  final String location;
  final int    likes;
  final double score;
  final int    createdAt; // Unix timestamp (seconds)
 
  const Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.urgency,
    required this.location,
    required this.likes,
    required this.score,
    required this.createdAt,
  });
 
  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id:          (json['id']          as num?)?.toInt()    ?? 0,
      title:       (json['title']       as String?)          ?? 'Untitled',
      description: (json['description'] as String?)          ?? '',
      category:    (json['category']    as String?)          ?? 'General',
      urgency:     (json['urgency']     as String?)          ?? 'Low',
      location:    (json['location']    as String?)          ?? 'Unknown',
      likes:       (json['likes']       as num?)?.toInt()    ?? 0,
      score:       (json['score']       as num?)?.toDouble() ?? 0.0,
      createdAt:   (json['created_at']  as num?)?.toInt()    ?? 0,
    );
  }
 
  Map<String, dynamic> toJson() => {
    'id':          id,
    'title':       title,
    'description': description,
    'category':    category,
    'urgency':     urgency,
    'location':    location,
    'likes':       likes,
    'score':       score,
    'created_at':  createdAt,
  };
 
  // ── Derived helpers ──────────────────────────────────
  String get timeAgo {
    if (createdAt == 0) return '';
    final ts   = DateTime.fromMillisecondsSinceEpoch(
      createdAt > 1e10.toInt() ? createdAt : createdAt * 1000);
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes  < 1)  return 'just now';
    if (diff.inMinutes  < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours    < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
 
  String get urgencyLabel => urgency.isEmpty ? 'Low' : urgency;
 
  bool get isHighUrgency   => urgency == 'High';
  bool get isMediumUrgency => urgency == 'Medium';
}