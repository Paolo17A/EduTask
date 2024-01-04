import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/url_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

import '../util/color_util.dart';

class SelectedSubmissionScreen extends StatefulWidget {
  final String submissionID;
  const SelectedSubmissionScreen({super.key, required this.submissionID});

  @override
  State<SelectedSubmissionScreen> createState() =>
      _SelectedSubmissionScreenState();
}

class _SelectedSubmissionScreenState extends State<SelectedSubmissionScreen> {
  bool _isLoading = true;

  bool isGraded = false;
  num grade = 0;
  String title = '';
  String directions = '';
  String assignmentType = '';
  String submission = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getLessonData();
  }

  void getLessonData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      //  Get Submission Data
      final submissionDoc = await FirebaseFirestore.instance
          .collection('submissions')
          .doc(widget.submissionID)
          .get();
      final submissionData = submissionDoc.data() as Map<dynamic, dynamic>;
      isGraded = submissionData['isGraded'];
      grade = submissionData['grade'];
      submission = submissionData['submission'];

      //  Get Assignment Data
      String assignmentID = submissionData['assignmentID'];
      final assignment = await FirebaseFirestore.instance
          .collection('assignments')
          .doc(assignmentID)
          .get();
      final assignmentData = assignment.data() as Map<dynamic, dynamic>;

      title = assignmentData['title'];
      directions = assignmentData['directions'];
      assignmentType = assignmentData['assignmentType'];
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting lesson data: $error')));
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
      body: switchedLoadingContainer(
          _isLoading,
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: all20Pix(
                child: Column(
                  children: [
                    _gradeScore(),
                    Divider(),
                    _title(),
                    _direction(),
                    if (assignmentType == 'ESSAY')
                      _essaySubmission()
                    else if (assignmentType == 'FILE UPLOAD')
                      _fileUploadSubmission()
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _gradeScore() {
    return interText(isGraded ? 'GRADE: ${grade.toString()}' : 'PENDING GRADE',
        fontSize: 37, fontWeight: FontWeight.bold, color: Colors.black);
  }

  Widget _title() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: interText(title,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            textAlign: TextAlign.center));
  }

  Widget _direction() {
    return vertical10horizontal4(
      Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.all(10),
        child: interText(directions, fontSize: 18),
      ),
    );
  }

  Widget _essaySubmission() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(border: Border.all()),
      padding: EdgeInsets.all(10),
      child: interText(submission, fontSize: 18),
    );
  }

  Widget _fileUploadSubmission() {
    return ovalButton('DOWNLOAD SUBMISSION',
        onPress: () => launchThisURL(submission),
        width: MediaQuery.of(context).size.width * 0.6,
        backgroundColor: CustomColors.softOrange);
  }
}
