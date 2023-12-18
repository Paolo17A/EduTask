import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class TeacherSelectedSectionScreen extends StatefulWidget {
  final String sectionID;
  const TeacherSelectedSectionScreen({super.key, required this.sectionID});

  @override
  State<TeacherSelectedSectionScreen> createState() =>
      _TeacherSelectedSectionScreenState();
}

class _TeacherSelectedSectionScreenState
    extends State<TeacherSelectedSectionScreen> {
  bool _isLoading = true;

  String sectionName = '';
  List<DocumentSnapshot> lessonDocs = [];
  List<DocumentSnapshot> quizDocs = [];
  List<DocumentSnapshot> assignmentDocs = [];
  List<DocumentSnapshot> associatedStudentDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getSectionData();
  }

  void getSectionData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final section = await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .get();
      final sectionData = section.data() as Map<dynamic, dynamic>;
      sectionName = sectionData['name'];
      List<dynamic> lessonIDs = sectionData['lessons'];
      List<dynamic> quizIDs = sectionData['quizzes'];
      List<dynamic> assignmentIDs = sectionData['assignments'];
      if (lessonIDs.isNotEmpty) {
        final lessons = await FirebaseFirestore.instance
            .collection('lessons')
            .where(FieldPath.documentId, whereIn: lessonIDs)
            .get();
        lessonDocs = lessons.docs;
        lessonDocs = lessonDocs.where((lesson) {
          final lessonData = lesson.data() as Map<dynamic, dynamic>;
          String teacherID = lessonData['teacherID'];
          return teacherID == FirebaseAuth.instance.currentUser!.uid;
        }).toList();
      }
      if (quizIDs.isNotEmpty) {
        final quizzes = await FirebaseFirestore.instance
            .collection('quizzes')
            .where(FieldPath.documentId, whereIn: quizIDs)
            .get();
        quizDocs = quizzes.docs;
        quizDocs = quizDocs.where((quiz) {
          final quizData = quiz.data() as Map<dynamic, dynamic>;
          String teacherID = quizData['teacherID'];
          return teacherID == FirebaseAuth.instance.currentUser!.uid;
        }).toList();
      }
      if (assignmentIDs.isNotEmpty) {
        final assignments = await FirebaseFirestore.instance
            .collection('assignments')
            .where(FieldPath.documentId, whereIn: assignmentIDs)
            .get();
        assignmentDocs = assignments.docs;
        assignmentDocs = assignmentDocs.where((assignment) {
          final assignmentData = assignment.data() as Map<dynamic, dynamic>;
          String teacherID = assignmentData['teacherID'];
          return teacherID == FirebaseAuth.instance.currentUser!.uid;
        }).toList();
      }
      List<dynamic> studentIDs = sectionData['students'];
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
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting section materials: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      body: switchedLoadingContainer(
          _isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
              children: [
                _sectionNameHeader(),
                Gap(30),
                if (!_isLoading) _expandables()
              ],
            )),
          )),
    );
  }

  Widget _sectionNameHeader() {
    return interText(sectionName,
        fontSize: 40, textAlign: TextAlign.center, color: Colors.black);
  }

  Widget _expandables() {
    return Column(
      children: [_expandableLessons(), _expandableStudents()],
    );
  }

  Widget _expandableLessons() {
    return ExpansionTile(
      collapsedBackgroundColor: Colors.grey.withOpacity(0.5),
      backgroundColor: Colors.grey.withOpacity(0.5),
      textColor: Colors.black,
      iconColor: Colors.black,
      collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), side: BorderSide()),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), side: BorderSide()),
      title: interText('LESSONS'),
      children: [
        ovalButton('ASSIGN LESSON', onPress: () {}),
        Gap(15),
        lessonDocs.isNotEmpty
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: ListView.builder(
                    shrinkWrap: false,
                    itemCount: lessonDocs.length,
                    itemBuilder: (context, index) => sectionMaterialEntry(
                        context,
                        materialDoc: lessonDocs[index],
                        onEdit: () {},
                        onDelete: () {})),
              )
            : interText('NO ASSIGNED LESSONS', fontSize: 20)
      ],
    );
  }

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
