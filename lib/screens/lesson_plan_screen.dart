// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/profile_image_provider.dart';
import 'package:edutask/providers/selected_quiz_type_provider.dart';
import 'package:edutask/providers/selected_subject_provider.dart';
import 'package:edutask/util/string_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../util/delete_entry_dialog_util.dart';
import '../util/navigator_util.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class LessonPlanScreen extends ConsumerStatefulWidget {
  const LessonPlanScreen({super.key});

  @override
  ConsumerState<LessonPlanScreen> createState() => _LessonPlanScreenState();
}

class _LessonPlanScreenState extends ConsumerState<LessonPlanScreen> {
  bool _isLoading = true;

  //  LESSONS
  List<DocumentSnapshot> lessonDocs = [];
  List<DocumentSnapshot> quarter1LessonDocs = [];
  List<DocumentSnapshot> quarter2LessonDocs = [];
  List<DocumentSnapshot> quarter3LessonDocs = [];
  List<DocumentSnapshot> quarter4LessonDocs = [];

  //  ASSIGNMENTS
  List<DocumentSnapshot> assignmentDocs = [];
  List<DocumentSnapshot> quarter1AssignmentDocs = [];
  List<DocumentSnapshot> quarter2AssignmentDocs = [];
  List<DocumentSnapshot> quarter3AssignmentDocs = [];
  List<DocumentSnapshot> quarter4AssignmentDocs = [];

