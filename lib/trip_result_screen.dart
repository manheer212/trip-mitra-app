import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TripResultScreen extends StatelessWidget {
  final Map<String, dynamic> tripData;

  const TripResultScreen({super.key, required this.tripData});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Data Parsing (Safety Checks)
    final origin = tripData['origin'] ?? "Your City";
    final destination = tripData['destination'] ?? "Unknown";
    final travelOptions = tripData['travel_options'] ?? {};
    final itinerary = tripData['itinerary'] as List? ?? [];
    final budgetStats = tripData['budget_breakdown'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // --- HEADER IMAGE ---
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(destination, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10)])),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(tripData['imageUrl'] ?? "https://via.placeholder.com/400", fit: BoxFit.cover),
                  Container(color: Colors.black38), // Dark overlay
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- SECTION 1: HOW TO REACH (Flight / Train / Bus) ---
                  const Text("🚆 How to Reach", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTravelCard(
                          icon: Icons.flight, 
                          mode: "Flight", 
                          data: travelOptions['flight'], 
                          color: Colors.blue, 
                          onTap: () => _launchURL("https://www.google.com/search?q=flights+from+$origin+to+$destination"),
                        ),
                        _buildTravelCard(
                          icon: Icons.train, 
                          mode: "Train", 
                          data: travelOptions['train'], 
                          color: Colors.orange, 
                          onTap: () => _launchURL("https://www.google.com/search?q=trains+from+$origin+to+$destination"), // In India, ideally irctc.co.in
                        ),
                        _buildTravelCard(
                          icon: Icons.directions_bus, 
                          mode: "Bus", 
                          data: travelOptions['bus'], 
                          color: Colors.green, 
                          onTap: () => _launchURL("https://www.redbus.in/search?fromCityName=$origin&toCityName=$destination"), // Generic search
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- SECTION 2: BUDGET BREAKDOWN ---
                  const Text("💰 Estimated Budget", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)]),
                    child: Column(
                      children: [
                        _buildBudgetRow("Transport", budgetStats['transport']),
                        _buildBudgetRow("Stays", budgetStats['accommodation']),
                        _buildBudgetRow("Food", budgetStats['food']),
                        _buildBudgetRow("Activities", budgetStats['activities']),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("TOTAL EST.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
                            Text(budgetStats['total_estimated'] ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.teal)),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- SECTION 3: DETAILED ITINERARY ---
                  const Text("📅 Day-by-Day Plan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  ...itinerary.map((day) => _buildDayCard(day)),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildTravelCard({required IconData icon, required String mode, required dynamic data, required Color color, required VoidCallback onTap}) {
    if (data == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Icon(Icons.arrow_outward, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 10),
            Text(mode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(data['price'] ?? "", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(data['duration'] ?? "", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(data['details'] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDayCard(Map day) {
    List activities = day['activities'] ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text("Day ${day['day']}: ${day['title']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          children: activities.map<Widget>((act) {
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(act['time'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)), // M, A, E
              ),
              title: Text(act['desc'], style: const TextStyle(fontSize: 14)),
              trailing: Text(act['cost'], style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
            );
          }).toList(),
        ),
      ),
    );
  }
}