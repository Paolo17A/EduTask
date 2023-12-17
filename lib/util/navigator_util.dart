import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/screens/selected_user_record_screen.dart';
import 'package:flutter/material.dart';

class NavigatorRoutes {
  static const welcome = '/';
  static const resetPassword = '/resetPassword';
  static const changePassword = '/changePassword';

  //  TEACHER
  static const teacherLogin = '/teacherLogin';
  static const teacherRegister = '/teacherRegister';
  static const teacherHome = '/teacherHome';
  static const teacherProfile = '/teacherProfile';

  //  STUDENT
  static const studentLogin = '/studentLogin';
  static const studentRegister = '/studentRegister';
  static const studentHome = '/studentHome';
  static const studentProfile = '/studentProfile';

  //  ADMIN
  static const adminLogin = '/adminLogin';
  static const adminHome = '/adminHome';
  static const adminStudentRecords = '/adminStudentRecords';
  static const adminTeacherRecords = '/adminTeacherRecords';
  static const adminSectionRecords = '/adminSectionRecords';
  static const addSection = '/addSection';
  static const adminProfile = '/adminProfile';

  static void selectedUserRecord(BuildContext context,
      {required DocumentSnapshot userDoc}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SelectedUserRecordScreen(userDoc: userDoc)));
  }
}
