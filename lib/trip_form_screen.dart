import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'trip_result_screen.dart';
import 'saved_trips_screen.dart';

class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  // --- STATE VARIABLES ---
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _originController = TextEditingController(); // Moved inside class
  double _days = 3;
  String _selectedBudget = 'Mid';
  bool _isLoading = false;

  // ⚠️ REPLACE THIS WITH YOUR RENDER URL
  final String _apiUrl = "https://trip-mitra-api.onrender.com/generate-trip";

  // --- LOGIC: CALL API ---
  Future<void> _generateTrip() async {
    // 1. Validation: Check both inputs
    if (_destinationController.text.isEmpty || _originController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both cities! 🌍")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "origin": _originController.text,        // <--- FIXED: Now sending Origin!
          "destination": _destinationController.text,
          "days": _days.toInt(),
          "budget": _selectedBudget,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripResultScreen(tripData: data),
          ),
        );
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI DESIGN ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?q=80&w=2021&auto=format&fit=crop"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. BLACK OVERLAY
          Container(color: Colors.black.withOpacity(0.5)),

          // 3. THE CONTENT
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.travel_explore, color: Colors.white, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      "Trip Mitra",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      "Your AI Travel Companion",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 40),

                    // GLASS CARD FORM
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          // 1. ORIGIN INPUT (Moved Inside Card)
                          const Text("From where?", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _originController,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: "e.g. New Delhi",
                              prefixIcon: const Icon(Icons.flight_takeoff, color: Color(0xFF00695C)),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          
                          const SizedBox(height: 20),

                          // 2. DESTINATION INPUT
                          const Text("Where to?", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _destinationController,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: "e.g. Goa, Paris",
                              prefixIcon: const Icon(Icons.location_pin, color: Color(0xFF00695C)),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 3. DURATION SLIDER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Duration", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("${_days.toInt()} Days", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00695C))),
                            ],
                          ),
                          Slider(
                            value: _days,
                            min: 1,
                            max: 14,
                            divisions: 13,
                            activeColor: const Color(0xFF00695C),
                            onChanged: (val) => setState(() => _days = val),
                          ),

                          const SizedBox(height: 15),

                          // 4. BUDGET DROPDOWN
                          const Text("Budget", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedBudget,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              prefixIcon: const Icon(Icons.wallet, color: Color(0xFF00695C)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            items: ["Low", "Mid", "High"]
                                .map((b) => DropdownMenuItem(value: b, child: Text("$b Budget")))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedBudget = val!),
                          ),

                          const SizedBox(height: 30),

                          // ACTION BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _generateTrip,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00695C),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      "Plan My Trip ✈️",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Saved Trips Link
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedTripsScreen()));
                      },
                      icon: const Icon(Icons.history, color: Colors.white),
                      label: const Text("View Saved Trips", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}