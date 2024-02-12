// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/future_util.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:flutter/material.dart';

import '../util/color_util.dart';
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
  String adviserName = '';
  List<DocumentSnapshot> associatedTeacherDocs = [];
  List<DocumentSnapshot> associatedStudentDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sectionData = widget.sectionDoc.data() as Map<dynamic, dynamic>;
    sectionName = sectionData['name'];
    List<dynamic> associatedTeacherIDs = sectionData['teachers'];
    List<dynamic> students = sectionData['students'];
    String adviser = sectionData['adviser'];

    getSectionUsers(associatedTeacherIDs, students, adviser);
  }

  void getSectionUsers(List<dynamic> teacherIDs, List<dynamic> studentIDs,
      String adviserID) async {
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

      if (adviserID.isNotEmpty) {
        adviserName = await getUserName(adviserID);
      }

      setState(() {
        _isLoading = false;
      });
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
          appBar: homeAppBarWidget(context,
              backgroundColor: CustomColors.veryDarkGrey, mayGoBack: true),
          body: switchedLoadingContainer(
              _isLoading,
              SingleChildScrollView(
                child: all20Pix(
                  child: Column(
                    children: [
                      selectedSectionHeader(),
                      _sectionAdviser(),
                      _expandableTeachers(),
                      _expandableStudents(),
                      ovalButton('EDIT SECTION',
                          onPress: () => NavigatorRoutes.adminEditSection(
                              context,
                              sectionID: widget.sectionDoc.id),
                          backgroundColor: CustomColors.softOrange)
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

  //  STUDENT WIDGETS
  //============================================================================

  Widget _sectionAdviser() {
    return vertical20Pix(
        child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            interText('Section Adviser:', fontSize: 24),
            interText(adviserName.isNotEmpty ? adviserName : 'N/A',
                fontSize: 20)
          ],
        ),
      ],
    ));
  }

  Widget _expandableTeachers() {
    return vertical20Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange.withOpacity(0.5),
        backgroundColor: CustomColors.softOrange.withOpacity(0.5),
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('ASSIGNED TEACHERS'),
        children: [
          associatedTeacherDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: associatedTeacherDocs.length,
                      itemBuilder: (context, index) => studentEntry(context,
                          studentDoc: associatedTeacherDocs[index],
                          onPress: () {},
                          backgroundColor: CustomColors.softOrange)),
                )
              : interText('NO ASSIGNED TEACHERS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _expandableStudents() {
    return vertical20Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange.withOpacity(0.5),
        backgroundColor: CustomColors.softOrange.withOpacity(0.5),
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
                          studentDoc: associatedStudentDocs[index],
                          onPress: () {},
                          backgroundColor: CustomColors.softOrange)),
                )
              : interText('NO ENROLLED STUDENTS', fontSize: 20)
        ],
      ),
    );
  }
}
