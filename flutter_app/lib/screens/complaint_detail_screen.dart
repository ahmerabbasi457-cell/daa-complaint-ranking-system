import 'package:flutter/material.dart';

class ComplaintDetailScreen extends StatelessWidget {
  final dynamic complaint;
  final int rank;                          // ✅ ADDED
  final double maxScore;                   // ✅ ADDED
  final Future<void> Function(int) onLike; // ✅ ADDED

  const ComplaintDetailScreen({
    super.key,
    required this.complaint,
    required this.rank,      // ✅ ADDED
    required this.maxScore,  // ✅ ADDED
    required this.onLike,    // ✅ ADDED
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaint Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complaint.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(complaint.description),
            const SizedBox(height: 20),
            Text("Category: ${complaint.category}"),
            Text("Urgency: ${complaint.urgency}"),
            Text("Likes: ${complaint.likes}"),
            Text(
              "Score: ${complaint.score.toStringAsFixed(2)}",
            ),
          ],
        ),
      ),
    );
  }
}