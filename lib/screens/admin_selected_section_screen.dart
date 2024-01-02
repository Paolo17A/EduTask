import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class AdminSelectedSectionScreen extends StatefulWidget {
  final DocumentSnapshot sectionDoc;
  const AdminSelectedSectionScreen({super.key, required this.sectionDoc});

  @override
  State<AdminSelectedSectionScreen> createState() =>
      _AdminSelectedSectionScreenState();
}

class _AdminSelectedSectionScreenState
    extends State<AdminSelectedSectionScreen> {
  bool _isLoading = true;

  String sectionName = '';
  List<DocumentSnapshot> associatedTeacherDocs = [];
  String scienceTeacherID = '';
  String mathTeacherID = '';
  String englishTeacherID = '';
  String apTeacherID = '';
  String filipinoTeacherID = '';
  String eppTeacherID = '';
  String mapehTeacherID = '';
  String espTeacherID = '';
  List<DocumentSnapshot> associatedStudentDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sectionData = widget.sectionDoc.data() as Map<dynamic, dynamic>;
    sectionName = sectionData['name'];
    List<dynamic> associatedTeacherIDs = [];
    scienceTeacherID = sectionData['SCIENCE'];
    if (scienceTeacherID.isNotEmpty) {
      associatedTeacherIDs.add(sectionData['SCIENCE']);
    }
    mathTeacherID = sectionData['MATHEMATICS'];
    if (mathTeacherID.isNotEmpty) {
      associatedTeacherIDs.add(sectionData['MATHEMATICS']);
    }
    englishTeacherID = sectionData['ENGLISH'];
    if (englishTeacherID.isNotEmpty) {
      associatedTeacherIDs.add(sectionData['ENGLISH']);
    }
    apTeacherID = sectionData['AP'];
    if (apTeacherID.isNotEmpty) {
      associatedTeacherIDs.add(sectionData['AP']);
    }
    filipinoTeacherID = sectionData['FILIPINO'];
    if (filipinoTeacherID.isNotEmpty) {
      associatedTeacherIDs.add(sectionData['FILIPINO']);
    }
    eppTeacherID = sectionData['EPP'];
    if (eppTeacherID.isNotEmpty) {
      associatedTeacherIDs.add(sectionData['EPP']);
    }
    espTeacherID = sectionData['ESP'];
    if (espTeacherID.isNotEmpty) {
      associatedTeacherIDs.add(sectionData['ESP']);
    }
    mapehTeacherID = sectionData['MAPEH'];
    if (mapehTeacherID.isNotEmpty) {
      associatedTeacherIDs.add(sectionData['MAPEH']);
    }
    List<dynamic> students = sectionData['students'];

    getSectionUsers(associatedTeacherIDs, students);
  }

  void getSectionUsers(
      List<dynamic> teacherIDs, List<dynamic> studentIDs) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      //  GET ASSOCIATED TEACHERS
      if (teacherIDs.isNotEmpty) {
        final teachers = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: teacherIDs)
            .get();
        associatedTeacherDocs = teachers.docs;
      }

      //  GET ASSOCIATED STUDENTS
      if (studentIDs.isNotEmpty) {
        final studentsQuery = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: studentIDs)
            .get();
        associatedStudentDocs = studentsQuery.docs;
      }

      setState(() {
        _isLoading = false;
      });
      print('DONE GETTING SECTION USERS');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting section data: $error')));
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
      onWillPop: () async {
        Navigator.of(context).pop();
        Navigator.of(context)
            .pushReplacementNamed(NavigatorRoutes.adminSectionRecords);
        return false;
      },
      child: Scaffold(
          appBar: homeAppBarWidget(context, mayGoBack: true),
          body: switchedLoadingContainer(
              _isLoading,
              SingleChildScrollView(
                child: all20Pix(
                  child: Column(
                    children: [
                      selectedSectionHeader(),
                      if (!_isLoading) _sectionTeachersContainer(),
                      if (!_isLoading) _expandableStudents(),
                      ovalButton('EDIT SECTION',
                          onPress: () => NavigatorRoutes.adminEditSection(
                              context,
                              sectionID: widget.sectionDoc.id))
                    ],
                  ),
                ),
              ))),
    );
  }

  //  TEACHER WIDGETS
  //============================================================================
  Widget selectedSectionHeader() {
    return interText(sectionName,
        fontSize: 40, textAlign: TextAlign.center, color: Colors.black);
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
          _scienceTeacher(),
          _mathTeacher(),
          _englishTeacher(),
          _apTeacher()
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
          _filipinoTeacher(),
          _eppTeacher(),
          _espTeacher(),
          _mapehTeacher()
        ],
      ),
    );
  }

  Widget _scienceTeacher() {
    String formattedName = '';
    if (scienceTeacherID.isNotEmpty) {
      DocumentSnapshot teacherDoc = associatedTeacherDocs.where((teacher) {
        return teacher.id == scienceTeacherID;
      }).first;
      final teacherData = teacherDoc.data() as Map<dynamic, dynamic>;
      formattedName = '${teacherData['firstName']} ${teacherData['lastName']}';
    }

    return sectionTeacherContainer(context,
        subjectLabel: 'SCIENCE TEACHER', formattedName: formattedName);
  }

  Widget _mathTeacher() {
    String formattedName = '';
    if (mathTeacherID.isNotEmpty) {
      DocumentSnapshot teacherDoc = associatedTeacherDocs.where((teacher) {
        return teacher.id == mathTeacherID;
      }).first;
      final teacherData = teacherDoc.data() as Map<dynamic, dynamic>;
      formattedName = '${teacherData['firstName']} ${teacherData['lastName']}';
    }

    return sectionTeacherContainer(context,
        subjectLabel: 'MATH TEACHER', formattedName: formattedName);
  }

  Widget _englishTeacher() {
    String formattedName = '';
    if (englishTeacherID.isNotEmpty) {
      print('ENGLISH TEACHER ID: $englishTeacherID');
      DocumentSnapshot teacherDoc = associatedTeacherDocs.where((teacher) {
        print('current teacher: ${teacher.id}');
        return teacher.id == englishTeacherID;
      }).first;
      final teacherData = teacherDoc.data() as Map<dynamic, dynamic>;
      formattedName = '${teacherData['firstName']} ${teacherData['lastName']}';
    }

    return sectionTeacherContainer(context,
        subjectLabel: 'ENGLISH TEACHER', formattedName: formattedName);
  }

  Widget _apTeacher() {
    String formattedName = '';
    if (apTeacherID.isNotEmpty) {
      DocumentSnapshot teacherDoc = associatedTeacherDocs.where((teacher) {
        return teacher.id == apTeacherID;
      }).first;
      final teacherData = teacherDoc.data() as Map<dynamic, dynamic>;
      formattedName = '${teacherData['firstName']} ${teacherData['lastName']}';
    }

    return sectionTeacherContainer(context,
        subjectLabel: 'AP TEACHER', formattedName: formattedName);
  }

  Widget _filipinoTeacher() {
    String formattedName = '';
    if (filipinoTeacherID.isNotEmpty) {
      DocumentSnapshot teacherDoc = associatedTeacherDocs.where((teacher) {
        return teacher.id == filipinoTeacherID;
      }).first;
      final teacherData = teacherDoc.data() as Map<dynamic, dynamic>;
      formattedName = '${teacherData['firstName']} ${teacherData['lastName']}';
    }

    return sectionTeacherContainer(context,
        subjectLabel: 'FILIPINO TEACHER', formattedName: formattedName);
  }

  Widget _eppTeacher() {
    String formattedName = '';
    if (eppTeacherID.isNotEmpty) {
      DocumentSnapshot teacherDoc = associatedTeacherDocs.where((teacher) {
        return teacher.id == eppTeacherID;
      }).first;
      final teacherData = teacherDoc.data() as Map<dynamic, dynamic>;
      formattedName = '${teacherData['firstName']} ${teacherData['lastName']}';
    }

    return sectionTeacherContainer(context,
        subjectLabel: 'EPP TEACHER', formattedName: formattedName);
  }

  Widget _espTeacher() {
    String formattedName = '';
    if (espTeacherID.isNotEmpty) {
      DocumentSnapshot teacherDoc = associatedTeacherDocs.where((teacher) {
        return teacher.id == espTeacherID;
      }).first;
      final teacherData = teacherDoc.data() as Map<dynamic, dynamic>;
      formattedName = '${teacherData['firstName']} ${teacherData['lastName']}';
    }

    return sectionTeacherContainer(context,
        subjectLabel: 'ESP TEACHER', formattedName: formattedName);
  }

  Widget _mapehTeacher() {
    String formattedName = '';
    if (mapehTeacherID.isNotEmpty) {
      DocumentSnapshot teacherDoc = associatedTeacherDocs.where((teacher) {
        return teacher.id == mapehTeacherID;
      }).first;
      final teacherData = teacherDoc.data() as Map<dynamic, dynamic>;
      formattedName = '${teacherData['firstName']} ${teacherData['lastName']}';
    }

    return sectionTeacherContainer(context,
        subjectLabel: 'MAPEH TEACHER', formattedName: formattedName);
  }

  //  STUDENT WIDGETS
  //============================================================================
  Widget _expandableStudents() {
    return vertical20Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.grey.withOpacity(0.5),
        backgroundColor: Colors.grey.withOpacity(0.5),
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('ENROLLED STUDENTS'),
        children: [
          associatedStudentDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: associatedStudentDocs.length,
                      itemBuilder: (context, index) => studentEntry(context,
                          studentDoc: associatedStudentDocs[index])),
                )
              : interText('NO ENROLLED STUDENTS', fontSize: 20)
        ],
      ),
    );
  }
}
