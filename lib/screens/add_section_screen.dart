import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<DocumentSnapshot> teacherDocs = [];
  List<DocumentSnapshot> scienceTeachers = [];
  String selectedScienceTeacherID = '';
  List<DocumentSnapshot> mathTeachers = [];
  String selectedMathTeacherID = '';
  List<DocumentSnapshot> englishTeachers = [];
  String selectedEnglishTeacherID = '';
  List<DocumentSnapshot> apTeachers = [];
  String selectedAPTeacherID = '';
  List<DocumentSnapshot> filipinoTeachers = [];
  String selectedFilipinoTeacherID = '';
  List<DocumentSnapshot> eppTeachers = [];
  String selectedEPPTeacherID = '';
  List<DocumentSnapshot> mapehTeachers = [];
  String selectedMAPEHTeacherID = '';
  List<DocumentSnapshot> espTeachers = [];
  String selectedESPTeacherID = '';

  //  STUDENTS
  List<DocumentSnapshot> studentDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) getAllTeachers();
  }

  void getAllTeachers() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final teachers = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'TEACHER')
          .get();
      teacherDocs = teachers.docs;

      scienceTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'SCIENCE';
      }).toList();

      mathTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'MATHEMATICS';
      }).toList();

      englishTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'ENGLISH';
      }).toList();

      filipinoTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'FILIPINO';
      }).toList();

      apTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'AP';
      }).toList();

      eppTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'EPP';
      }).toList();

      mapehTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'MAPEH';
      }).toList();

      espTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'ESP';
      }).toList();

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
        'SCIENCE': selectedScienceTeacherID,
        'MATHEMATICS': selectedMathTeacherID,
        'ENGLISH': selectedEnglishTeacherID,
        'AP': selectedAPTeacherID,
        'FILIPINO': selectedFilipinoTeacherID,
        'EPP': selectedEPPTeacherID,
        'MAPEH': selectedMAPEHTeacherID,
        'ESP': selectedESPTeacherID,
        'students': [],
        'assignments': [],
        'quizzes': [],
        'lessons': []
      });

      if (selectedScienceTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedScienceTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([sectionID])
        });
      }

      if (selectedMathTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedMathTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([sectionID])
        });
      }

      if (selectedEnglishTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedEnglishTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([sectionID])
        });
      }

      if (selectedAPTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedAPTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([sectionID])
        });
      }

      if (selectedFilipinoTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedFilipinoTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([sectionID])
        });
      }

      if (selectedEPPTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedEPPTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([sectionID])
        });
      }

      if (selectedESPTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedESPTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([sectionID])
        });
      }

      if (selectedMAPEHTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedMAPEHTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([sectionID])
        });
      }
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
                  if (!_isLoading)
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [_teacher1stColumn(), _teacher2ndColumn()]),
                  const Gap(15),
                  ovalButton('ADD NEW SECTION',
                      onPress: addNewSection,
                      backgroundColor: CustomColors.moderateCyan)
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

  Widget _teacher1stColumn() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _scienceTeachers(),
          _mathTeachers(),
          _englishTeachers(),
          _apTeachers()
        ],
      ),
    );
  }

  Widget _teacher2ndColumn() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filipinoTeachers(),
          _eppTeachers(),
          _espTeachers(),
          _mapehTeachers()
        ],
      ),
    );
  }

  Widget _scienceTeachers() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Science Teachers', fontSize: 18),
        if (scienceTeachers.isNotEmpty)
          Container(
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(20)),
            child: userDocumentSnapshotDropdownWidget(
                context, scienceTeachers.first.id, (newVal) {
              setState(() {
                selectedScienceTeacherID = newVal!;
              });
            }, scienceTeachers),
          )
        else
          interText('NO SCIENCE TEACHERS AVAILABLE',
              fontWeight: FontWeight.bold)
      ],
    ));
  }

  Widget _mathTeachers() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Math Teachers', fontSize: 18),
        if (mathTeachers.isNotEmpty)
          Container(
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(20)),
            child: userDocumentSnapshotDropdownWidget(
                context, mathTeachers.first.id, (newVal) {
              setState(() {
                selectedMathTeacherID = newVal!;
              });
            }, mathTeachers),
          )
        else
          interText('NO MATH TEACHERS AVAILABLE', fontWeight: FontWeight.bold)
      ],
    ));
  }

  Widget _englishTeachers() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('English Teachers', fontSize: 18),
        if (englishTeachers.isNotEmpty)
          Container(
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(20)),
            child: userDocumentSnapshotDropdownWidget(
                context, englishTeachers.first.id, (newVal) {
              setState(() {
                selectedEnglishTeacherID = newVal!;
              });
            }, englishTeachers),
          )
        else
          interText('NO ENGLISH TEACHERS AVAILABLE',
              fontWeight: FontWeight.bold)
      ],
    ));
  }

  Widget _apTeachers() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('AP Teachers', fontSize: 18),
        if (apTeachers.isNotEmpty)
          Container(
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(20)),
            child: userDocumentSnapshotDropdownWidget(
                context, apTeachers.first.id, (newVal) {
              setState(() {
                selectedAPTeacherID = newVal!;
              });
            }, apTeachers),
          )
        else
          interText('NO AP TEACHERS AVAILABLE', fontWeight: FontWeight.bold)
      ],
    ));
  }

  Widget _filipinoTeachers() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Filipino Teachers', fontSize: 18),
        if (filipinoTeachers.isNotEmpty)
          Container(
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(20)),
            child: userDocumentSnapshotDropdownWidget(
                context, filipinoTeachers.first.id, (newVal) {
              setState(() {
                selectedFilipinoTeacherID = newVal!;
              });
            }, filipinoTeachers),
          )
        else
          interText('NO FILIPINO TEACHERS AVAILABLE',
              fontWeight: FontWeight.bold)
      ],
    ));
  }

  Widget _eppTeachers() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('EPP Teachers', fontSize: 18),
        if (eppTeachers.isNotEmpty)
          Container(
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(20)),
            child: userDocumentSnapshotDropdownWidget(
                context, eppTeachers.first.id, (newVal) {
              setState(() {
                selectedEPPTeacherID = newVal!;
              });
            }, eppTeachers),
          )
        else
          interText('NO EPP TEACHERS AVAILABLE', fontWeight: FontWeight.bold)
      ],
    ));
  }

  Widget _espTeachers() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('ESP Teachers', fontSize: 18),
        if (espTeachers.isNotEmpty)
          Container(
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(20)),
            child: userDocumentSnapshotDropdownWidget(
                context, espTeachers.first.id, (newVal) {
              setState(() {
                selectedESPTeacherID = newVal!;
              });
            }, espTeachers),
          )
        else
          interText('NO ESP TEACHERS AVAILABLE', fontWeight: FontWeight.bold)
      ],
    ));
  }

  Widget _mapehTeachers() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('MAPEH Teachers', fontSize: 18),
        if (mapehTeachers.isNotEmpty)
          Container(
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(20)),
            child: userDocumentSnapshotDropdownWidget(
                context, mapehTeachers.first.id, (newVal) {
              setState(() {
                selectedMAPEHTeacherID = newVal!;
              });
            }, mapehTeachers),
          )
        else
          interText('NO MAPEH TEACHERS AVAILABLE', fontWeight: FontWeight.bold)
      ],
    ));
  }
}
