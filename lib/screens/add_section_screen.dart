import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/future_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../util/navigator_util.dart';
import '../widgets/app_bottom_nav_bar_widget.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/edutask_text_field_widget.dart';

class AddSectionScreen extends StatefulWidget {
  const AddSectionScreen({super.key});

  @override
  State<AddSectionScreen> createState() => _AddSectionScreenState();
}

class _AddSectionScreenState extends State<AddSectionScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;

  final sectionNameController = TextEditingController();

  //  TEACHERS
  List<DocumentSnapshot> availableAdvisers = [];
  String selectedAdviserID = '';

  //  STUDENTS
  List<DocumentSnapshot> studentDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) getAllTeachers();
  }

  void getAllTeachers() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      List<DocumentSnapshot> teacherDocs = await getTeacherDocs();
      if (teacherDocs.isEmpty) {
        print('no teachers');
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('There are no more available teachers.')));
        navigator.pop();
        return;
      }
      availableAdvisers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String advisorySection = teacherData['advisorySection'];
        return advisorySection.isEmpty;
      }).toList();

      if (availableAdvisers.isEmpty) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(
                'There are no more available teachers to be this section\'s adviser.')));
        navigator.pop();
        return;
      }
      selectedAdviserID = availableAdvisers.first.id;
      final students = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'STUDENT')
          .get();
      studentDocs = students.docs;
      studentDocs = studentDocs.where(
        (student) {
          final studentData = student.data() as Map<dynamic, dynamic>;
          return studentData['section'].toString().isEmpty;
        },
      ).toList();
      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all teachers: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void addNewSection() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (sectionNameController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please provide a section name.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      String sectionID = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(sectionID)
          .set({
        'name': sectionNameController.text,
        'adviser': selectedAdviserID,
        'teachers': [],
        'students': [],
        'assignments': [],
        'quizzes': [],
        'lessons': []
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(selectedAdviserID)
          .update({'advisorySection': sectionID});
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully added new section')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.adminSectionRecords);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all sections: $error')));
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
        appBar: homeAppBarWidget(context),
        bottomNavigationBar: adminBottomNavBar(context, index: 0),
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  _newSectionHeader(),
                  const Gap(20),
                  _sectionName(),
                  _availableAdvisers(),
                  ovalButton('ADD NEW SECTION',
                      onPress: addNewSection,
                      backgroundColor: CustomColors.softOrange)
                ],
              )),
            )),
      ),
    );
  }

  Widget _newSectionHeader() {
    return interText('New Section Profile',
        fontSize: 40, textAlign: TextAlign.center);
  }

  Widget _sectionName() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Section Name', fontSize: 18),
        EduTaskTextField(
            text: 'Section Name',
            controller: sectionNameController,
            textInputType: TextInputType.text,
            displayPrefixIcon: const Icon(Icons.lock)),
      ],
    ));
  }

  Widget _availableAdvisers() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Section Adviser', fontSize: 18),
        if (availableAdvisers.isNotEmpty)
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(5),
            child: userDocumentSnapshotDropdownWidget(
                context,
                selectedAdviserID.isNotEmpty
                    ? selectedAdviserID
                    : availableAdvisers.first.id, (newVal) {
              setState(() {
                selectedAdviserID = newVal!;
              });
            }, availableAdvisers),
          )
        else
          interText('NO AVAILABLE TEACHERS AVAILABLE',
              fontWeight: FontWeight.bold)
      ],
    ));
  }
}