  List<DocumentSnapshot> quizDocs = [];
  List<DocumentSnapshot> quarter1QuizDocs = [];
  List<DocumentSnapshot> quarter2QuizDocs = [];
  List<DocumentSnapshot> quarter3QuizDocs = [];
  List<DocumentSnapshot> quarter4QuizDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getLessonPlan();
  }

  void getLessonPlan() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final lessons = await FirebaseFirestore.instance
          .collection('lessons')
          .where('teacherID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      lessonDocs = lessons.docs;
      lessonDocs.sort((a, b) {
        final lessonA = a.data() as Map<dynamic, dynamic>;
        final lessonB = b.data() as Map<dynamic, dynamic>;
        DateTime lessonADateLastModified =
            (lessonA['dateLastModified'] as Timestamp).toDate();
        DateTime lessonBDateLastModified =
            (lessonB['dateLastModified'] as Timestamp).toDate();
        return lessonBDateLastModified.compareTo(lessonADateLastModified);
      });
      quarter1LessonDocs = lessonDocs.where((lesson) {
        final lessonData = lesson.data() as Map<dynamic, dynamic>;
        return lessonData['quarter'] == 1;
      }).toList();
      quarter2LessonDocs = lessonDocs.where((lesson) {
        final lessonData = lesson.data() as Map<dynamic, dynamic>;
        return lessonData['quarter'] == 2;
      }).toList();
      quarter3LessonDocs = lessonDocs.where((lesson) {
        final lessonData = lesson.data() as Map<dynamic, dynamic>;
        return lessonData['quarter'] == 3;
      }).toList();
      quarter4LessonDocs = lessonDocs.where((lesson) {
        final lessonData = lesson.data() as Map<dynamic, dynamic>;
        return lessonData['quarter'] == 4;
      }).toList();

      final assignments = await FirebaseFirestore.instance
          .collection('assignments')
          .where('teacherID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      assignmentDocs = assignments.docs;
      assignmentDocs.sort((a, b) {
        final assignmentA = a.data() as Map<dynamic, dynamic>;
        final assignmentB = b.data() as Map<dynamic, dynamic>;
        DateTime assignmentADateLastModified =
            (assignmentA['dateLastModified'] as Timestamp).toDate();
        DateTime assignmentBDateLastModified =
            (assignmentB['dateLastModified'] as Timestamp).toDate();
        return assignmentBDateLastModified
            .compareTo(assignmentADateLastModified);
      });
      quarter1AssignmentDocs = assignmentDocs.where((assignment) {
        final assignmentData = assignment.data() as Map<dynamic, dynamic>;
        return assignmentData['quarter'] == 1;
      }).toList();
      quarter2AssignmentDocs = assignmentDocs.where((assignment) {
        final assignmentData = assignment.data() as Map<dynamic, dynamic>;
        return assignmentData['quarter'] == 2;
      }).toList();
      quarter3AssignmentDocs = assignmentDocs.where((assignment) {
        final assignmentData = assignment.data() as Map<dynamic, dynamic>;
        return assignmentData['quarter'] == 3;
      }).toList();
      quarter4AssignmentDocs = assignmentDocs.where((assignment) {
        final assignmentData = assignment.data() as Map<dynamic, dynamic>;
        return assignmentData['quarter'] == 4;
      }).toList();

      final quizzes = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('teacherID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      quizDocs = quizzes.docs;
      quizDocs.sort((a, b) {
        final quizA = a.data() as Map<dynamic, dynamic>;
        final quizB = b.data() as Map<dynamic, dynamic>;
        DateTime quizADateLastModified =
            (quizA['dateLastModified'] as Timestamp).toDate();
        DateTime quizBDateLastModified =
            (quizB['dateLastModified'] as Timestamp).toDate();
        return quizBDateLastModified.compareTo(quizADateLastModified);
      });
      quarter1QuizDocs = quizDocs.where((quiz) {
        final quizData = quiz.data() as Map<dynamic, dynamic>;
        return quizData['quarter'] == 1;
      }).toList();
      quarter2QuizDocs = quizDocs.where((quiz) {
        final quizData = quiz.data() as Map<dynamic, dynamic>;
        return quizData['quarter'] == 2;
      }).toList();
      quarter3QuizDocs = quizDocs.where((quiz) {
        final quizData = quiz.data() as Map<dynamic, dynamic>;
        return quizData['quarter'] == 3;
      }).toList();
      quarter4QuizDocs = quizDocs.where((quiz) {
        final quizData = quiz.data() as Map<dynamic, dynamic>;
        return quizData['quarter'] == 4;
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting lesson plan: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void deleteLesson(DocumentSnapshot lessonDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final lessonData = lessonDoc.data() as Map<dynamic, dynamic>;

      //  1. Disassociate this lesson from every associated section
      List<dynamic> associatedSections = lessonData['associatedSections'];
      for (var section in associatedSections) {
        await FirebaseFirestore.instance
            .collection('sections')
            .doc(section)
            .update({
          'lessons': FieldValue.arrayRemove([lessonDoc.id])
        });
      }

      //  2. Delete the lessonDoc
      await FirebaseFirestore.instance
          .collection('lessons')
          .doc(lessonDoc.id)
          .delete();
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully deleted this lesson')));
      getLessonPlan();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting this lesson: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void deleteAssignment(DocumentSnapshot assignmentDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final assignmentData = assignmentDoc.data() as Map<dynamic, dynamic>;

      //  1. Disassociate this assignment from every associated section
      List<dynamic> associatedSections = assignmentData['associatedSections'];
      for (var section in associatedSections) {
        await FirebaseFirestore.instance
            .collection('sections')
            .doc(section)
            .update({
          'assignments': FieldValue.arrayRemove([assignmentDoc.id])
        });
      }

      //  2. Delete all associated submissions
      final submissions = await FirebaseFirestore.instance
          .collection('submissions')
          .where('assignmentID', isEqualTo: assignmentDoc.id)
          .get();
      for (var submission in submissions.docs) {
        await FirebaseFirestore.instance
            .collection('submissions')
            .doc(submission.id)
            .delete();
      }

      //  3. Delete the assignment document
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(assignmentDoc.id)
          .delete();

      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully deleted this assignment.')));
      getLessonPlan();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting this assignment: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void deleteQuiz(DocumentSnapshot quizDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final quizData = quizDoc.data() as Map<dynamic, dynamic>;

      //  1. Disassociate this assignment from every associated section
      List<dynamic> associatedSections = quizData['associatedSections'];
      for (var section in associatedSections) {
        await FirebaseFirestore.instance
            .collection('sections')
            .doc(section)
            .update({
          'quizzes': FieldValue.arrayRemove([quizDoc.id])
        });
      }

      //  2. Delete all associated quizResults
      final quizResults = await FirebaseFirestore.instance
          .collection('quizResults')
          .where('quizID', isEqualTo: quizDoc.id)
          .get();
      for (var quizResult in quizResults.docs) {
        await FirebaseFirestore.instance
            .collection('quizResults')
            .doc(quizResult.id)
            .delete();
      }

      //  3. Delete the quiz document
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizDoc.id)
          .delete();

      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully deleted this quiz.')));
      getLessonPlan();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting this quiz: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed(NavigatorRoutes.teacherHome);
        return false;
      },
      child: Scaffold(
        appBar: homeAppBarWidget(context, mayGoBack: true),
        drawer: appDrawer(context,
            userType: 'TEACHER',
            profileImageURL: ref.read(profileImageProvider)),
        body: switchedLoadingContainer(
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  lessonMaterialsHeader(),
                  Gap(30),
                  _expandableLessons(),
                  _expandableAssignments(),
                  _expandableQuizzes()
                ],
              )),
            )),
      ),
    );
  }

  Widget lessonMaterialsHeader() {
    return interText('LESSON MATERIALS',
        fontSize: 40, textAlign: TextAlign.center, color: Colors.black);
  }

  Widget _expandableLessons() {
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
          ovalButton('CREATE LESSON',
              onPress: () => showSubjectSelectDialog(() =>
                  Navigator.of(context).pushNamed(NavigatorRoutes.addLesson)),
              backgroundColor: CustomColors.softOrange),
          Gap(15),
          lessonDocs.isNotEmpty
              ? Column(
                  children: [
                    _quarter1Lessons(),
                    _quarter2Lessons(),
                    _quarter3Lessons(),
                    _quarter4Lessons()
                  ],
                )
              : interText('NO AVAILABLE  LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter1Lessons() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.softOrange,
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
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          color: CustomColors.verySoftOrange,
                          materialDoc: quarter1LessonDocs[index],
                          onEdit: () => NavigatorRoutes.editLesson(context,
                              lessonID: quarter1LessonDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this lesson?',
                              deleteWord: 'Delete',
                              deleteEntry: () =>
                                  deleteLesson(quarter1LessonDocs[index])))),
                )
              : interText('NO AVAILABLE  LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter2Lessons() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.softOrange,
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
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          color: CustomColors.verySoftOrange,
                          materialDoc: quarter2LessonDocs[index],
                          onEdit: () => NavigatorRoutes.editLesson(context,
                              lessonID: quarter2LessonDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this lesson?',
                              deleteWord: 'Delete',
                              deleteEntry: () =>
                                  deleteLesson(quarter2LessonDocs[index])))),
                )
              : interText('NO AVAILABLE  LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter3Lessons() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.softOrange,
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
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          color: CustomColors.verySoftOrange,
                          materialDoc: quarter3LessonDocs[index],
                          onEdit: () => NavigatorRoutes.editLesson(context,
                              lessonID: quarter3LessonDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this lesson?',
                              deleteWord: 'Delete',
                              deleteEntry: () =>
                                  deleteLesson(quarter3LessonDocs[index])))),
                )
              : interText('NO AVAILABLE  LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter4Lessons() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.softOrange,
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
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          color: CustomColors.verySoftOrange,
                          materialDoc: quarter4LessonDocs[index],
                          onEdit: () => NavigatorRoutes.editLesson(context,
                              lessonID: quarter4LessonDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this lesson?',
                              deleteWord: 'Delete',
                              deleteEntry: () =>
                                  deleteLesson(quarter4LessonDocs[index])))),
                )
              : interText('NO AVAILABLE  LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _expandableAssignments() {
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
          ovalButton('CREATE ASSIGNMENT',
              onPress: () => showSubjectSelectDialog(() => Navigator.of(context)
                  .pushNamed(NavigatorRoutes.addAssignment)),
              backgroundColor: CustomColors.softOrange),
          Gap(15),
          assignmentDocs.isNotEmpty
              ? Column(
                  children: [
                    _quarter1Assignments(),
                    _quarter2Assignments(),
                    _quarter3Assignments(),
                    _quarter4Assignments()
                  ],
                )
              : interText('NO AVAILABLE ASSIGNMENTS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter1Assignments() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.softOrange,
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
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          color: CustomColors.verySoftOrange,
                          materialDoc: quarter1AssignmentDocs[index],
                          onEdit: () => NavigatorRoutes.editAssignment(context,
                              assignmentID: quarter1AssignmentDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this assignment?',
                              deleteWord: 'Delete',
                              deleteEntry: () => deleteAssignment(
                                  quarter1AssignmentDocs[index])))),
                )
              : interText('NO AVAILABLE  ASSIGNMENTS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter2Assignments() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.softOrange,
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
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          color: CustomColors.verySoftOrange,
                          materialDoc: quarter2AssignmentDocs[index],
                          onEdit: () => NavigatorRoutes.editAssignment(context,
                              assignmentID: quarter2AssignmentDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this assignment?',
                              deleteWord: 'Delete',
                              deleteEntry: () => deleteAssignment(
                                  quarter2AssignmentDocs[index])))),
                )
              : interText('NO AVAILABLE ASSIGNMENTS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter3Assignments() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.softOrange,
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
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          color: CustomColors.verySoftOrange,
                          materialDoc: quarter3AssignmentDocs[index],
                          onEdit: () => NavigatorRoutes.editAssignment(context,
                              assignmentID: quarter3AssignmentDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this assignment?',
                              deleteWord: 'Delete',
                              deleteEntry: () => deleteAssignment(
                                  quarter3AssignmentDocs[index])))),
                )
              : interText('NO AVAILABLE ASSIGNMENTS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter4Assignments() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.softOrange,
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
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          color: CustomColors.verySoftOrange,
                          materialDoc: quarter4AssignmentDocs[index],
                          onEdit: () => NavigatorRoutes.editAssignment(context,
                              assignmentID: quarter4AssignmentDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this assignment?',
                              deleteWord: 'Delete',
                              deleteEntry: () => deleteAssignment(
                                  quarter4AssignmentDocs[index])))),
                )
              : interText('NO AVAILABLE ASSIGNMENTS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _expandableQuizzes() {
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
          ovalButton('CREATE QUIZ',
              onPress: () => showQuizTypeSelectDialog(),
              backgroundColor: CustomColors.softOrange),
          Gap(15),
          quizDocs.isNotEmpty
              ? Column(
                  children: [
                    _quarter1Quizzes(),
                    _quarter2Quizzes(),
                    _quarter3Quizzes(),
                    _quarter4Quizzes()
                  ],
                )
              : interText('NO AVAILABLE QUIZZES', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter1Quizzes() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.softOrange,
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
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          color: CustomColors.verySoftOrange,
                          materialDoc: quarter1QuizDocs[index],
                          onEdit: () => NavigatorRoutes.editQuiz(context,
                              quizID: quarter1QuizDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this quiz?',
                              deleteWord: 'Delete',
                              deleteEntry: () =>
                                  deleteQuiz(quarter1QuizDocs[index])))),
                )
              : interText('NO AVAILABLE QUIZZES', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter2Quizzes() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.softOrange,
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
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          color: CustomColors.verySoftOrange,
                          materialDoc: quarter2QuizDocs[index],
                          onEdit: () => NavigatorRoutes.editQuiz(context,
                              quizID: quarter2QuizDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this quiz?',
                              deleteWord: 'Delete',
                              deleteEntry: () =>
                                  deleteQuiz(quarter2QuizDocs[index])))),
                )
              : interText('NO AVAILABLE QUIZZES', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter3Quizzes() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.softOrange,
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
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          color: CustomColors.verySoftOrange,
                          materialDoc: quarter3QuizDocs[index],
                          onEdit: () => NavigatorRoutes.editQuiz(context,
                              quizID: quarter3QuizDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this quiz?',
                              deleteWord: 'Delete',
                              deleteEntry: () =>
                                  deleteQuiz(quarter3QuizDocs[index])))),
                )
              : interText('NO AVAILABLE QUIZZES', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quarter4Quizzes() {
    return all10Pix(
      child: ExpansionTile(
        collapsedBackgroundColor: CustomColors.softOrange,
        backgroundColor: CustomColors.softOrange,
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
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          color: CustomColors.verySoftOrange,
                          materialDoc: quarter4QuizDocs[index],
                          onEdit: () => NavigatorRoutes.editQuiz(context,
                              quizID: quarter4QuizDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this quiz?',
                              deleteWord: 'Delete',
                              deleteEntry: () =>
                                  deleteQuiz(quarter4QuizDocs[index])))),
                )
              : interText('NO AVAILABLE QUIZZES', fontSize: 20)
        ],
      ),
    );
  }

  void showQuizTypeSelectDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Column(children: [
                  interText('SELECT QUIZ TYPE',
                      fontWeight: FontWeight.bold, fontSize: 20),
                  _quizTypeTile(QuizTypes.multipleChoice),
                  _quizTypeTile(QuizTypes.trueOrFalse),
                  _quizTypeTile(QuizTypes.identification),
                ]),
              ),
            ));
  }

  void showSubjectSelectDialog(Function onPress) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    interText('SELECT SUBJECT',
                        fontWeight: FontWeight.bold, fontSize: 20),
                    _subjectTile('AP', onPress),
                    _subjectTile('ENGLISH', onPress),
                    _subjectTile('EPP', onPress),
                    _subjectTile('TLE', onPress),
                    _subjectTile('FILIPINO', onPress),
                    _subjectTile('MATH', onPress),
                    _subjectTile('MAPEH', onPress),
                    _subjectTile('SCIENCE', onPress),
                  ],
                ),
              ),
            ));
  }

  Widget _quizTypeTile(String label) {
    return InkWell(
      onTap: () {
        ref.read(selectedQuizTypeProvider.notifier).setSelectedQuizType(label);
        Navigator.of(context).pop();
        showSubjectSelectDialog(
            () => Navigator.of(context).pushNamed(NavigatorRoutes.addQuiz));
      },
      child: Container(
          decoration: BoxDecoration(border: Border.all()),
          padding: EdgeInsets.all(10),
          child: Center(
            child: interText(label, fontSize: 20),
          )),
    );
  }

  Widget _subjectTile(String label, Function onPress) {
    return InkWell(
      onTap: () {
        ref.read(selectedSubjectProvider.notifier).setSelectedSubject(label);
        Navigator.of(context).pop();
        onPress();
      },
      child: Container(
          decoration: BoxDecoration(border: Border.all()),
          padding: EdgeInsets.all(10),
          child: Center(
            child: interText(label, fontSize: 20),
          )),
    );
  }
}
