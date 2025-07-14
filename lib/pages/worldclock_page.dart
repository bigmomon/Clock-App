import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorldClockPage extends StatefulWidget {
  const WorldClockPage({super.key});

  @override
  State<WorldClockPage> createState() => _WorldClockPageState();
}

class _WorldClockPageState extends State<WorldClockPage> {
  late Timer _timer;
  late DateTime _now;

  final List<Map<String, dynamic>> _cities = [

  ];

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _openCityPicker() async {
    final List<Map<String, dynamic>> allCities = [
      {'name': 'Tokyo', 'offset': const Duration(hours: 9)},
      {'name': 'London', 'offset': const Duration(hours: 1)},
      {'name': 'New York', 'offset': const Duration(hours: -4)},
      {'name': 'Sydney', 'offset': const Duration(hours: 10)},
    ];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Select City',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allCities.length,
              itemBuilder: (context, index) {
                final city = allCities[index];
                return ListTile(
                  title: Text(
                    city['name'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, city),
                );
              },
            ),
          ),
        );
      },
    );

    if (result != null && !_cities.any((c) => c['name'] == result['name'])) {
      setState(() {
        _cities.add(result);
      });
    }
  }

  String _formatTime(DateTime time) => DateFormat('HH:mm:ss').format(time);
  String _formatDate(DateTime time) => DateFormat('EEE, MMM d').format(time);

  @override
  Widget build(BuildContext context) {
    final nowUtc = DateTime.now().toUtc();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: DateFormat('HH:').format(_now),
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: DateFormat('mm:ss').format(_now),
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Indochina Time | ${_formatDate(_now)}',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white30),
            const SizedBox(height: 12),

            // 🕒 World Clocks Scrollable Section
            Expanded(
              child: ListView.builder(
                itemCount: _cities.length,
                itemBuilder: (context, index) {
                  final city = _cities[index];
                  final cityTime = nowUtc.add(city['offset']);
                  return ListTile(
                    leading: const Icon(Icons.language, color: Colors.white),
                    title: Text(
                      city['name'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      _formatTime(cityTime),
                      style: const TextStyle(color: Colors.blue, fontSize: 20),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _openCityPicker,
        child: const Icon(Icons.add),
      ),
    );
  }
}
