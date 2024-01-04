import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../util/color_util.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/edutask_text_field_widget.dart';

class EditAssignmentScreen extends StatefulWidget {
  final String assignmentID;
  const EditAssignmentScreen({super.key, required this.assignmentID});

  @override
  State<EditAssignmentScreen> createState() => _EditAssignmentScreenState();
}

class _EditAssignmentScreenState extends State<EditAssignmentScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;

  String assignmentType = '';
  final titleController = TextEditingController();
  final directionsController = TextEditingController();
  DateTime? deadline;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) getAssignmentData();
  }

  void getAssignmentData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final assignment = await FirebaseFirestore.instance
          .collection('assignments')
          .doc(widget.assignmentID)
          .get();
      final assignmentData = assignment.data() as Map<dynamic, dynamic>;
      assignmentType = assignmentData['assignmentType'];
      titleController.text = assignmentData['title'];
      directionsController.text = assignmentData['directions'];
      deadline = (assignmentData['deadline'] as Timestamp).toDate();
      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error getting this assignment data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void editAssignment() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (titleController.text.isEmpty ||
        directionsController.text.isEmpty ||
        assignmentType.isEmpty ||
        deadline == null) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all provided fields.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(widget.assignmentID)
          .update({
        'title': titleController.text,
        'directions': directionsController.text,
        'assignmentType': assignmentType,
        'teacherID': FirebaseAuth.instance.currentUser!.uid,
        'deadline': deadline,
        'associatedSections': []
      });

      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully created new assignment!')));
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.lessonPlan);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error editing this assignment: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void selectDateTime() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
        builder: (context, child) => Theme(
            data: ThemeData().copyWith(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: CustomColors.softLimeGreen)),
            child: child!));
    if (picked != null && picked != DateTime.now()) {
      if (picked.difference(DateTime.now()).inDays < 2) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Event date must be at least 2 days from now.')));
        return;
      }
      setState(() {
        deadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: homeAppBarWidget(context,
            backgroundColor: CustomColors.lightGreyishLimeGreen),
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  newAssignmentHeader(),
                  Gap(30),
                  _assignmentType(),
                  _assignmentTitle(),
                  _assignmentDirections(),
                  _dateSelectionContainer(),
                  Gap(30),
                  ovalButton('EDIT ASSIGNMENT',
                      onPress: editAssignment,
                      backgroundColor: CustomColors.softLimeGreen)
                ],
              )),
            )),
      ),
    );
  }

  Widget newAssignmentHeader() {
    return interText('NEW ASSIGNMENT',
        fontSize: 40, textAlign: TextAlign.center, color: Colors.black);
  }

  Widget _assignmentType() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Assignment Type', fontSize: 18),
        Container(
          decoration: BoxDecoration(
              border: Border.all(), borderRadius: BorderRadius.circular(20)),
          child: dropdownWidget(assignmentType, (newVal) {
            setState(() {
              assignmentType = newVal!;
            });
          }, ['ESSAY', 'FILE UPLOAD'], assignmentType, false),
        ),
      ],
    ));
  }

  Widget _assignmentTitle() {
    return vertical10horizontal4(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Assignment Title', fontSize: 18),
          EduTaskTextField(
              text: 'Assignment Title',
              controller: titleController,
              textInputType: TextInputType.text,
              displayPrefixIcon: null),
        ],
      ),
    );
  }

  Widget _assignmentDirections() {
    return vertical10horizontal4(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Assignment Directions', fontSize: 18),
          EduTaskTextField(
              text: 'Assignment Directions',
              controller: directionsController,
              textInputType: TextInputType.multiline,
              displayPrefixIcon: null),
        ],
      ),
    );
  }

  Widget _dateSelectionContainer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      child: ElevatedButton(
        onPressed: selectDateTime,
        child: interText(
            deadline != null
                ? DateFormat('MMM dd, yyyy').format(deadline!)
                : 'Select Assignment Deadline',
            color: Colors.black,
            fontSize: 20),
      ),
    );
  }
}
