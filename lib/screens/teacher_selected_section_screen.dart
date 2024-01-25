import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
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

  //  All documents created by this teacer.
  List<DocumentSnapshot> allLessonDocs = [];
  List<DocumentSnapshot> allQuizDocs = [];
  List<DocumentSnapshot> allAssignmentDocs = [];

  //  All documents assigned to this section.
  List<DocumentSnapshot> assignedLessonDocs = [];
  List<dynamic> assignedLessonIDs = [];
  List<DocumentSnapshot> assignedQuizDocs = [];
  List<dynamic> assignedQuizIDs = [];
  List<DocumentSnapshot> assignedAssignmentDocs = [];
  List<dynamic> assignedAssignmentIDs = [];
  List<DocumentSnapshot> associatedStudentDocs = [];

  //  Assigned Lessons

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
      assignedLessonIDs = sectionData['lessons'];
      assignedQuizIDs = sectionData['quizzes'];
      assignedAssignmentIDs = sectionData['assignments'];

      // Initialize Lesons
      final lessons = await FirebaseFirestore.instance
          .collection('lessons')
          .where('teacherID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      allLessonDocs = lessons.docs;
      assignedLessonDocs = allLessonDocs.where((lesson) {
        final lessonData = lesson.data() as Map<dynamic, dynamic>;
        List<dynamic> associatedSections = lessonData['associatedSections'];
        return associatedSections.contains(widget.sectionID);
      }).toList();

      //  Initialize Assignments
      final assignments = await FirebaseFirestore.instance
          .collection('assignments')
          .where('teacherID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      allAssignmentDocs = assignments.docs;
      assignedAssignmentDocs = allAssignmentDocs.where((assignment) {
        final assignmentData = assignment.data() as Map<dynamic, dynamic>;
        List<dynamic> associatedSections = assignmentData['associatedSections'];
        return associatedSections.contains(widget.sectionID);
      }).toList();

      //  Initialize Quizzes
      final quizzes = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('teacherID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      allQuizDocs = quizzes.docs;
      assignedQuizDocs = allQuizDocs.where((quiz) {
        final quizData = quiz.data() as Map<dynamic, dynamic>;
        List<dynamic> associatedSections = quizData['associatedSections'];
        return associatedSections.contains(widget.sectionID);
      }).toList();

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

  void assignThisLesson(DocumentSnapshot lessonDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      //  1.  assign lesson to section doc
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .update({
        'lessons': FieldValue.arrayUnion([lessonDoc.id])
      });
      //  2. Assign section to lesson doc
      await FirebaseFirestore.instance
          .collection('lessons')
          .doc(lessonDoc.id)
          .update({
        'associatedSections': FieldValue.arrayUnion([widget.sectionID])
      });
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully assigned this lesson to this section.')));
      getSectionData();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error assigning this section: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void removeThisLesson(DocumentSnapshot lessonDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      //  1. Remove lesson to section doc
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .update({
        'lessons': FieldValue.arrayRemove([lessonDoc.id])
      });
      //  2. Remove section to lesson doc
      await FirebaseFirestore.instance
          .collection('lessons')
          .doc(lessonDoc.id)
          .update({
        'associatedSections': FieldValue.arrayRemove([widget.sectionID])
      });
      scaffoldMessenger.showSnackBar(const SnackBar(
          content:
              Text('Successfully assigned this lesson from this section.')));
      getSectionData();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error assigning this section: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void assignThisAssignment(DocumentSnapshot assignmentDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      //  1.  assign assignment to section doc
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .update({
        'assignments': FieldValue.arrayUnion([assignmentDoc.id])
      });
      //  2. Assign assignment to lesson doc
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(assignmentDoc.id)
          .update({
        'associatedSections': FieldValue.arrayUnion([widget.sectionID])
      });
      scaffoldMessenger.showSnackBar(const SnackBar(
          content:
              Text('Successfully assigned this assignment to this section.')));
      getSectionData();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error assigning this assignment: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void removeThisAssignment(DocumentSnapshot assignmentDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      //  1.  assign assignment to section doc
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .update({
        'assignments': FieldValue.arrayRemove([assignmentDoc.id])
      });
      //  2. Assign assignment to lesson doc
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(assignmentDoc.id)
          .update({
        'associatedSections': FieldValue.arrayRemove([widget.sectionID])
      });
      scaffoldMessenger.showSnackBar(const SnackBar(
          content:
              Text('Successfully removed this assignment from this section.')));
      getSectionData();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error removing this assignment: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void assignThisQuiz(DocumentSnapshot quizDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      //  1.  assign assignment to section doc
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .update({
        'quizzes': FieldValue.arrayUnion([quizDoc.id])
      });
      //  2. Assign assignment to lesson doc
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizDoc.id)
          .update({
        'associatedSections': FieldValue.arrayUnion([widget.sectionID])
      });
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully assigned this quiz to this section.')));
      getSectionData();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error assigning this quiz: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void removeThisQuiz(DocumentSnapshot assignmentDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      //  1.  assign assignment to section doc
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .update({
        'quizzes': FieldValue.arrayRemove([assignmentDoc.id])
      });
      //  2. Assign assignment to lesson doc
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(assignmentDoc.id)
          .update({
        'associatedSections': FieldValue.arrayRemove([widget.sectionID])
      });
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully removed this quiz from this section.')));
      getSectionData();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error removing this quiz: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      bottomNavigationBar: teacherBottomNavBar(context, index: 1),
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
      children: [
        _expandableLessons(),
        _expandableAssignments(),
        _expandableQuizzes(),
        _expandableStudents()
      ],
    );
  }

  Widget _expandableLessons() {
    List<DocumentSnapshot> availableLessons = allLessonDocs
        .where((lesson) => !assignedLessonIDs.contains(lesson.id))
        .toList();
    return vertical20Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('LESSONS'),
        children: [
          if (availableLessons.isNotEmpty)
            ovalButton('ASSIGN LESSON',
                onPress: () => showAvailableLessonsDialog(availableLessons),
                backgroundColor: CustomColors.softOrange),
          Gap(15),
          assignedLessonDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: assignedLessonDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: assignedLessonDocs[index],
                          onRemove: () =>
                              removeThisLesson(assignedLessonDocs[index]))),
                )
              : interText('NO ASSIGNED LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  void showAvailableLessonsDialog(List<DocumentSnapshot> availableLessons) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    interText('AVAILABLE LESSONS'),
                    Column(
                        children: availableLessons.map((lesson) {
                      final lessonData = lesson.data() as Map<dynamic, dynamic>;
                      String title = lessonData['title'];
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              assignThisLesson(lesson);
                            },
                            child:
                                interText(title, fontWeight: FontWeight.bold)),
                      );
                    }).toList()),
                  ],
                ),
              ),
            ));
  }

  Widget _expandableAssignments() {
    List<DocumentSnapshot> availableAssignments = allAssignmentDocs
        .where((assignment) => !assignedAssignmentIDs.contains(assignment.id))
        .toList();
    return vertical20Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('ASSIGNMENTS'),
        children: [
          if (availableAssignments.isNotEmpty)
            ovalButton('ASSIGN ASSIGNMENT',
                onPress: () =>
                    showAvailableAssignmentsDialog(availableAssignments),
                backgroundColor: CustomColors.softOrange),
          Gap(15),
          assignedAssignmentDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: assignedAssignmentDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: assignedAssignmentDocs[index],
                          onRemove: () => removeThisAssignment(
                              assignedAssignmentDocs[index]))),
                )
              : interText('NO ASSIGNED LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  void showAvailableAssignmentsDialog(
      List<DocumentSnapshot> availableAssignments) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    interText('AVAILABLE ASSIGNMENTS'),
                    Column(
                        children: availableAssignments.map((assignment) {
                      final assignmentData =
                          assignment.data() as Map<dynamic, dynamic>;
                      String title = assignmentData['title'];
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              assignThisAssignment(assignment);
                            },
                            child:
                                interText(title, fontWeight: FontWeight.bold)),
                      );
                    }).toList()),
                  ],
                ),
              ),
            ));
  }

  Widget _expandableQuizzes() {
    List<DocumentSnapshot> availableQuizzes = allQuizDocs
        .where((quiz) => !assignedQuizIDs.contains(quiz.id))
        .toList();
    return vertical20Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUIZZES'),
        children: [
          if (availableQuizzes.isNotEmpty)
            ovalButton('ASSIGN QUIZ',
                onPress: () => showAvailableQuizzesDialog(availableQuizzes),
                backgroundColor: CustomColors.softOrange),
          Gap(15),
          assignedQuizDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: assignedQuizDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: assignedQuizDocs[index],
                          onRemove: () =>
                              removeThisQuiz(assignedQuizDocs[index]))),
                )
              : interText('NO ASSIGNED LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  void showAvailableQuizzesDialog(List<DocumentSnapshot> availableQuizzes) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    interText('AVAILABLE QUIZZES'),
                    Column(
                        children: availableQuizzes.map((quiz) {
                      final quizData = quiz.data() as Map<dynamic, dynamic>;
                      String title = quizData['title'];
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              assignThisQuiz(quiz);
                            },
                            child:
                                interText(title, fontWeight: FontWeight.bold)),
                      );
                    }).toList()),
                  ],
                ),
              ),
            ));
  }

  Widget _expandableStudents() {
    return vertical20Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
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
                          onPress: () =>
                              NavigatorRoutes.teacherSelectedStudentGrades(
                                  context,
                                  studentDoc: associatedStudentDocs[index]))),
                )
              : interText('NO ENROLLED STUDENTS', fontSize: 20)
        ],
      ),
    );
  }
}
