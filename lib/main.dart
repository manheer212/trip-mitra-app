import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'trip_form_screen.dart';

void main() {
  runApp(const TripMitraApp());
}

class TripMitraApp extends StatelessWidget {
  const TripMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip Mitra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Using a Travel-friendly color palette (Ocean Blue & Sand)
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
       // textTheme: GoogleFonts.poppinsTextTheme(
         // Theme.of(context).textTheme,
       // ),
        useMaterial3: true,
      ),
      home: const TripFormScreen(),
    );
  }
}