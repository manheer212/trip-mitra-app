import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'trip_result_screen.dart'; // Reuse the result screen to show details!

class SavedTripsScreen extends StatefulWidget {
  const SavedTripsScreen({super.key});

  @override
  State<SavedTripsScreen> createState() => _SavedTripsScreenState();
}

class _SavedTripsScreenState extends State<SavedTripsScreen> {
  List trips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  // Fetch from Backend
  Future<void> fetchTrips() async {
    try {
      // Use 10.0.2.2 if on Android Emulator, localhost if on Web
      final response = await http.get(Uri.parse('https://trip-mitra-api.onrender.com/my-trips'));

      if (response.statusCode == 200) {
        setState(() {
          trips = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching trips: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Saved Trips"), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trips.isEmpty
              ? const Center(child: Text("No saved trips yet!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    final fullData = trip['fullData']; // The exact data needed for the result screen

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: const Icon(Icons.flight_takeoff, color: Colors.teal),
                        ),
                        title: Text(trip['destination'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text("Budget: ${trip['budget']} • Saved on ${trip['createdAt'].substring(0, 10)}"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // NAVIGATE TO DETAILS (Reusing your existing screen!)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripResultScreen(tripData: fullData),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}