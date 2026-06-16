import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {

  final List complaints;
  final Future<void> Function() onRefresh;

  const AdminDashboardScreen({
    super.key,
    required this.complaints,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Admin Dashboard"),

        actions: [

          IconButton(
            icon: const Icon(Icons.refresh),

            onPressed: () {
              onRefresh();
            },
          ),
        ],
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // -----------------------------
            // TOP STATS
            // -----------------------------
            Row(

              children: [

                Expanded(
                  child: _buildStatCard(
                    "Total Complaints",
                    complaints.length.toString(),
                    Icons.report_problem,
                    Colors.red,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildStatCard(
                    "Top-K",
                    "5",
                    Icons.leaderboard,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Top Ranked Complaints",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // -----------------------------
            // COMPLAINT LIST
            // -----------------------------
            Expanded(

              child: ListView.builder(

                itemCount: complaints.length,

                itemBuilder: (context, index) {

                  final complaint = complaints[index];

                  return Card(

                    elevation: 4,

                    margin: const EdgeInsets.only(bottom: 12),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Padding(

                      padding: const EdgeInsets.all(14),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Row(

                            children: [

                              CircleAvatar(
                                backgroundColor: Colors.blue,

                                child: Text(
                                  "#${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  complaint.title,

                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text(
                            complaint.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 12),

                          Row(

                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                            children: [

                              Container(

                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color:
                                      Colors.orange.shade100,

                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),

                                child: Text(
                                  "⭐ ${complaint.score.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              Text(
                                "👍 ${complaint.likes}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // STAT CARD WIDGET
  // -----------------------------
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: color.withOpacity(0.15),

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Icon(icon, color: color, size: 30),

          const SizedBox(height: 12),

          Text(
            value,

            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          Text(
            title,

            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}