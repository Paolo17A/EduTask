import 'package:edutask/firebase_options.dart';
import 'package:edutask/screens/admin_home_screen.dart';
import 'package:edutask/screens/admin_login_screen.dart';
import 'package:edutask/screens/admin_sections_screen.dart';
import 'package:edutask/screens/teacher_home_screen.dart';
import 'package:edutask/screens/teacher_login_screen.dart';
import 'package:edutask/screens/teacher_register_screen.dart';
import 'package:edutask/screens/welcome_screen.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

final Map<String, WidgetBuilder> _routes = {
  NavigatorRoutes.welcome: (context) => const WelcomeScreen(),
  //  TEACHER
  NavigatorRoutes.teacherLogin: (context) => const TeacherLoginScreen(),
  NavigatorRoutes.teacherRegister: (context) => const TeacherRegisterScreen(),
  NavigatorRoutes.teacherHome: (context) => const TeacherHomeScreen(),

  //ADMIN
  NavigatorRoutes.adminLogin: (context) => const AdminLoginScreen(),
  NavigatorRoutes.adminHome: (context) => const AdminHomeScreen(),
  NavigatorRoutes.adminSections: (context) => const AdminSectionsScreen()
};

final ThemeData _themeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
    scaffoldBackgroundColor: Colors.white,
    snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.grey,
        contentTextStyle: TextStyle(color: Colors.black)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false),
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.grey,
        iconTheme: IconThemeData(color: Colors.black)),
    listTileTheme: const ListTileThemeData(
        iconColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            textStyle: const TextStyle(color: Colors.black))),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                decoration: TextDecoration.underline))),
    tabBarTheme: const TabBarTheme(labelColor: Colors.black));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduTask',
      theme: _themeData,
      routes: _routes,
      initialRoute: '/',
    );
  }
}
