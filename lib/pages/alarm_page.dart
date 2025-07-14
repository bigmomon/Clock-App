// ignore_for_file: file_names

import 'package:flutter/material.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final List<TimeOfDay> _alarms = [];

  void _addAlarm() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(), // dark theme for consistency
          child: child!,
        );
      },
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _alarms.add(pickedTime);
      });
    }
  }

  void _deleteAlarm(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Delete Alarm", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this alarm?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _alarms.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Alarms'),
        backgroundColor: Colors.black,
      ),
      body: _alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.alarm, size: 120, color: Colors.grey),
                  SizedBox(height: 20),
                  Text("No alarms", style: TextStyle(color: Colors.white54, fontSize: 18)),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _alarms.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return ListTile(
                  leading: const Icon(Icons.alarm, color: Colors.white),
                  title: Text(
                    alarm.format(context),
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteAlarm(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
