import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pifront/controller/FavoriteController.dart';
import 'package:pifront/controller/HomeController.dart';
import 'package:pifront/controller/RecipeController.dart';
import 'package:pifront/ui/root_page.dart';
import 'package:pifront/view/home_screen.dart';
import 'package:pifront/view/signup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pifront/view/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lrqgurtatmzepipvyorv.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxycWd1cnRhdG16ZXBpcHZ5b3J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM5NTAxODEsImV4cCI6MjA0OTUyNjE4MX0.kiSw8qtwUtmtG-so46t5Z6kY9ETeq6QwxvcesuILcwc' // Remplacez par votre clé anonyme
  );
  Get.put(HomeController()); 
  Get.put(RecipeController()); 
  



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Miniprojet",
      theme: ThemeData(
        primaryColor: const Color(0xFF593AD5),
        scaffoldBackgroundColor: const Color(0XFFF5F5F5),
      ),
      home: LoginScreen(),
      routes: {
  '/login': (_) => LoginScreen(),
  '/signup': (_) => SignupScreen(),
  '/homescreen': (_) => RootPage(),
},
    );
  }
}
