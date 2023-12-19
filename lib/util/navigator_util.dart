import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/screens/admin_selected_section_screen.dart';
import 'package:edutask/screens/answer_assignment_screen.dart';
import 'package:edutask/screens/answer_quiz_screen.dart';
import 'package:edutask/screens/edit_lesson_screen.dart';
import 'package:edutask/screens/edit_quiz_screen.dart';
import 'package:edutask/screens/selected_lesson_screen.dart';
import 'package:edutask/screens/selected_quiz_result_screen.dart';
import 'package:edutask/screens/selected_submission_screen.dart';
import 'package:edutask/screens/selected_user_record_screen.dart';
import 'package:edutask/screens/teacher_selected_section_screen.dart';
import 'package:flutter/material.dart';

import '../screens/edit_assignment_screen.dart';

class NavigatorRoutes {
  static const welcome = '/';
  static const resetPassword = '/resetPassword';
  static const changePassword = '/changePassword';

  static void selectedLesson(BuildContext context, {required String lessonID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SelectedLessonScreen(lessonID: lessonID)));
  }

  static void selectedSubmission(BuildContext context,
      {required String submissionID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            SelectedSubmissionScreen(submissionID: submissionID)));
  }

  static void answerQuiz(BuildContext context, {required String quizID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AnswerQuizScreen(quizID: quizID)));
  }

  static void selectedQuizResult(BuildContext context,
      {required String quizResultID, bool isReplacing = false}) {
    if (isReplacing) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>
              SelectedQuizResultScreen(quizResultID: quizResultID)));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              SelectedQuizResultScreen(quizResultID: quizResultID)));
    }
  }

  //  TEACHER
  static const teacherLogin = '/teacherLogin';
  static const teacherRegister = '/teacherRegister';
  static const teacherHome = '/teacherHome';
  static const teacherProfile = '/teacherProfile';
  static const teacherHandledSections = '/teacherHandledSections';
  static const lessonPlan = '/lessonPlan';
  static const addLesson = '/addLesson';
  static const addAssignment = '/addAssignment';
  static const addQuiz = '/addQuiz';

  static void teacherSelectedSection(BuildContext context,
      {required String sectionID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            TeacherSelectedSectionScreen(sectionID: sectionID)));
  }

  static void editLesson(BuildContext context, {required String lessonID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditLessonScreen(lessonID: lessonID)));
  }

  static void editAssignment(BuildContext context,
      {required String assignmentID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            EditAssignmentScreen(assignmentID: assignmentID)));
  }

  static void editQuiz(BuildContext context, {required String quizID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditQuizScreen(quizID: quizID)));
  }

  //  STUDENT
  static const studentLogin = '/studentLogin';
  static const studentRegister = '/studentRegister';
  static const studentHome = '/studentHome';
  static const studentProfile = '/studentProfile';
  static const studentLessons = '/studentLessons';
  static const studentSubmittables = '/studentSubmittables';
  static void answerAssignment(BuildContext context,
      {required String assignmentID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            AnswerAssignmentScreen(assignmentID: assignmentID)));
  }

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

  static void adminSelectedSection(BuildContext context,
      {required DocumentSnapshot sectionDoc}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            AdminSelectedSectionScreen(sectionDoc: sectionDoc)));
  }
}
