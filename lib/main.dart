import 'package:edutask/firebase_options.dart';
import 'package:edutask/screens/add_assignment_screen.dart';
import 'package:edutask/screens/add_lesson_screen.dart';
import 'package:edutask/screens/add_quiz_screen.dart';
import 'package:edutask/screens/add_section_screen.dart';
import 'package:edutask/screens/admin_add_student_screen.dart';
import 'package:edutask/screens/admin_add_teacher_screen.dart';
import 'package:edutask/screens/admin_all_assignments_screen.dart';
import 'package:edutask/screens/admin_all_lessons_screen.dart';
import 'package:edutask/screens/admin_all_quizzes_screen.dart';
import 'package:edutask/screens/admin_home_screen.dart';
import 'package:edutask/screens/admin_login_screen.dart';
import 'package:edutask/screens/admin_materials_screen.dart';
import 'package:edutask/screens/admin_profile_screen.dart';
import 'package:edutask/screens/admin_section_records_screen.dart';
import 'package:edutask/screens/admin_student_records_screen.dart';
import 'package:edutask/screens/admin_teacher_records_screen.dart';
import 'package:edutask/screens/change_password_screen.dart';
import 'package:edutask/screens/lesson_plan_screen.dart';
import 'package:edutask/screens/reset_password_screen.dart';
import 'package:edutask/screens/student_home_screen.dart';
import 'package:edutask/screens/student_login_screen.dart';
import 'package:edutask/screens/student_materials_subject_select_screen.dart';
import 'package:edutask/screens/student_profile_screen.dart';
import 'package:edutask/screens/student_progress_subject_select_screen.dart';
import 'package:edutask/screens/student_register_screen.dart';
import 'package:edutask/screens/student_submittables_screen.dart';
import 'package:edutask/screens/teacher_handled_sections_screen.dart';
import 'package:edutask/screens/teacher_home_screen.dart';
import 'package:edutask/screens/teacher_login_screen.dart';
import 'package:edutask/screens/teacher_make_announcement.dart';
import 'package:edutask/screens/teacher_profile_screen.dart';
import 'package:edutask/screens/teacher_register_screen.dart';
import 'package:edutask/screens/welcome_screen.dart';
import 'package:edutask/util/color_util.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ProviderScope(child: const MyApp()));
}

final Map<String, WidgetBuilder> _routes = {
  NavigatorRoutes.welcome: (context) => const WelcomeScreen(),
  NavigatorRoutes.resetPassword: (context) => const ResetPasswordScreen(),
  NavigatorRoutes.changePassword: (context) => const ChangePasswordScreen(),

  //  TEACHER
  NavigatorRoutes.teacherLogin: (context) => const TeacherLoginScreen(),
  NavigatorRoutes.teacherRegister: (context) => const TeacherRegisterScreen(),
  NavigatorRoutes.teacherHome: (context) => const TeacherHomeScreen(),
  NavigatorRoutes.teacherProfile: (context) => const TeacherProfileScreen(),
  NavigatorRoutes.teacherHandledSections: (context) =>
      TeacherHandledSectionsScreen(),
  NavigatorRoutes.lessonPlan: (context) => const LessonPlanScreen(),
  NavigatorRoutes.addLesson: (context) => const AddLessonScreen(),
  NavigatorRoutes.addAssignment: (context) => const AddAssignmentScreen(),
  NavigatorRoutes.addQuiz: (context) => const AddQuizScreen(),
  NavigatorRoutes.makeAnnouncement: (context) =>
      const TeacherMakeAnnouncementScreen(),

  //  STUDENTS
  NavigatorRoutes.studentLogin: (context) => const StudentLoginScreen(),
  NavigatorRoutes.studentRegister: (context) => const StudentRegisterScreen(),
  NavigatorRoutes.studentHome: (context) => const StudentHomeScreen(),
  NavigatorRoutes.studentProfile: (context) => const StudentProfileScreen(),
  NavigatorRoutes.studentMaterialsSubjectSelect: (context) =>
      const StudentMaterialsSubjectSelectScreen(),
  NavigatorRoutes.studentSubmittables: (context) =>
      const StudentSubmittablesScreen(),
  NavigatorRoutes.studentProgressSubjectSelect: (context) =>
      const StudentProgressSubjectSelectScreen(),

  //ADMIN
  NavigatorRoutes.adminLogin: (context) => const AdminLoginScreen(),
  NavigatorRoutes.adminHome: (context) => const AdminHomeScreen(),
  NavigatorRoutes.adminStudentRecords: (context) =>
      const AdminStudentRecordsScreen(),
  NavigatorRoutes.adminAddStudent: (context) => const AdminAddStudentScreen(),
  NavigatorRoutes.adminTeacherRecords: (context) =>
      const AdminTeacherRecordsScreen(),
  NavigatorRoutes.adminAddTeacher: (context) => const AdminAddTeacherScreen(),
  NavigatorRoutes.adminSectionRecords: (context) =>
      const AdminSectionRecordsScreen(),
  NavigatorRoutes.addSection: (context) => const AddSectionScreen(),
  NavigatorRoutes.adminProfile: (context) => const AdminProfileScreen(),
  NavigatorRoutes.adminMaterials: (context) => const AdminMaterialsScreen(),
  NavigatorRoutes.adminAllLessons: (context) => const AdminAllLessonsScreen(),
  NavigatorRoutes.adminAllAssignments: (context) =>
      const AdminAllAssignmentsScreen(),
  NavigatorRoutes.adminAllQuizzes: (context) => const AdminAllQuizzesScreen()
};

final ThemeData _themeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
    scaffoldBackgroundColor: Colors.white,
    snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.grey,
        contentTextStyle: TextStyle(color: Colors.black)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false),
    appBarTheme: const AppBarTheme(
        backgroundColor: CustomColors.veryDarkGrey,
        iconTheme: IconThemeData(color: Colors.white)),
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
