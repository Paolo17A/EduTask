import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/color_util.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/dropdown_widget.dart';
import '../widgets/edutask_text_field_widget.dart';

class AdminEditStudentScreen extends ConsumerStatefulWidget {
  final DocumentSnapshot studentDoc;
  const AdminEditStudentScreen({super.key, required this.studentDoc});

  @override
  ConsumerState<AdminEditStudentScreen> createState() =>
      _AdminEditStudentScreenState();
}

class _AdminEditStudentScreenState
    extends ConsumerState<AdminEditStudentScreen> {
  bool _isLoading = true;
  final studentNumberController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  List<DocumentSnapshot> availableSectionDocs = [];
  String selectedSection = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final studentData = widget.studentDoc.data() as Map<dynamic, dynamic>;
      studentNumberController.text = studentData['IDNumber'];
      firstNameController.text = studentData['firstName'];
      lastNameController.text = studentData['lastName'];
      final sections =
          await FirebaseFirestore.instance.collection('sections').get();
      availableSectionDocs = sections.docs;
      selectedSection = studentData['section'];
      setState(() {
        _isLoading = false;
      });
    });
  }

  void saveStudentData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentDoc.id)
          .update({
        'userType': 'STUDENT',
        'IDNumber': studentNumberController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'section': selectedSection
      });
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully savedc student data.')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.adminStudentRecords);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error saving student data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: homeAppBarWidget(context,
            backgroundColor: CustomColors.verySoftCyan,
            mayGoBack: true,
            actions: [
              ElevatedButton(
                  onPressed: saveStudentData,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.moderateCyan),
                  child: interText('SAVE\nSTUDENT',
                      color: Colors.white, textAlign: TextAlign.center))
            ]),
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  _studentHeader(),
                  _studentIDNumber(),
                  _studentFirstName(),
                  _studentLastName(),
                  if (availableSectionDocs.isNotEmpty) _sectionDropdown()
                ],
              )),
            )),
      ),
    );
  }

  Widget _studentHeader() {
    return interText('Edit\n Student Profile',
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        textAlign: TextAlign.center);
  }

  Widget _studentIDNumber() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Student ID Number', fontSize: 20, color: Colors.black),
        EduTaskTextField(
            text: '',
            controller: studentNumberController,
            textInputType: TextInputType.number,
            displayPrefixIcon: null)
      ],
    ));
  }

  Widget _studentFirstName() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Student First Name', fontSize: 20, color: Colors.black),
        EduTaskTextField(
            text: '',
            controller: firstNameController,
            textInputType: TextInputType.name,
            displayPrefixIcon: null)
      ],
    ));
  }

  Widget _studentLastName() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Student Last Name', fontSize: 20, color: Colors.black),
        EduTaskTextField(
            text: '',
            controller: lastNameController,
            textInputType: TextInputType.name,
            displayPrefixIcon: null)
      ],
    ));
  }

  Widget _sectionDropdown() {
    return vertical10horizontal4(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Student Section', fontSize: 20, color: Colors.black),
          sectionDocumentSnapshotDropdownWidget(
              selectedSection.isNotEmpty
                  ? selectedSection
                  : availableSectionDocs.first.id, (newVal) {
            setState(() {
              selectedSection = newVal!;
            });
          }, availableSectionDocs),
        ],
      ),
    );
  }
}
