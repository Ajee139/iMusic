import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/playerController.dart';
import 'Screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure proper initialization
  Get.put(PlayerController()); // Initialize the PlayerController
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      title: "InstMusic",
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}
