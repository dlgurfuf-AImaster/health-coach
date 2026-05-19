import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:squat_assistant/screens/login_screen.dart';
import 'providers/squat_provider.dart';
import 'screens/squat_screen.dart';
import 'screens/main_holder.dart';

void main() {
  runApp(
    // 앱 전체에서 SquatProvider를 사용할 수 있게 등록합니다.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SquatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthCare App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const LoginScreen(), // 우리가 만든 스쿼트 화면을 첫 화면으로 설정
    );
  }
}