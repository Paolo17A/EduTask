// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/util/quit_dialogue_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:edutask/widgets/edutask_text_field_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../util/color_util.dart';

class AnswerAssignmentScreen extends StatefulWidget {
  final String assignmentID;
  final bool fromHomeScreen;
  const AnswerAssignmentScreen(
      {super.key, required this.assignmentID, this.fromHomeScreen = false});

  @override
  State<AnswerAssignmentScreen> createState() => _AnswerAssignmentScreenState();
}

class _AnswerAssignmentScreenState extends State<AnswerAssignmentScreen> {
  bool _isLoading = true;

  String title = '';
  String directions = '';
  String assignmentType = '';

  //  ESSAY
  final essayController = TextEditingController();

  //  FILE UPLOAD
  File? selectedFormFile;
  String? selectedFileName;
  String? selectedExtension;

  @override
  void dispose() {
    super.dispose();
    essayController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAssignmentData();
  }

  void getAssignmentData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final assignment = await FirebaseFirestore.instance
          .collection('assignments')
          .doc(widget.assignmentID)
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
          SnackBar(content: Text('Error getting assignment data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future pickFormFile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          selectedFormFile = File(result.files.first.path!);
          selectedExtension = result.files.first.extension;
          selectedFileName = result.files.first.name;
        });
      } else {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Selected File is null.')));
      }
    } catch (error) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error picking file: $error')));
    }
  }

  void submitAssignment() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (assignmentType == 'ESSAY' && essayController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Please fill up the essay question.')));
      return;
    }
    if (assignmentType == 'FILE UPLOAD' && selectedFormFile == null) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Please select a file to upload')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      String submissionID = DateTime.now().millisecondsSinceEpoch.toString();

      if (assignmentType == 'ESSAY') {
        await FirebaseFirestore.instance
            .collection('submissions')
            .doc(submissionID)
            .set({
          'studentID': FirebaseAuth.instance.currentUser!.uid,
          'assignmentID': widget.assignmentID,
          'assignmentType': assignmentType,
          'submission': essayController.text,
          'isGraded': false,
          'grade': 0,
          'remarks': '',
          'dateSubmitted': DateTime.now()
        });
      }

      if (assignmentType == 'FILE UPLOAD') {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('submissions')
            .child(widget.assignmentID)
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child(selectedFileName!);

        final uploadTask = storageRef.putFile(selectedFormFile!);
        final taskSnapshot = await uploadTask.whenComplete(() {});
        final downloadURL = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('submissions')
            .doc(submissionID)
            .set({
          'studentID': FirebaseAuth.instance.currentUser!.uid,
          'assignmentID': widget.assignmentID,
          'assignmentType': assignmentType,
          'submission': downloadURL,
          'isGraded': false,
          'grade': 0,
          'remarks': ''
        });
      }

      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Successfully submitted this essay assignment.')));
      navigator.pop();
      if (widget.fromHomeScreen) {
        navigator.pushReplacementNamed(NavigatorRoutes.studentHome);
      } else {
        navigator.pushReplacementNamed(NavigatorRoutes.studentSubmittables);
      }
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error submitting essay assignment: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  //  BUILD WIDGETS
  //============================================================================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => displayExitDialogue(context),
      child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: homeAppBarWidget(context,
                backgroundColor: CustomColors.verySoftOrange, mayGoBack: true),
            body: stackedLoadingContainer(
              context,
              _isLoading,
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: all20Pix(
                      child: Column(children: [
                    interText(title, fontWeight: FontWeight.bold, fontSize: 27),
                    _directions(),
                    if (assignmentType == 'ESSAY')
                      _essayFields()
                    else if (assignmentType == 'FILE UPLOAD')
                      _fileUploadFields(),
                    _submitAssignment()
                  ])),
                ),
              ),
            ),
          )),
    );
  }

  Widget _directions() {
    return vertical20Pix(child: interText(directions, fontSize: 19));
  }

  Widget _essayFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Type your essay here', fontWeight: FontWeight.bold),
        vertical10horizontal4(
          EduTaskTextField(
              text: 'Type your essay here.',
              controller: essayController,
              textInputType: TextInputType.multiline,
              displayPrefixIcon: null,
              maxLines: 15),
        ),
      ],
    );
  }

  Widget _fileUploadFields() {
    return Column(children: [
      if (selectedFileName != null)
        Text(selectedFileName!, style: const TextStyle(color: Colors.black)),
      ovalButton('SELECT FILE',
          onPress: () => pickFormFile(),
          backgroundColor: CustomColors.softOrange),
    ]);
  }

  Widget _submitAssignment() {
    return vertical20Pix(
        child: ovalButton('SUBMIT ASSIGNMENT',
            onPress: () => submitAssignment(),
            backgroundColor: CustomColors.softOrange));
  }
}
