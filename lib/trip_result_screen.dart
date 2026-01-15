import 'dart:convert'; // <--- New
import 'package:http/http.dart' as http; // <--- New
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // <--- Add this

class TripResultScreen extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const TripResultScreen({super.key, required this.tripData});

  @override
  State<TripResultScreen> createState() => _TripResultScreenState();
}

class _TripResultScreenState extends State<TripResultScreen> {
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _saveTrip() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saving your trip... 💾")),
    );

    try {
      final response = await http.post(
        Uri.parse('https://trip-mitra-api.onrender.com/save-trip'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'destination': widget.tripData['destination'],
          'budget': widget.tripData['budget_tier'],
          'fullData': widget.tripData,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Trip Saved Successfully! ✅"),
          ),
        );
      } else {
        throw Exception('Failed to save');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error saving: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.tripData['destination'] ?? "Unknown Destination";
    final budget = widget.tripData['budget_tier'] ?? "Standard";
    final List gems = widget.tripData['gems'] ?? [];
    final List itinerary = widget.tripData['itinerary'] ?? [];
    final transportTip = widget.tripData['local_transport'] ?? "No transport info available.";
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveTrip,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save),
        label: const Text("Save Trip"),
      ),
      // ------------------------
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0, // Made it slightly taller for better view
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                destination,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. The Real Image
                  Image.network(
                    widget.tripData['imageUrl'] ?? "https://via.placeholder.com/400",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.teal,
                      ); // Fallback color if image fails
                    },
                  ),
                  // 2. A Dark Gradient Overlay (so text is readable)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
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
                  // Budget Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Budget: $budget Tier",
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- NEW: BOOKING BUTTONS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Opens Google Flights searching for the destination
                          _launchURL(
                            "https://www.google.com/search?q=flights+to+$destination",
                          );
                        },
                        icon: const Icon(Icons.flight, size: 18),
                        label: const Text("Flights"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Opens Booking.com searching for the destination
                          _launchURL(
                            "https://www.booking.com/searchresults.html?ss=$destination",
                          );
                        },
                        icon: const Icon(Icons.hotel, size: 18),
                        label: const Text("Hotels"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade50,
                          foregroundColor: Colors.teal,
                        ),
                      ),
                    ],
                  ),

                  // -----------------------------
                  const SizedBox(height: 25),

                  // ... after the Booking Buttons Row ...
                  const SizedBox(height: 20),

                  // NEW: Local Transport Tip Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_bus, color: Colors.blue),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Local Commute Tip:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                transportTip,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // DYNAMIC HIDDEN GEMS
                  const Text(
                    "💎 Hidden Gems",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: gems.length,
                      itemBuilder: (context, index) {
                        return _buildGemCard(
                          gems[index]['name'],
                          gems[index]['type'],
                          Colors.blue,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // DYNAMIC ITINERARY
                  const Text(
                    "📅 Your Itinerary",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itinerary.length,
                    itemBuilder: (context, index) {
                      final dayData = itinerary[index];
                      return _buildDayItem(dayData);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGemCard(String title, String tag, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, color: Colors.orange, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(tag, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDayItem(Map dayData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${dayData['day']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(width: 2, height: 80, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 5),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "☀️ Morning: ${dayData['morning']}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "🌤 Afternoon: ${dayData['afternoon']}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "🌙 Evening: ${dayData['evening']}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
