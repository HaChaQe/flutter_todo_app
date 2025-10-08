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
      debugShowCheckedModeBanner: false, // köşedeki "debug" yazısını kaldırır
      title: 'To-Do App',
      theme: ThemeData(primarySwatch: Colors.blue,),
      home: HomeScreen(), // 🔥 Artık senin HomeScreen açılacak
    );
  }
}
