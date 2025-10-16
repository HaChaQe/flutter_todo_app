import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // senin HomeScreen dosyanın yolu
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.grey.shade50,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amber.shade300,
        ),
        listTileTheme: ListTileThemeData(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        textTheme: TextTheme(
          titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          bodySmall: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ),
      debugShowCheckedModeBanner: false, // köşedeki "debug" yazısını kaldırır
      title: 'To-Do App',
      home: HomeScreen(), // 🔥 Artık senin HomeScreen açılacak
    );
  }
}
