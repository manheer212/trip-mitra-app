import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // 1. Data Parsing (Safely handle missing data)
    final origin = tripData['origin'] ?? "Your City";
    final destination = tripData['destination'] ?? "Unknown";
    
    // Default to empty maps/lists if the AI missed them
    final travelOptions = tripData['travel_options'] ?? {};
    final List itinerary = tripData['itinerary'] ?? [];
    final budgetStats = tripData['budget_breakdown'] ?? {};
    final imageUrl = tripData['imageUrl'] ?? "https://via.placeholder.com/400";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // --- HEADER IMAGE ---
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                destination,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [const Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(color: Colors.teal),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                  ),
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
                  Text("🚆 How to Reach", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  if (travelOptions.isEmpty)
                    const Text("No travel details generated.")
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (travelOptions['flight'] != null)
                            _buildTravelCard(
                              icon: Icons.flight, 
                              mode: "Flight", 
                              data: travelOptions['flight'], 
                              color: Colors.blue, 
                              onTap: () => _launchURL("https://www.google.com/search?q=flights+from+$origin+to+$destination"),
                            ),
                          if (travelOptions['train'] != null)
                            _buildTravelCard(
                              icon: Icons.train, 
                              mode: "Train", 
                              data: travelOptions['train'], 
                              color: Colors.orange, 
                              onTap: () => _launchURL("https://www.google.com/search?q=trains+from+$origin+to+$destination"), 
                            ),
                          if (travelOptions['bus'] != null)
                            _buildTravelCard(
                              icon: Icons.directions_bus, 
                              mode: "Bus", 
                              data: travelOptions['bus'], 
                              color: Colors.green, 
                              onTap: () => _launchURL("https://www.redbus.in/search?fromCityName=$origin&toCityName=$destination"), 
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),

                  // --- SECTION 2: BUDGET BREAKDOWN ---
                  Text("💰 Estimated Budget", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16), 
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                    ),
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
                            Text("TOTAL EST.", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF00695C))),
                            Text(budgetStats['total_estimated'] ?? "N/A", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF00695C))),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- SECTION 3: DETAILED ITINERARY ---
                  Text("📅 Day-by-Day Plan", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  if (itinerary.isEmpty)
                     const Padding(
                       padding: EdgeInsets.all(20.0),
                       child: Text("⚠️ No itinerary details found. Try generating again."),
                     )
                  else
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
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
            Text(mode, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            const SizedBox(height: 4),
            Text(data['price'] ?? "Check Price", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(data['duration'] ?? "", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              data['details'] ?? "Direct Route", 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis, 
              style: const TextStyle(fontSize: 11, color: Colors.grey)
            ),
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
    
    // Check if activities is just a List of Strings (Old format fallback)
    // or a List of Maps (New format)
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          shape: const Border(), // Removes border when expanded
          title: Text(
            "Day ${day['day']}: ${day['title'] ?? 'Explore'}", 
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)
          ),
          children: activities.map<Widget>((act) {
            
            // Handle new format {time, desc, cost}
            if (act is Map) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    (act['time'] ?? "Day").toString().substring(0, 1), // M/A/E
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700)
                  ),
                ),
                title: Text(act['desc'] ?? "", style: const TextStyle(fontSize: 13)),
                trailing: Text(
                  act['cost'] ?? "", 
                  style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)
                ),
              );
            } 
            // Handle fallback (if old format somehow comes through)
            else {
               return ListTile(title: Text(act.toString()));
            }
          }).toList(),
        ),
      ),
    );
  }
}