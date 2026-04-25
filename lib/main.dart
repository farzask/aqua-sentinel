import 'package:flutter/material.dart';
import 'package:aqua_sentinel/pages/homepage.dart';
import 'package:aqua_sentinel/sensor_data.dart';
import 'package:aqua_sentinel/notification_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await sensorData.loadFromStorage();
  runApp(MyApp());
  await notificationService.init();
  sensorData.startListening();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aqua Sentinel',
      theme: ThemeData(),
      home: SafeArea(child: Homepage()),
    );
  }
}
