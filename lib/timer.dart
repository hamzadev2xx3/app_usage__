import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TimerApp extends StatefulWidget {
  final Database database;

  const TimerApp({Key? key, required this.database}) : super(key: key);

  @override
  _TimerAppState createState() => _TimerAppState();
}

class _TimerAppState extends State<TimerApp> with WidgetsBindingObserver {
  late Timer _timer;
  int _secondsElapsed = 0;

  Database get database => widget.database;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _getSecondsElapsed();
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    _stopTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _secondsElapsed++;
        _updateSecondsElapsed(_secondsElapsed);
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  Future<void> _getSecondsElapsed() async {
    final List<Map<String, dynamic>> maps = await database.query('timer');
    if (maps.isNotEmpty) {
      setState(() {
        _secondsElapsed = maps.first['seconds_elapsed'] as int;
      });
    }
  }

  Future<void> _updateSecondsElapsed(int secondsElapsed) async {
    // Ensure that the database is created
    await database.transaction((txn) async {
      await txn.execute(
        'CREATE TABLE IF NOT EXISTS timer(id INTEGER PRIMARY KEY, seconds_elapsed INTEGER)',
      );
    });

    // Check if there is an existing row in the database
    final count = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM timer'),
    );

    if (count == 0) {
      // If there is no existing row, insert the initial value of the timer
      await database.insert('timer', {'id': 1, 'seconds_elapsed': secondsElapsed});
    } else {
      // Otherwise, update the existing row with the new value of the timer
      await database.update(
        'timer',
        {'seconds_elapsed': secondsElapsed},
        where: 'id = ?',
        whereArgs: [1],
      );
    }
  }

  String getTimerString() {
    final int hours = _secondsElapsed ~/ 3600;
    final int minutes = (_secondsElapsed % 3600) ~/ 60;
    final int seconds = _secondsElapsed % 60;

    final String hourString = hours > 0 ? '$hours hour ' : '';
    final String minuteString = minutes > 0 || hours > 0 ? '$minutes minute ' : '';
    final String secondString = '$seconds second';

    return '$hourString$minuteString$secondString';
  }


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer App'),
      ),
      body: Center(
        child: Text(
          'Time elapsed: ${getTimerString()}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopTimer();
    } else if (state == AppLifecycleState.resumed) {
      _getSecondsElapsed();
      _startTimer();
    }
  }
}