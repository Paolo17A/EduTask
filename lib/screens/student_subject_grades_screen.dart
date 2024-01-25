import 'package:edutask/util/color_util.dart';
import 'package:edutask/util/future_util.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../widgets/app_bar_widgets.dart';
import '../widgets/app_bottom_nav_bar_widget.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class StudentSubjectGradesScreen extends ConsumerWidget {
  final String subject;
  const StudentSubjectGradesScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      bottomNavigationBar: clientBottomNavBar(context, index: 2),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: studentSubmittablesButton(context),
      body: SingleChildScrollView(
        child: all20Pix(
            child: Column(
          children: [
            interText('Subject: ${subject}',
                fontWeight: FontWeight.bold, fontSize: 36),
            _submittedAssignments(),
            Gap(30),
            _answeredQuizzes()
          ],
        )),
      ),
    );
  }

  Widget _submittedAssignments() {
    return Container(
      decoration: BoxDecoration(
          color: CustomColors.verySoftOrange,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Gap(10),
          interText('SUBMITTED ASSIGNMENTS',
              fontWeight: FontWeight.bold, fontSize: 20),
          Divider(
            color: CustomColors.softOrange,
          ),
          FutureBuilder(
              future: getSubmittedAssignmentsInSubject(
                  subject: subject,
                  studentID: FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return interText('-');
                } else {
                  return snapshot.data!.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return submittedAssignmentEntry(context,
                                submissionDoc: snapshot.data![index]);
                          })
                      : interText(
                          'You have no submitted assignments for this subject.',
                          fontSize: 20,
                          textAlign: TextAlign.center);
                }
              })
        ],
      ),
    );
  }

  Widget _answeredQuizzes() {
    return Container(
      decoration: BoxDecoration(
          color: CustomColors.verySoftOrange,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Gap(10),
          interText('ANSWERED QUIZZES',
              fontWeight: FontWeight.bold, fontSize: 20),
          Divider(color: CustomColors.softOrange),
          FutureBuilder(
              future: getAnsweredQuizzesInSubject(
                  subject: subject,
                  studentID: FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return interText('-');
                } else {
                  return snapshot.data!.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return answeredQuizEntry(context,
                                quizResultDoc: snapshot.data![index]);
                          })
                      : interText(
                          'You have not yet answered any quizzes for this subject.',
                          fontSize: 20,
                          textAlign: TextAlign.center);
                }
              })
        ],
      ),
    );
  }
}
