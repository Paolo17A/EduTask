import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/teacher_subject_provider.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../util/future_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class TeacherSelectedStudentGradesScreen extends ConsumerStatefulWidget {
  final DocumentSnapshot studentDoc;
  const TeacherSelectedStudentGradesScreen(
      {super.key, required this.studentDoc});

  @override
  ConsumerState<TeacherSelectedStudentGradesScreen> createState() =>
      _TeacherSelectedStudentGradesScreenState();
}

class _TeacherSelectedStudentGradesScreenState
    extends ConsumerState<TeacherSelectedStudentGradesScreen> {
  late String formattedName;

  @override
  void initState() {
    super.initState();
    final studentData = widget.studentDoc.data() as Map<dynamic, dynamic>;
    formattedName = '${studentData['firstName']} ${studentData['lastName']}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      bottomNavigationBar: teacherBottomNavBar(context, index: 1),
      body: SingleChildScrollView(
        child: all20Pix(
            child: Column(
          children: [
            _studentData(),
            Gap(30),
            _studentAssignments(),
            Gap(20),
            _answeredQuizzes()
          ],
        )),
      ),
    );
  }

  Widget _studentData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Student: $formattedName',
            fontWeight: FontWeight.bold, fontSize: 28)
      ],
    );
  }

  Widget _studentAssignments() {
    return Container(
      decoration: BoxDecoration(
          color: CustomColors.verySoftOrange,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          interText('GRADED ${ref.read(teacherSubjectProvider)} ASSIGNMENTS',
              fontWeight: FontWeight.bold, fontSize: 20),
          Divider(color: CustomColors.softOrange),
          FutureBuilder(
              future: getSubmittedAssignmentsInSubject(
                  subject: ref.read(teacherSubjectProvider),
                  studentID: widget.studentDoc.id),
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
                          'This student has yet answered any quizzes for this subject.',
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
          interText('ANSWERED ${ref.read(teacherSubjectProvider)} QUIZZES',
              fontWeight: FontWeight.bold, fontSize: 20),
          Divider(color: CustomColors.softOrange),
          FutureBuilder(
              future: getAnsweredQuizzesInSubject(
                  subject: ref.read(teacherSubjectProvider),
                  studentID: widget.studentDoc.id),
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
                          'This student has not yet answered any quizzes for this subject.',
                          fontSize: 20,
                          textAlign: TextAlign.center);
                }
              })
        ],
      ),
    );
  }
}
