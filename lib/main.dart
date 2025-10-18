import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'services/notification_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // Flutter motorunun hazır olduğundan emin ol
  NotificationService notificationService = NotificationService();
  await notificationService.init(); // Bildirim servisini başlat
  await notificationService.requestPermissions(); // İzinleri iste

  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(notificationService),
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
