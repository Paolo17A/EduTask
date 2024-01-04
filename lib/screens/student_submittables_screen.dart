import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../util/color_util.dart';
import '../widgets/custom_text_widgets.dart';

class StudentSubmittablesScreen extends StatefulWidget {
  const StudentSubmittablesScreen({super.key});

  @override
  State<StudentSubmittablesScreen> createState() =>
      _StudentSubmittablesScreenState();
}

class _StudentSubmittablesScreenState extends State<StudentSubmittablesScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> assignmentDocs = [];
  List<DocumentSnapshot> quizDocs = [];
  List<DocumentSnapshot> submissionDocs = [];
  List<DocumentSnapshot> quizResultDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getSectionSubmittables();
  }

  void getSectionSubmittables() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final userData = user.data() as Map<dynamic, dynamic>;

      String section = userData['section'];
      final sectionDoc = await FirebaseFirestore.instance
          .collection('sections')
          .doc(section)
          .get();
      List<dynamic> assignmentIDs = sectionDoc['assignments'];
      List<dynamic> quizIDs = sectionDoc['quizzes'];

      if (assignmentIDs.isNotEmpty) {
        final assignments = await FirebaseFirestore.instance
            .collection('assignments')
            .where(FieldPath.documentId, whereIn: assignmentIDs)
            .get();
        assignmentDocs = assignments.docs;
      }

      if (quizIDs.isNotEmpty) {
        final quizzes = await FirebaseFirestore.instance
            .collection('quizzes')
            .where(FieldPath.documentId, whereIn: quizIDs)
            .get();
        quizDocs = quizzes.docs;
      }

      final submissions = await FirebaseFirestore.instance
          .collection('submissions')
          .where('studentID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      submissionDocs = submissions.docs;

      final quizResults = await FirebaseFirestore.instance
          .collection('quizResults')
          .where('studentID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      quizResultDocs = quizResults.docs;
      print('quizResultDocs fouind: ${quizResultDocs.length}');

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error getting section submittables: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context,
          backgroundColor: CustomColors.verySoftOrange, mayGoBack: true),
      drawer: appDrawer(context,
          backgroundColor: CustomColors.verySoftOrange, userType: 'STUDENT'),
      bottomNavigationBar: userBottomNavBar(context,
          index: 3,
          userType: 'STUDENT',
          backgroundColor: CustomColors.verySoftOrange),
      body: switchedLoadingContainer(
          _isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
              children: [_assigments(), _quizzes()],
            )),
          )),
    );
  }

  Widget _assigments() {
    return vertical20Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange.withOpacity(0.5),
        backgroundColor: CustomColors.softOrange.withOpacity(0.5),
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('ASSIGNMENTS'),
        children: [
          assignmentDocs.isNotEmpty
              ? SizedBox(
                  height: assignmentDocs.length * 90,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: assignmentDocs.length,
                      itemBuilder: (context, index) =>
                          _assignmentEntry(assignmentDocs[index], index)),
                )
              : interText('NO ASSIGNED ASSIGNMENTS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _assignmentEntry(DocumentSnapshot assignmentDoc, int index) {
    final assignmentData = assignmentDoc.data() as Map<dynamic, dynamic>;
    String title = assignmentData['title'];
    String subject = assignmentData['subject'];
    DateTime deadline = (assignmentData['deadline'] as Timestamp).toDate();
    String formattedGrade = 'N/A';
    bool isGraded = false;

    //  Search for a matching submission for this assignment.
    List<DocumentSnapshot> matchingSubmissions =
        submissionDocs.where((submission) {
      final submissionData = submission.data() as Map<dynamic, dynamic>;
      String assignmentID = submissionData['assignmentID'];

      return assignmentID == assignmentDoc.id;
    }).toList();

    //  If the student has a submission for this assignment, check if it was already graded
    if (matchingSubmissions.isNotEmpty) {
      DocumentSnapshot matchingSubmission = matchingSubmissions.first;
      final submissionData = matchingSubmission.data() as Map<dynamic, dynamic>;
      num grade = submissionData['grade'];
      isGraded = submissionData['isGraded'];
      formattedGrade = grade.toString();
    }
    return Container(
      height: 80,
      color: index % 2 == 0 ? Colors.grey.withOpacity(0.25) : Colors.white,
      padding: EdgeInsets.all(5),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    interText(title,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis),
                    interText(subject, fontSize: 15),
                    interText(
                        'Due Date: ${DateFormat('MMM dd, yyyy').format(deadline)}')
                  ]),
            ),
            if (matchingSubmissions.isNotEmpty && isGraded)
              interText(formattedGrade,
                  fontWeight: FontWeight.bold, fontSize: 20)
            else if (matchingSubmissions.isNotEmpty && !isGraded)
              ovalButton('VIEW\nSUBMISSION',
                  onPress: () => NavigatorRoutes.selectedSubmission(context,
                      submissionID: matchingSubmissions.first.id),
                  backgroundColor: CustomColors.softOrange)
            else
              ovalButton('ANSWER\nASSIGNMENT',
                  onPress: () => NavigatorRoutes.answerAssignment(context,
                      assignmentID: assignmentDoc.id),
                  backgroundColor: CustomColors.softOrange)
          ]),
    );
  }

  Widget _quizzes() {
    return vertical20Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange.withOpacity(0.5),
        backgroundColor: CustomColors.softOrange.withOpacity(0.5),
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUIZZES'),
        children: [
          quizDocs.isNotEmpty
              ? SizedBox(
                  height: quizDocs.length * 90,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quizDocs.length,
                      itemBuilder: (context, index) =>
                          _quizEntry(quizDocs[index], index)),
                )
              : interText('NO ASSIGNED QUIZZES', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quizEntry(DocumentSnapshot quizDoc, int index) {
    final quizData = quizDoc.data() as Map<dynamic, dynamic>;
    String title = quizData['title'];
    String subject = quizData['subject'];

    //  Search for a matching submission for this assignment.
    List<DocumentSnapshot> matchingQuizResults =
        quizResultDocs.where((quizResult) {
      final quizResultData = quizResult.data() as Map<dynamic, dynamic>;
      String quizID = quizResultData['quizID'];
      return quizID == quizDoc.id;
    }).toList();

    return Container(
      height: 70,
      color: index % 2 == 0 ? Colors.grey.withOpacity(0.25) : Colors.white,
      padding: EdgeInsets.all(5),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    interText(title,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis),
                    interText(subject, fontSize: 15),
                  ]),
            ),
            if (matchingQuizResults.isNotEmpty)
              ovalButton('VIEW\nRESULTS',
                  onPress: () => NavigatorRoutes.selectedQuizResult(context,
                      quizResultID: matchingQuizResults.first.id),
                  backgroundColor: CustomColors.softOrange)
            else
              ovalButton('ANSWER\nQUIZ',
                  onPress: () =>
                      NavigatorRoutes.answerQuiz(context, quizID: quizDoc.id),
                  backgroundColor: CustomColors.softOrange)
          ]),
    );
  }
}
