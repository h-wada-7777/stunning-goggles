import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '経済指標カレンダー',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    loadEventData().then((events) {
      setState(() {
        _events = events;
      });
    }).catchError((error) {
      print('データ読み込みエラー: $error');
    });
  }

  Future<Map<DateTime, List<String>>> loadEventData() async {
    try {
      String jsonFile = 'assets/events_data.json';
      String data = await DefaultAssetBundle.of(context).loadString(jsonFile);
      Map<String, dynamic> jsonMap = json.decode(data);
      Map<DateTime, List<String>> events = {};
      jsonMap.forEach((key, value) {
        DateTime date = DateTime.parse(key);
        List<String> eventList = List<String>.from(value);
        events[date] = eventList;
      });
      return events;
    } catch (e) {
      print('データ読み込みエラー: $e');
      return {}; // データ読み込み失敗時は空のマップを返す
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('経済指標カレンダー'),
      ),
      body: Center(
        child: Column(
          children: [
            _events.isEmpty
                ? CircularProgressIndicator()
                : TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    eventLoader: _getEventsForDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: Colors.red),
                      weekdayStyle: TextStyle(color: Colors.blue),
                    ),
                  ),
            const SizedBox(height: 8.0),
            ..._getEventsForDay(_selectedDay ?? _focusedDay).map(
              (event) => ListTile(
                title: Text(event),
              ),
            ),
          ],
        ),
      ),
    );
  }
}