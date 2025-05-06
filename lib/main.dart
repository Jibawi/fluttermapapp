import 'package:flutter/material.dart';
import 'package:fluttermapapp/my_flutter_map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyMapPage());
  }
}
