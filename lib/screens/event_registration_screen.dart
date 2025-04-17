import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ritian_v1/models/event.dart';
import 'package:ritian_v1/screens/payment_screen.dart';
import 'package:ritian_v1/widgets/custom_navigation_drawer.dart';
import 'package:ritian_v1/screens/ritz_purchase_screen.dart';
import 'package:ritian_v1/screens/payment_success_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  _EventRegistrationScreenState createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  late List<Event> _events;

  // Inline JSON data with valid URLs for testing
  static const List<Map<String, dynamic>> _eventData = [
    {
      "id": 1,
      "title": "Tech Fest 2025",
      "cover_image": "https://via.placeholder.com/300x150.png?text=Tech+Fest",
      "description":
          "A grand technology festival featuring workshops, hackathons, and tech talks.",
      "organizer": "Tech Club",
      "location": "In College",
      "od_provided": true,
      "duration": "2 Days",
      "enrollment_criteria": "Open to all students",
      "registration_link": "https://www.google.com", // Valid URL for testing
      "price": 50
    },
    {
      "id": 2,
      "title": "Cultural Night",
      "cover_image":
          "https://via.placeholder.com/300x150.png?text=Cultural+Night",
      "description": "An evening of music, dance, and cultural performances.",
      "organizer": "Cultural Committee",
      "location": "In College",
      "od_provided": false,
      "duration": "4 Hours",
      "enrollment_criteria": "Open to all",
      "registration_link": "https://www.example.com", // Valid URL for testing
      "price": 0
    },
    {
      "id": 3,
      "title": "National Hackathon",
      "cover_image": "https://via.placeholder.com/300x150.png?text=Hackathon",
      "description":
          "A 24-hour coding competition with teams from across the country.",
      "organizer": "Coding Club",
      "location": "Outside College",
      "od_provided": true,
      "duration": "24 Hours",
      "enrollment_criteria": "Teams of 2-4, coding experience required",
      "registration_link": "https://www.github.com", // Valid URL for testing
      "price": 100
    },
    {
      "id": 4,
      "title": "Guest Lecture Series",
      "cover_image": "https://via.placeholder.com/300x150.png?text=Lecture",
      "description": "Lectures by industry experts on emerging technologies.",
      "organizer": "Academic Council",
      "location": "In College",
      "od_provided": true,
      "duration": "3 Hours",
      "enrollment_criteria": "Open to final-year students",
      "registration_link": "https://www.flutter.dev", // Valid URL for testing
      "price": 0
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    try {
      setState(() {
        _events = _eventData.map((json) => Event.fromJson(json)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading events: $e')),
      );
    }
  }

  void _showEventDetails(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        event.coverImage,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error, size: 50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Organizer: ${event.organizer}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Location: ${event.location}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'OD Provided: ${event.odProvided ? 'Yes' : 'No'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Duration: ${event.duration}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enrollment Criteria: ${event.enrollmentCriteria}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: ${event.price == 0 ? 'Free' : '${event.price} RITZ'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _registerForEvent(context, event),
                        child: const Text('Register'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _registerForEvent(BuildContext context, Event event) async {
    if (event.price > 0) {
      // Paid event: Check RITZ balance
      if (UserBalance.deductRitz(event.price)) {
        // Payment successful, proceed to registration
        _launchRegistrationLink(context, event);
      } else {
        // Insufficient balance
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Insufficient RITZ balance'),
            action: SnackBarAction(
              label: 'Buy RITZ',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RitzPurchaseScreen()),
                );
              },
            ),
          ),
        );
      }
    } else {
      // Free event: Directly launch registration link
      _launchRegistrationLink(context, event);
    }
  }

  void _launchRegistrationLink(BuildContext context, Event event) async {
    final Uri url = Uri.parse(event.registrationLink);
    print('Attempting to launch URL: ${event.registrationLink}'); // Debug log
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Cannot launch URL: ${event.registrationLink}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Registration')),
      drawer: const CustomNavigationDrawer(),
      body: _events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    onTap: () => _showEventDetails(context, event),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8.0)),
                          child: Image.network(
                            event.coverImage,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, size: 50),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
