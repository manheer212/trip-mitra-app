import 'package:flutter/material.dart';
import './trip_result_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'saved_trips_screen.dart';

class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  // Controllers to store user input
  final TextEditingController _destinationController = TextEditingController();

  // Default values
  double _days = 3;
  String _selectedBudget = 'Mid'; // Options: Low, Mid, High

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: const Text("Trip Mitra", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // NEW: Button to view saved trips
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedTripsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Image or Icon
              Center(
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.travel_explore,
                    size: 80,
                    color: Colors.teal,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 2. Destination Input
              const Text(
                "Where do you want to go?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _destinationController,
                decoration: InputDecoration(
                  hintText: "e.g., Paris, Bali, Kyoto",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 25),

              // 3. Duration Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Duration",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "${_days.toInt()} Days",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _days,
                min: 1,
                max: 14,
                divisions: 13,
                activeColor: Colors.teal,
                label: "${_days.toInt()} Days",
                onChanged: (value) {
                  setState(() {
                    _days = value;
                  });
                },
              ),

              const SizedBox(height: 25),

              // 4. Budget Selector
              const Text(
                "What is your Budget?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBudgetCard("Low", "₹", Colors.green),
                  _buildBudgetCard("Mid", "₹₹", Colors.orange),
                  _buildBudgetCard("High", "₹₹₹", Colors.red),
                ],
              ),

              const SizedBox(height: 40),

              // 5. Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_destinationController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a destination!"),
                        ),
                      );
                      return;
                    }

                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    // 1. Show Loading Indicator
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("Connecting to Trip Mitra Brain..."),
                      ),
                    );

                    // 2. Prepare the Data
                    final requestBody = {
                      "destination": _destinationController.text,
                      "days": _days.toInt(),
                      "budget": _selectedBudget,
                    };

                    try {
                      // 3. Send Request to Backend
                      final response = await http.post(
                        Uri.parse('https://trip-mitra-api.onrender.com/generate-trip'),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode(requestBody),
                      );

                      if (!mounted) return;
                      if (response.statusCode == 200) {
                        // 4. Success! Decode the data
                        final responseData = jsonDecode(response.body);

                        // 5. Navigate to Result Screen with REAL Data
                        navigator.push(
                          MaterialPageRoute(
                            builder: (context) =>
                                TripResultScreen(tripData: responseData),
                          ),
                        );
                      } else {
                        throw Exception("Server Error: ${response.statusCode}");
                      }
                    } catch (e) {
                      // 6. Handle Errors
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text("Error: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Plan My Trip",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build budget options
  Widget _buildBudgetCard(String label, String iconText, Color color) {
    bool isSelected = _selectedBudget == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBudget = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              iconText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
