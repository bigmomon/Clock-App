import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int selectedHour = 0;
  int selectedMinute = 0;
  int selectedSecond = 0;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;

  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isRunning = false;

  final List<Duration> _savedTimers = [];

  Duration get totalDuration => Duration(
        hours: selectedHour,
        minutes: selectedMinute,
        seconds: selectedSecond,
      );

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: selectedMinute);
    _secondController = FixedExtentScrollController(initialItem: selectedSecond);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning || totalDuration.inSeconds == 0) return;
    _remaining = totalDuration;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds == 0) {
        timer.cancel();
        setState(() => _isRunning = false);
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remaining = Duration.zero;
    });
  }

  void _addToSavedTimers() {
    final dur = totalDuration;
    if (dur.inSeconds > 0 &&
        !_savedTimers.any((d) => d.inSeconds == dur.inSeconds)) {
      setState(() {
        _savedTimers.add(dur);
      });
    }
  }

  Widget _buildPickerColumn({
    required String label,
    required int max,
    required int value,
    required void Function(int) onChanged,
    required FixedExtentScrollController controller,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white38)),
          SizedBox(
            height: 150,
            child: CupertinoPicker(
              scrollController: controller,
              backgroundColor: Colors.transparent,
              itemExtent: 50,
              onSelectedItemChanged: onChanged,
              children: List.generate(max, (i) {
                return Center(
                  child: Text(
                    i.toString().padLeft(2, '0'),
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final isZero = totalDuration.inSeconds == 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            if (_isRunning)
              Column(
                children: [
                  const Text("Time Remaining",
                      style: TextStyle(color: Colors.white38)),
                  const SizedBox(height: 10),
                  Text(
                    _formatDuration(_remaining),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildPickerColumn(
                      label: 'Hours',
                      max: 24,
                      value: selectedHour,
                      onChanged: (v) => setState(() => selectedHour = v),
                      controller: _hourController,
                    ),
                    _buildPickerColumn(
                      label: 'Minutes',
                      max: 60,
                      value: selectedMinute,
                      onChanged: (v) => setState(() => selectedMinute = v),
                      controller: _minuteController,
                    ),
                    _buildPickerColumn(
                      label: 'Seconds',
                      max: 60,
                      value: selectedSecond,
                      onChanged: (v) => setState(() => selectedSecond = v),
                      controller: _secondController,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Frequently used timers",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  GestureDetector(
                    onTap: _addToSavedTimers,
                    child: const Text("Add",
                        style: TextStyle(color: Colors.blue, fontSize: 16)),
                  ),
                ],
              ),
            ),

            if (_savedTimers.isNotEmpty)
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _savedTimers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final d = _savedTimers[i];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedHour = d.inHours;
                          selectedMinute = d.inMinutes.remainder(60);
                          selectedSecond = d.inSeconds.remainder(60);
                          _hourController.jumpToItem(selectedHour);
                          _minuteController.jumpToItem(selectedMinute);
                          _secondController.jumpToItem(selectedSecond);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _formatDuration(d),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const Spacer(),
            FloatingActionButton(
              backgroundColor:
                  isZero && !_isRunning ? Colors.grey : Colors.blue,
              onPressed: isZero && !_isRunning
                  ? null
                  : _isRunning
                      ? _resetTimer
                      : _startTimer,
              child: Icon(_isRunning ? Icons.stop : Icons.play_arrow, size: 32),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
