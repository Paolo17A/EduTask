import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/navigator_util.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/edutask_text_field_widget.dart';

class AddSectionScreen extends StatefulWidget {
  const AddSectionScreen({super.key});

  @override
  State<AddSectionScreen> createState() => _AddSectionScreenState();
}

class _AddSectionScreenState extends State<AddSectionScreen> {
  bool _isLoading = true;

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
          .where('section', isNotEqualTo: '')
          .get();
      studentDocs = students.docs;
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
      Navigator.of(context).pop();
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
        'students': []
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
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully added new section')));
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
    return Scaffold(
      appBar: homeAppBarWidget(context),
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
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [_teacherColumn(), _studentsColumn()]),
                const Gap(15),
                ovalButton('ADD NEW SECTION', onPress: addNewSection)
              ],
            )),
          )),
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

  Widget _teacherColumn() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _scienceTeachers(),
          _mathTeachers(),
          _englishTeachers(),
        ],
      ),
    );
  }

  Widget _studentsColumn() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
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
            child: userDocumentSnapshotDropdownWidget(selectedScienceTeacherID,
                (newVal) {
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
        if (scienceTeachers.isNotEmpty)
          Container(
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(20)),
            child: userDocumentSnapshotDropdownWidget(selectedMathTeacherID,
                (newVal) {
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
        if (scienceTeachers.isNotEmpty)
          Container(
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(20)),
            child: userDocumentSnapshotDropdownWidget(selectedMathTeacherID,
                (newVal) {
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
}
