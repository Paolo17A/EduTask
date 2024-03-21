import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../widgets/app_bar_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class AdminSelectedAssignmentScreen extends StatefulWidget {
  final DocumentSnapshot assignmentDoc;
  const AdminSelectedAssignmentScreen({super.key, required this.assignmentDoc});

  @override
  State<AdminSelectedAssignmentScreen> createState() =>
      _AdminSelectedAssignmentScreenState();
}

class _AdminSelectedAssignmentScreenState
    extends State<AdminSelectedAssignmentScreen> {
  String title = '';
  String subject = '';
  String teacherID = '';
  List<dynamic> associatedSections = [];
  String assignmentType = '';
  String directions = '';
  int quarter = 0;
  DateTime deadline = DateTime.now();

  @override
  void initState() {
    super.initState();
    final assignmentData = widget.assignmentDoc.data() as Map<dynamic, dynamic>;
    title = assignmentData['title'];
    subject = assignmentData['subject'];
    teacherID = assignmentData['teacherID'];
    associatedSections = assignmentData['associatedSections'];
    assignmentType = assignmentData['assignmentType'];
    directions = assignmentData['directions'];
    quarter = assignmentData['quarter'];
    deadline = (assignmentData['deadline'] as Timestamp).toDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      drawer: adminBottomNavBar(context, index: 2),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: all20Pix(
              child: Column(
            children: [
              _basicAssignmentData(),
              assignedSections(associatedSections),
              _assignmentContent()
            ],
          )),
        ),
      ),
    );
  }

  Widget _basicAssignmentData() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      interText('Title: $title', fontWeight: FontWeight.bold, fontSize: 24),
      Gap(12),
      interText('Subject: $subject', fontSize: 20),
      teacherName(teacherID),
      interText('Quarter: ${quarter.toString()}'),
      interText('Deadline: ${DateFormat('MMM dd, yyyy').format(deadline)}'),
      Divider(thickness: 4),
    ]);
  }

  Widget _assignmentContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      interText('Assignment Type: $assignmentType',
          fontWeight: FontWeight.bold, fontSize: 20),
      interText('Directions:\n$directions', fontSize: 16),
      Gap(8),
      Divider(thickness: 4)
    ]);
  }
}
