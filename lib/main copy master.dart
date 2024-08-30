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
  late Future<Map<DateTime, List<String>>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = loadEventData();
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
      throw e; // エラーを再スローして呼び出し元に伝える
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
        child: FutureBuilder<Map<DateTime, List<String>>>(
          future: _futureEvents,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('データの読み込みに失敗しました: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('データが見つかりませんでした');
            } else {
              _events = snapshot.data!; // データを取得したら_eventsを更新
              return Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    eventLoader: (day) => _getEventsForDay(day),
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
                  Column(
                    children: _getEventsForDay(_selectedDay ?? _focusedDay).map(
                      (event) => ListTile(
                        title: Text(event),
                      ),
                    ).toList(),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
