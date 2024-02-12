import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/color_util.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:emailjs/emailjs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_bottom_nav_bar_widget.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/edutask_text_field_widget.dart';

class AdminEditStudentScreen extends ConsumerStatefulWidget {
  final String studentID;
  const AdminEditStudentScreen({super.key, required this.studentID});

  @override
  ConsumerState<AdminEditStudentScreen> createState() =>
      _AdminEditStudentScreenState();
}

class _AdminEditStudentScreenState
    extends ConsumerState<AdminEditStudentScreen> {
  bool _isLoading = true;
  String email = '';
  final studentNumberController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  List<DocumentSnapshot> availableSectionDocs = [];
  String selectedSection = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getStudentData();
    });
  }

  void getStudentData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final student = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentID)
          .get();
      final studentData = student.data() as Map<dynamic, dynamic>;
      studentNumberController.text = studentData['IDNumber'];
      firstNameController.text = studentData['firstName'];
      lastNameController.text = studentData['lastName'];
      selectedSection = studentData['section'];
      email = studentData['email'];
      final sections =
          await FirebaseFirestore.instance.collection('sections').get();
      availableSectionDocs = sections.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting student data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void saveStudentData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final student = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentID)
          .get();
      final studentData = student.data() as Map<dynamic, dynamic>;
      String currentSection = studentData['section'];

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentID)
          .update({
        'IDNumber': studentNumberController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
      });

      if (currentSection != selectedSection) {
        await switchStudentSection(currentSection, selectedSection);
      }

      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully saved student data.')));
      setState(() {});
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

  Future switchStudentSection(String oldSection, String newSection) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentID)
          .update({'section': newSection});
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(oldSection)
          .update({
        'students': FieldValue.arrayRemove([widget.studentID])
      });
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(newSection)
          .update({
        'students': FieldValue.arrayUnion([widget.studentID])
      });
      final section = await FirebaseFirestore.instance
          .collection('sections')
          .doc(newSection)
          .get();
      final newSectionData = section.data() as Map<dynamic, dynamic>;

      await EmailJS.send(
          'service_8qicz6r',
          'template_6zzxsku',
          {
            'to_email': email,
            'to_name': '${firstNameController.text} ${lastNameController.text}',
            'message_content':
                'You have been reassigned to section ${newSectionData['name']}.'
          },
          Options(
              publicKey: 'u6vTOeKnZ6uLR3BVX',
              privateKey: 'e-HosRtW2lC5-XlLVt1WV'));
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error switching student section: $error')));
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
        appBar: homeAppBarWidget(context, mayGoBack: true, actions: [
          ElevatedButton(
              onPressed: saveStudentData,
              style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.veryLightGrey),
              child: interText('SAVE\nSTUDENT',
                  color: Colors.black, textAlign: TextAlign.center))
        ]),
        bottomNavigationBar: adminBottomNavBar(context, index: 0),
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
                  if (selectedSection.isNotEmpty &&
                      availableSectionDocs.isNotEmpty)
                    _sectionDropdown()
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
