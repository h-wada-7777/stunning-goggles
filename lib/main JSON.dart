import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<DateTime, List<String>>> loadEventData() async {
  // JSONファイルの読み込み
  String data = await rootBundle.loadString('assets/events_data.json');
  
  // JSONデータのパース
  Map<String, dynamic> jsonMap = json.decode(data);
  
  // DateTimeに変換したデータを格納するMapの初期化
  Map<DateTime, List<String>> events = {};

  // JSONデータをDateTimeキー、リストの値でセットアップ
  jsonMap.forEach((key, value) {
    DateTime date = DateTime.parse(key);
    events[date] = List<String>.from(value);
  });

  return events;
}
