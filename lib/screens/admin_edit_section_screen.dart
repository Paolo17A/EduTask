import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/edutask_text_field_widget.dart';

class AdminEditSection extends StatefulWidget {
  final String sectionID;
  const AdminEditSection({super.key, required this.sectionID});

  @override
  State<AdminEditSection> createState() => _AdminEditSectionState();
}

class _AdminEditSectionState extends State<AdminEditSection> {
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
    if (!_isInitialized) getSectionData();
  }

  void getSectionData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      //  Get Section Data
      final section = await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .get();
      final sectionData = section.data() as Map<dynamic, dynamic>;
      sectionNameController.text = sectionData['name'];
      selectedScienceTeacherID = sectionData['SCIENCE'];
      selectedMathTeacherID = sectionData['MATHEMATICS'];
      selectedEnglishTeacherID = sectionData['ENGLISH'];
      selectedAPTeacherID = sectionData['AP'];
      selectedFilipinoTeacherID = sectionData['FILIPINO'];
      selectedEPPTeacherID = sectionData['EPP'];
      selectedESPTeacherID = sectionData['ESP'];
      selectedMAPEHTeacherID = sectionData['MAPEH'];

      //  Get Teacher Data
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
      if (selectedScienceTeacherID.isEmpty && scienceTeachers.isNotEmpty) {
        selectedScienceTeacherID = scienceTeachers.first.id;
      }

      mathTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'MATHEMATICS';
      }).toList();
      if (selectedMathTeacherID.isNotEmpty && mathTeachers.isNotEmpty) {
        selectedMathTeacherID = mathTeachers.first.id;
      }

      englishTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'ENGLISH';
      }).toList();
      if (selectedEnglishTeacherID.isEmpty && englishTeachers.isNotEmpty) {
        selectedEnglishTeacherID = englishTeachers.first.id;
      }

      filipinoTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'FILIPINO';
      }).toList();
      if (selectedFilipinoTeacherID.isEmpty && filipinoTeachers.isNotEmpty) {
        selectedFilipinoTeacherID = filipinoTeachers.first.id;
      }

      apTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'AP';
      }).toList();
      if (selectedAPTeacherID.isEmpty && apTeachers.isNotEmpty) {
        selectedAPTeacherID = apTeachers.first.id;
      }

      eppTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'EPP';
      }).toList();
      if (selectedEPPTeacherID.isEmpty && eppTeachers.isNotEmpty) {
        selectedAPTeacherID = eppTeachers.first.id;
      }

      espTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'ESP';
      }).toList();
      if (selectedESPTeacherID.isEmpty && espTeachers.isNotEmpty) {
        selectedESPTeacherID = espTeachers.first.id;
      }

      mapehTeachers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String subject = teacherData['subject'];
        return subject == 'MAPEH';
      }).toList();
      if (selectedMAPEHTeacherID.isEmpty && mapehTeachers.isNotEmpty) {
        selectedMAPEHTeacherID = mapehTeachers.first.id;
      }

      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting section data: $error')));
      setState(() {
        _isLoading = true;
      });
    }
  }

  void editThisSection() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      //  Get current section data
      final section = await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .get();
      final sectionData = section.data() as Map<dynamic, dynamic>;

      String currentScienceTeacherID = sectionData['SCIENCE'];
      String currentMathTeacherID = sectionData['MATHEMATICS'];
      String currentEnglishTeacherID = sectionData['ENGLISH'];
      String currentAPTeacherID = sectionData['AP'];
      String currentFilipinoTeacherID = sectionData['FILIPINO'];
      String currentEPPTeacherID = sectionData['EPP'];
      String currentESPTeacherID = sectionData['ESP'];
      String currentMAPEHTeacherID = sectionData['MAPEH'];

      //  Start updating section data with new data
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .update({
        'name': sectionNameController.text,
        'SCIENCE': selectedScienceTeacherID,
        'MATHEMATICS': selectedMathTeacherID,
        'ENGLISH': selectedEnglishTeacherID,
        'AP': selectedAPTeacherID,
        'FILIPINO': selectedFilipinoTeacherID,
        'EPP': selectedEPPTeacherID,
        'MAPEH': selectedMAPEHTeacherID,
        'ESP': selectedESPTeacherID,
      });

      //  Set Science Teacher
      if (currentScienceTeacherID.isNotEmpty &&
          currentScienceTeacherID != selectedScienceTeacherID) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentScienceTeacherID)
            .update({
          'handledSections': FieldValue.arrayRemove([widget.sectionID])
        });
      }
      if (selectedScienceTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedScienceTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([widget.sectionID])
        });
      }

      //  Set Math Teacher
      if (currentMathTeacherID.isNotEmpty &&
          currentMathTeacherID != selectedMathTeacherID) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentMathTeacherID)
            .update({
          'handledSections': FieldValue.arrayRemove([widget.sectionID])
        });
      }
      if (selectedMathTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedMathTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([widget.sectionID])
        });
      }

      //  Set English Teacher
      if (currentEnglishTeacherID.isNotEmpty &&
          currentEnglishTeacherID != selectedEnglishTeacherID) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentEnglishTeacherID)
            .update({
          'handledSections': FieldValue.arrayRemove([widget.sectionID])
        });
      }
      if (selectedEnglishTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedEnglishTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([widget.sectionID])
        });
      }

      //  Set AP Teacher
      if (currentAPTeacherID.isNotEmpty &&
          currentAPTeacherID != selectedAPTeacherID) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentAPTeacherID)
            .update({
          'handledSections': FieldValue.arrayRemove([widget.sectionID])
        });
      }
      if (selectedAPTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedAPTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([widget.sectionID])
        });
      }

      //  Set Filipino Teacher
      if (currentFilipinoTeacherID.isNotEmpty &&
          currentFilipinoTeacherID != selectedAPTeacherID) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentFilipinoTeacherID)
            .update({
          'handledSections': FieldValue.arrayRemove([widget.sectionID])
        });
      }
      if (selectedFilipinoTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedFilipinoTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([widget.sectionID])
        });
      }

      //  Set EPP Teacher
      if (currentEPPTeacherID.isNotEmpty &&
          currentEPPTeacherID != selectedAPTeacherID) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentEPPTeacherID)
            .update({
          'handledSections': FieldValue.arrayRemove([widget.sectionID])
        });
      }
      if (selectedEPPTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedEPPTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([widget.sectionID])
        });
      }

      //  Set ESP Teacher
      if (currentESPTeacherID.isNotEmpty &&
          currentESPTeacherID != selectedAPTeacherID) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentESPTeacherID)
            .update({
          'handledSections': FieldValue.arrayRemove([widget.sectionID])
        });
      }
      if (selectedESPTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedESPTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([widget.sectionID])
        });
      }

      //  Set MAPEH Teacher
      if (currentMAPEHTeacherID.isNotEmpty &&
          currentMAPEHTeacherID != selectedAPTeacherID) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentMAPEHTeacherID)
            .update({
          'handledSections': FieldValue.arrayRemove([widget.sectionID])
        });
      }
      if (selectedMAPEHTeacherID.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedMAPEHTeacherID)
            .update({
          'handledSections': FieldValue.arrayUnion([widget.sectionID])
        });
      }
      final sectionDoc = await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .get();
      navigator.pop();
      NavigatorRoutes.adminSelectedSection(context,
          sectionDoc: sectionDoc, isReplacing: true);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error editing this section: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  //  BUILD WIDGETS
  //============================================================================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: homeAppBarWidget(context,
            backgroundColor: CustomColors.verySoftCyan, mayGoBack: true),
        body: switchedLoadingContainer(
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  _sectionName(),
                  Gap(20),
                  _sectionTeachersContainer(),
                  ovalButton('SAVE CHANGES',
                      onPress: editThisSection,
                      backgroundColor: CustomColors.moderateCyan)
                ],
              )),
            )),
      ),
    );
  }

  //  TEACHER WIDGETS
  //============================================================================
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

  Widget _sectionTeachersContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_teacher1stColumn(), _teacher2ndColumn()],
    );
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
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(5),
            child: userDocumentSnapshotDropdownWidget(
                context,
                selectedScienceTeacherID.isNotEmpty
                    ? selectedScienceTeacherID
                    : scienceTeachers.first.id, (newVal) {
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
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(5),
            child: userDocumentSnapshotDropdownWidget(
                context,
                selectedMathTeacherID.isNotEmpty
                    ? selectedMathTeacherID
                    : mathTeachers.first.id, (newVal) {
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
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(5),
            child: userDocumentSnapshotDropdownWidget(
                context,
                selectedEnglishTeacherID.isNotEmpty
                    ? selectedEnglishTeacherID
                    : englishTeachers.first.id, (newVal) {
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
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(5),
            child: userDocumentSnapshotDropdownWidget(
                context,
                selectedAPTeacherID.isNotEmpty
                    ? selectedAPTeacherID
                    : apTeachers.first.id, (newVal) {
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
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(5),
            child: userDocumentSnapshotDropdownWidget(
                context,
                selectedFilipinoTeacherID.isNotEmpty
                    ? selectedFilipinoTeacherID
                    : filipinoTeachers.first.id, (newVal) {
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
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(5),
            child: userDocumentSnapshotDropdownWidget(
                context,
                selectedEPPTeacherID.isNotEmpty
                    ? selectedEPPTeacherID
                    : eppTeachers.first.id, (newVal) {
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
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(5),
            child: userDocumentSnapshotDropdownWidget(
                context,
                selectedESPTeacherID.isNotEmpty
                    ? selectedESPTeacherID
                    : espTeachers.first.id, (newVal) {
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
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(5),
            child: userDocumentSnapshotDropdownWidget(
                context,
                selectedMAPEHTeacherID.isNotEmpty
                    ? selectedMAPEHTeacherID
                    : mapehTeachers.first.id, (newVal) {
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
