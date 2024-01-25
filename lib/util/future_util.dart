import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> getUserName(String userID) async {
  final user =
      await FirebaseFirestore.instance.collection('users').doc(userID).get();
  final userData = user.data() as Map<dynamic, dynamic>;
  return '${userData['firstName']} ${userData['lastName']}';
}

Future<List<String>> getSectionNames(List<dynamic> associatedSections) async {
  final sections = await FirebaseFirestore.instance
      .collection('sections')
      .where(FieldPath.documentId, whereIn: associatedSections)
      .get();
  final sectionDocs = sections.docs;
  return sectionDocs.map((section) {
    final sectionData = section.data();
    return sectionData['name'] as String;
  }).toList();
}

Future<String> getSectionName(String sectionID) async {
  if (sectionID.isEmpty) return '';
  final section = await FirebaseFirestore.instance
      .collection('sections')
      .doc(sectionID)
      .get();
  final sectionData = section.data() as Map<dynamic, dynamic>;
  return sectionData['name'];
}

Future<List<DocumentSnapshot>> getPendingAssignments(String sectionID) async {
  if (sectionID.isEmpty) return [];

  List<DocumentSnapshot> pendingAssignments = [];
  final assignments = await FirebaseFirestore.instance
      .collection('assignments')
      .where('associatedSections', arrayContains: sectionID)
      .get();
  pendingAssignments = assignments.docs;

  final submissions = await FirebaseFirestore.instance
      .collection('submissions')
      .where('studentID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();

  List<dynamic> completedAssignmentIDs = submissions.docs.map((submission) {
    final submissionData = submission.data();
    return submissionData['assignmentID'];
  }).toList();

  pendingAssignments = pendingAssignments.where((assignment) {
    return !completedAssignmentIDs.contains(assignment.id);
  }).toList();

  return pendingAssignments;
}

Future<List<DocumentSnapshot>> getSubmittedAssignmentsInSubject(
    {required String subject, required String studentID}) async {
  final submissions = await FirebaseFirestore.instance
      .collection('submissions')
      .where('studentID', isEqualTo: studentID)
      .where('subject', isEqualTo: subject)
      .where('isGraded', isEqualTo: true)
      .get();

  return submissions.docs;
}

Future<List<DocumentSnapshot>> getAnsweredQuizzesInSubject(
    {required String subject, required String studentID}) async {
  final submissions = await FirebaseFirestore.instance
      .collection('quizResults')
      .where('studentID', isEqualTo: studentID)
      .where('subject', isEqualTo: subject)
      .get();

  return submissions.docs;
}

Future<DocumentSnapshot> getCorrespondingAssignment(String assignmentID) async {
  final assignment = await FirebaseFirestore.instance
      .collection('assignments')
      .doc(assignmentID)
      .get();
  return assignment;
}

Future<DocumentSnapshot> getCorrespondingQuiz(String quizID) async {
  final quiz =
      await FirebaseFirestore.instance.collection('quizzes').doc(quizID).get();
  return quiz;
}

Future<List<DocumentSnapshot>> getPendingQuizzes(String sectionID) async {
  if (sectionID.isEmpty) return [];

  List<DocumentSnapshot> pendingQuizzes = [];
  final assignments = await FirebaseFirestore.instance
      .collection('quizzes')
      .where('associatedSections', arrayContains: sectionID)
      .get();
  pendingQuizzes = assignments.docs;

  final quizResults = await FirebaseFirestore.instance
      .collection('quizResults')
      .where('studentID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();

  List<dynamic> completedQuizIDs = quizResults.docs.map((quizResult) {
    final quizResultData = quizResult.data();
    return quizResultData['quizID'];
  }).toList();
  pendingQuizzes = pendingQuizzes
      .where((quiz) => !completedQuizIDs.contains(quiz.id))
      .toList();

  return pendingQuizzes;
}

Future<List<DocumentSnapshot>> getSubmissionsToCheck() async {
  List<DocumentSnapshot> submissionsToCheck = [];

  //  1. Get all the assignment IDs created by the currently logged in teacher
  final assignments = await FirebaseFirestore.instance
      .collection('assignments')
      .where('teacherID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();
  List<dynamic> associatedAssignmentIDs =
      assignments.docs.map((e) => e.id).toList();

  //  2. Get all submissions that aren't graded yet and where the assignmentID
  //  is part of the teacher's associated AssignmentIDs
  final submissions = await FirebaseFirestore.instance
      .collection('submissions')
      .where('isGraded', isEqualTo: false)
      .get();

  submissionsToCheck = submissions.docs.where((submission) {
    final submissionData = submission.data();
    final assignmentID = submissionData['assignmentID'];
    return associatedAssignmentIDs.contains(assignmentID);
  }).toList();

  return submissionsToCheck;
}

Future<String> getAssignmentTitle(String assignmentID) async {
  final assignment = await FirebaseFirestore.instance
      .collection('assignments')
      .doc(assignmentID)
      .get();
  final assignmentData = assignment.data() as Map<dynamic, dynamic>;
  return assignmentData['title'];
}
