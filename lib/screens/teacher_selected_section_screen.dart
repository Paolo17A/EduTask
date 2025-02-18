import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:emailjs/emailjs.dart';
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
  //  LESSONS
  List<DocumentSnapshot> assignedLessonDocs = [];
  List<dynamic> assignedLessonIDs = [];
  List<DocumentSnapshot> quarter1LessonDocs = [];
  List<DocumentSnapshot> quarter2LessonDocs = [];
  List<DocumentSnapshot> quarter3LessonDocs = [];
  List<DocumentSnapshot> quarter4LessonDocs = [];

  //  QUIZZES
  List<DocumentSnapshot> assignedQuizDocs = [];
  List<dynamic> assignedQuizIDs = [];
  List<DocumentSnapshot> quarter1QuizDocs = [];
  List<DocumentSnapshot> quarter2QuizDocs = [];
  List<DocumentSnapshot> quarter3QuizDocs = [];
  List<DocumentSnapshot> quarter4QuizDocs = [];

  //  ASSIGNMENTS
  List<DocumentSnapshot> assignedAssignmentDocs = [];
  List<dynamic> assignedAssignmentIDs = [];
  List<DocumentSnapshot> quarter1AssignmentDocs = [];
  List<DocumentSnapshot> quarter2AssignmentDocs = [];
  List<DocumentSnapshot> quarter3AssignmentDocs = [];
  List<DocumentSnapshot> quarter4AssignmentDocs = [];

  //  STUDENTS
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
      assignedLessonDocs.sort((a, b) {
        final lessonA = a.data() as Map<dynamic, dynamic>;
        final lessonB = b.data() as Map<dynamic, dynamic>;
        DateTime lessonADateLastModified =
            (lessonA['dateLastModified'] as Timestamp).toDate();
        DateTime lessonBDateLastModified =
            (lessonB['dateLastModified'] as Timestamp).toDate();
        return lessonBDateLastModified.compareTo(lessonADateLastModified);
      });
      quarter1LessonDocs = assignedLessonDocs.where((lesson) {
        final lessonData = lesson.data() as Map<dynamic, dynamic>;
        return lessonData['quarter'] == 1 &&
            assignedLessonIDs.contains(lesson.id);
      }).toList();
      quarter2LessonDocs = assignedLessonDocs.where((lesson) {
        final lessonData = lesson.data() as Map<dynamic, dynamic>;
        return lessonData['quarter'] == 2 &&
            assignedLessonIDs.contains(lesson.id);
      }).toList();
      quarter3LessonDocs = assignedLessonDocs.where((lesson) {
        final lessonData = lesson.data() as Map<dynamic, dynamic>;
        return lessonData['quarter'] == 3 &&
            assignedLessonIDs.contains(lesson.id);
      }).toList();
      quarter4LessonDocs = assignedLessonDocs.where((lesson) {
        final lessonData = lesson.data() as Map<dynamic, dynamic>;
        return lessonData['quarter'] == 4 &&
            assignedLessonIDs.contains(lesson.id);
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
      assignedAssignmentDocs.sort((a, b) {
        final assignmentA = a.data() as Map<dynamic, dynamic>;
        final assignmentB = b.data() as Map<dynamic, dynamic>;
        DateTime assignmentADateLastModified =
            (assignmentA['dateLastModified'] as Timestamp).toDate();
        DateTime assignmentBDateLastModified =
            (assignmentB['dateLastModified'] as Timestamp).toDate();
        return assignmentBDateLastModified
            .compareTo(assignmentADateLastModified);
      });
      quarter1AssignmentDocs = assignedAssignmentDocs.where((assignment) {
        final assignmentData = assignment.data() as Map<dynamic, dynamic>;
        return assignmentData['quarter'] == 1 &&
            assignedAssignmentIDs.contains(assignment.id);
      }).toList();
      quarter2AssignmentDocs = assignedAssignmentDocs.where((assignment) {
        final assignmentData = assignment.data() as Map<dynamic, dynamic>;
        return assignmentData['quarter'] == 2 &&
            assignedAssignmentIDs.contains(assignment.id);
      }).toList();
      quarter3AssignmentDocs = assignedAssignmentDocs.where((assignment) {
        final assignmentData = assignment.data() as Map<dynamic, dynamic>;
        return assignmentData['quarter'] == 3 &&
            assignedAssignmentIDs.contains(assignment.id);
      }).toList();
      quarter4AssignmentDocs = assignedAssignmentDocs.where((assignment) {
        final assignmentData = assignment.data() as Map<dynamic, dynamic>;
        return assignmentData['quarter'] == 4 &&
            assignedAssignmentIDs.contains(assignment.id);
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
      assignedQuizDocs.sort((a, b) {
        final quizA = a.data() as Map<dynamic, dynamic>;
        final quizB = b.data() as Map<dynamic, dynamic>;
        DateTime quizADateLastModified =
            (quizA['dateLastModified'] as Timestamp).toDate();
        DateTime quizBDateLastModified =
            (quizB['dateLastModified'] as Timestamp).toDate();
        return quizBDateLastModified.compareTo(quizADateLastModified);
      });
      quarter1QuizDocs = assignedQuizDocs.where((quiz) {
        final quizData = quiz.data() as Map<dynamic, dynamic>;
        return quizData['quarter'] == 1 && assignedQuizIDs.contains(quiz.id);
      }).toList();
      quarter2QuizDocs = assignedQuizDocs.where((quiz) {
        final quizData = quiz.data() as Map<dynamic, dynamic>;
        return quizData['quarter'] == 2 && assignedQuizIDs.contains(quiz.id);
      }).toList();
      quarter3QuizDocs = assignedQuizDocs.where((quiz) {
        final quizData = quiz.data() as Map<dynamic, dynamic>;
        return quizData['quarter'] == 3 && assignedQuizIDs.contains(quiz.id);
      }).toList();
      quarter4QuizDocs = assignedQuizDocs.where((quiz) {
        final quizData = quiz.data() as Map<dynamic, dynamic>;
        return quizData['quarter'] == 4 && assignedQuizIDs.contains(quiz.id);
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

      final lessonData = lessonDoc.data() as Map<dynamic, dynamic>;
      String title = lessonData['title'];
      String subject = lessonData['subject'];
      for (var student in associatedStudentDocs) {
        final studentData = student.data() as Map<dynamic, dynamic>;
        String email = studentData['email'];
        String firstName = studentData['firstName'];
        String lastName = studentData['lastName'];
        await EmailJS.send(
            'service_8qicz6r',
            'template_6zzxsku',
            {
              'to_email': email,
              'to_name': '$firstName $lastName',
              'message_content':
                  'A new $subject lesson has been assigned your section: $title.'
            },
            Options(
                publicKey: 'u6vTOeKnZ6uLR3BVX',
                privateKey: 'e-HosRtW2lC5-XlLVt1WV'));
      }
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
      final lessonData = lessonDoc.data() as Map<dynamic, dynamic>;
      String title = lessonData['title'];
      String subject = lessonData['subject'];
      for (var student in associatedStudentDocs) {
        final studentData = student.data() as Map<dynamic, dynamic>;
        String email = studentData['email'];
        String firstName = studentData['firstName'];
        String lastName = studentData['lastName'];
        await EmailJS.send(
            'service_8qicz6r',
            'template_6zzxsku',
            {
              'to_email': email,
              'to_name': '$firstName $lastName',
              'message_content':
                  'The $subject lesson $title has been unassigned from your section.'
            },
            Options(
                publicKey: 'u6vTOeKnZ6uLR3BVX',
                privateKey: 'e-HosRtW2lC5-XlLVt1WV'));
      }
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
      final assignmentData = assignmentDoc.data() as Map<dynamic, dynamic>;
      String title = assignmentData['title'];
      String subject = assignmentData['subject'];

      for (var student in associatedStudentDocs) {
        final studentData = student.data() as Map<dynamic, dynamic>;
        String email = studentData['email'];
        String firstName = studentData['firstName'];
        String lastName = studentData['lastName'];
        await EmailJS.send(
            'service_8qicz6r',
            'template_6zzxsku',
            {
              'to_email': email,
              'to_name': '$firstName $lastName',
              'message_content':
                  'The $subject assignment $title has been unassigned from your section.'
            },
            Options(
                publicKey: 'u6vTOeKnZ6uLR3BVX',
                privateKey: 'e-HosRtW2lC5-XlLVt1WV'));
      }
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
      final assignmentData = assignmentDoc.data() as Map<dynamic, dynamic>;
      String title = assignmentData['title'];
      String subject = assignmentData['subject'];

      for (var student in associatedStudentDocs) {
        final studentData = student.data() as Map<dynamic, dynamic>;
        String email = studentData['email'];
        String firstName = studentData['firstName'];
        String lastName = studentData['lastName'];
        await EmailJS.send(
            'service_8qicz6r',
            'template_6zzxsku',
            {
              'to_email': email,
              'to_name': '$firstName $lastName',
              'message_content':
                  'The $subject assignment $title has been unassigned from your section.'
            },
            Options(
                publicKey: 'u6vTOeKnZ6uLR3BVX',
                privateKey: 'e-HosRtW2lC5-XlLVt1WV'));
      }
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
      final quizData = quizDoc.data() as Map<dynamic, dynamic>;
      String title = quizData['title'];
      String subject = quizData['subject'];

      for (var student in associatedStudentDocs) {
        final studentData = student.data() as Map<dynamic, dynamic>;
        String email = studentData['email'];
        String firstName = studentData['firstName'];
        String lastName = studentData['lastName'];
        await EmailJS.send(
            'service_8qicz6r',
            'template_6zzxsku',
            {
              'to_email': email,
              'to_name': '$firstName $lastName',
              'message_content':
                  'A new $subject quiz has been assigned to your section: $title'
            },
            Options(
                publicKey: 'u6vTOeKnZ6uLR3BVX',
                privateKey: 'e-HosRtW2lC5-XlLVt1WV'));
      }
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

  void removeThisQuiz(DocumentSnapshot quizDoc) async {
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
        'quizzes': FieldValue.arrayRemove([quizDoc.id])
      });
      //  2. Assign assignment to lesson doc
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizDoc.id)
          .update({
        'associatedSections': FieldValue.arrayRemove([widget.sectionID])
      });
      final quizData = quizDoc.data() as Map<dynamic, dynamic>;
      String title = quizData['title'];
      String subject = quizData['subject'];

      for (var student in associatedStudentDocs) {
        final studentData = student.data() as Map<dynamic, dynamic>;
        String email = studentData['email'];
        String firstName = studentData['firstName'];
        String lastName = studentData['lastName'];
        await EmailJS.send(
            'service_8qicz6r',
            'template_6zzxsku',
            {
              'to_email': email,
              'to_name': '$firstName $lastName',
              'message_content':
                  'The $subject quiz $title has been unassigned from your section.'
            },
            Options(
                publicKey: 'u6vTOeKnZ6uLR3BVX',
                privateKey: 'e-HosRtW2lC5-XlLVt1WV'));
      }
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
              ? Column(
                  children: [
                    _quarter1Lessons(),
                    _quarter2Lessons(),
                    _quarter3Lessons(),
                    _quarter4Lessons()
                  ],
                )
              : interText('NO ASSIGNED LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter1Lessons() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUARTER 1'),
        children: [
          quarter1LessonDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarter1LessonDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: quarter1LessonDocs[index],
                          onRemove: () =>
                              removeThisLesson(quarter1LessonDocs[index]))),
                )
              : interText('NO ASSIGNED LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter2Lessons() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUARTER 2'),
        children: [
          quarter2LessonDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarter2LessonDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: quarter2LessonDocs[index],
                          onRemove: () =>
                              removeThisLesson(quarter2LessonDocs[index]))),
                )
              : interText('NO ASSIGNED LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter3Lessons() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUARTER 3'),
        children: [
          quarter3LessonDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarter3LessonDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: quarter3LessonDocs[index],
                          onRemove: () =>
                              removeThisLesson(quarter3LessonDocs[index]))),
                )
              : interText('NO ASSIGNED LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter4Lessons() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUARTER 4'),
        children: [
          quarter4LessonDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarter4LessonDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: quarter4LessonDocs[index],
                          onRemove: () =>
                              removeThisLesson(quarter4LessonDocs[index]))),
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
                        child: ovalButton(title, onPress: () {
                          Navigator.of(context).pop();
                          assignThisLesson(lesson);
                        }, backgroundColor: CustomColors.softOrange),
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
              ? Column(
                  children: [
                    _quarter1Assignments(),
                    _quarter2Assignments(),
                    _quarter3Assignments(),
                    _quarter4Assignments()
                  ],
                )
              : interText('NO ASSIGNED ASSIGNMENTS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter1Assignments() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUARTER 1'),
        children: [
          quarter1AssignmentDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarter1AssignmentDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: quarter1AssignmentDocs[index],
                          onRemove: () => removeThisAssignment(
                              quarter1AssignmentDocs[index]))),
                )
              : interText('NO ASSIGNED ASSIGNMENTS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter2Assignments() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUARTER 2'),
        children: [
          quarter2AssignmentDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarter2AssignmentDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: quarter2AssignmentDocs[index],
                          onRemove: () => removeThisAssignment(
                              quarter2AssignmentDocs[index]))),
                )
              : interText('NO ASSIGNED ASSIGNMENTS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter3Assignments() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUARTER 3'),
        children: [
          quarter3AssignmentDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarter3AssignmentDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: quarter3AssignmentDocs[index],
                          onRemove: () => removeThisAssignment(
                              quarter3AssignmentDocs[index]))),
                )
              : interText('NO ASSIGNED ASSIGNMENTS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter4Assignments() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUARTER 4'),
        children: [
          quarter4AssignmentDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarter4AssignmentDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: quarter4AssignmentDocs[index],
                          onRemove: () => removeThisAssignment(
                              quarter4AssignmentDocs[index]))),
                )
              : interText('NO ASSIGNED ASSIGNMENTS', fontSize: 20)
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
                        child: ovalButton(title, onPress: () {
                          Navigator.of(context).pop();
                          assignThisAssignment(assignment);
                        }, backgroundColor: CustomColors.softOrange),
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
              ? Column(
                  children: [
                    _quarter1Quizzes(),
                    _quarter2Quizzes(),
                    _quarter3Quizzes(),
                    _quarter4Quizzes()
                  ],
                )
              : interText('NO ASSIGNED QUIZZES', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter1Quizzes() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUARTER 1'),
        children: [
          quarter1QuizDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarter1QuizDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: quarter1QuizDocs[index],
                          onRemove: () =>
                              removeThisQuiz(quarter1QuizDocs[index]))),
                )
              : interText('NO ASSIGNED QUIZZES', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter2Quizzes() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUARTER 2'),
        children: [
          quarter2QuizDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarter2QuizDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: quarter2QuizDocs[index],
                          onRemove: () =>
                              removeThisQuiz(quarter2QuizDocs[index]))),
                )
              : interText('NO ASSIGNED QUIZZES', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter3Quizzes() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUARTER 3'),
        children: [
          quarter3QuizDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarter3QuizDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: quarter3QuizDocs[index],
                          onRemove: () =>
                              removeThisQuiz(quarter3QuizDocs[index]))),
                )
              : interText('NO ASSIGNED QUIZZES', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter4Quizzes() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.verySoftOrange,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide()),
        title: interText('QUARTER 4'),
        children: [
          quarter4QuizDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarter4QuizDocs.length,
                      itemBuilder: (context, index) => sectionMaterialEntry(
                          context,
                          materialDoc: quarter4QuizDocs[index],
                          onRemove: () =>
                              removeThisQuiz(quarter4QuizDocs[index]))),
                )
              : interText('NO ASSIGNED QUIZZES', fontSize: 20)
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
                        child: ovalButton(title, onPress: () {
                          Navigator.of(context).pop();
                          assignThisQuiz(quiz);
                        }, backgroundColor: CustomColors.softOrange),
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
                          onPress: () => showSelectSubjectDialog(
                              studentDoc: associatedStudentDocs[index]))),
                )
              : interText('NO ENROLLED STUDENTS', fontSize: 20)
        ],
      ),
    );
  }

  void showSelectSubjectDialog({required DocumentSnapshot studentDoc}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: SingleChildScrollView(
              child: Column(
                children: [
                  interText('SELECT A SUBJECT: ',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                  const Gap(12),
                  subjectButton(studentDoc: studentDoc, subject: 'AP'),
                  subjectButton(studentDoc: studentDoc, subject: 'ENGLISH'),
                  subjectButton(studentDoc: studentDoc, subject: 'EPP'),
                  subjectButton(studentDoc: studentDoc, subject: 'TLE'),
                  subjectButton(studentDoc: studentDoc, subject: 'FILIPINO'),
                  subjectButton(studentDoc: studentDoc, subject: 'MAPEH'),
                  subjectButton(studentDoc: studentDoc, subject: 'MATHEMATICS'),
                  subjectButton(studentDoc: studentDoc, subject: 'SCIENCE'),
                ],
              ),
            )));
  }

  Widget subjectButton(
      {required DocumentSnapshot studentDoc, required String subject}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: () => _goToTeacherSelectedStudentGrades(
              studentDoc: studentDoc, subject: subject),
          style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.softOrange),
          child: interText(subject, fontSize: 16, color: Colors.black)),
    );
  }

  void _goToTeacherSelectedStudentGrades(
      {required DocumentSnapshot studentDoc, required String subject}) {
    Navigator.of(context).pop();
    NavigatorRoutes.teacherSelectedStudentGrades(context,
        studentDoc: studentDoc, subject: subject);
  }
}
