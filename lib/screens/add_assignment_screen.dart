import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/selected_subject_provider.dart';
import 'package:edutask/util/color_util.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../widgets/custom_text_widgets.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/edutask_text_field_widget.dart';

class AddAssignmentScreen extends ConsumerStatefulWidget {
  const AddAssignmentScreen({super.key});

  @override
  ConsumerState<AddAssignmentScreen> createState() =>
      _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends ConsumerState<AddAssignmentScreen> {
  bool _isLoading = false;

  String assignmentType = '';
  final titleController = TextEditingController();
  final directionsController = TextEditingController();
  int selectedQuarter = 1;
  DateTime? deadline;

  void createAssignment() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (titleController.text.isEmpty ||
        directionsController.text.isEmpty ||
        deadline == null) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all provided fields.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      String assignmentID = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(assignmentID)
          .set({
        'teacherID': FirebaseAuth.instance.currentUser!.uid,
        'subject': ref.read(selectedSubjectProvider),
        'title': titleController.text,
        'directions': directionsController.text,
        'assignmentType': 'FILE UPLOAD',
        'deadline': deadline,
        'associatedSections': [],
        'dateLastModified': DateTime.now(),
        'quarter': selectedQuarter
      });

      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully created new assignment!')));
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.lessonPlan);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error creating new assignment: $error')));
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
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey)),
            child: child!));
    if (picked != null && picked != DateTime.now()) {
      if (picked.difference(DateTime.now()).inDays < 1) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Event date must be at least 1 day from now.')));
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
        appBar: homeAppBarWidget(context),
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  newAssignmentHeader(),
                  Gap(30),
                  //_assignmentType(),
                  _assignmentTitle(),
                  _assignmentDirections(),
                  _quarterDropdown(),
                  _dateSelectionContainer(),
                  Gap(30),
                  ovalButton('CREATE ASSIGNMENT',
                      onPress: createAssignment,
                      backgroundColor: CustomColors.veryLightGrey)
                ],
              )),
            )),
      ),
    );
  }

  Widget newAssignmentHeader() {
    return interText('NEW ${ref.read(selectedSubjectProvider)} ASSIGNMENT',
        fontSize: 40, textAlign: TextAlign.center, color: Colors.black);
  }

  /*Widget _assignmentType() {
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
  }*/

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

  Widget _quarterDropdown() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Quarter', fontSize: 18),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10)),
          child: dropdownWidget('QUARTER', (number) {
            setState(() {
              selectedQuarter = int.parse(number!);
            });
          }, ['1', '2', '3', '4'], selectedQuarter.toString(), false),
        ),
      ],
    ));
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
