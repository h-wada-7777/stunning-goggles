import 'package:flutter/material.dart';

void main() {
  // カラム
  const col = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text('レモン'),
      Text('りんご'),
      Text('ブドウ'),
    ],
  );

  const row = Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [col, col, col],
  );

  const app = MaterialApp(
    home: Scaffold(
      body: Center(
        child: row,
      ),
    ),
  );
  runApp(app);
}