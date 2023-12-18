import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/delete_entry_dialog_util.dart';
import '../util/navigator_util.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class LessonPlanScreen extends StatefulWidget {
  const LessonPlanScreen({super.key});

  @override
  State<LessonPlanScreen> createState() => _LessonPlanScreenState();
}

class _LessonPlanScreenState extends State<LessonPlanScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> lessonDocs = [];
  List<DocumentSnapshot> quizDocs = [];
  List<DocumentSnapshot> assignmentDocs = [];

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

      final assignments = await FirebaseFirestore.instance
          .collection('assignments')
          .where('teacherID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      assignmentDocs = assignments.docs;

      final quizzes = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('teacherID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      quizDocs = quizzes.docs;
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

      //  2. Delete the assignment document
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

      //  2. Delete the assignment document
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
        drawer: appDrawer(context, userType: 'TEACHER'),
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
          ovalButton('CREATE LESSON',
              onPress: () =>
                  Navigator.of(context).pushNamed(NavigatorRoutes.addLesson)),
          Gap(15),
          lessonDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: lessonDocs.length,
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          materialDoc: lessonDocs[index],
                          onEdit: () => NavigatorRoutes.editLesson(context,
                              lessonID: lessonDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this lesson?',
                              deleteWord: 'Delete',
                              deleteEntry: () =>
                                  deleteLesson(lessonDocs[index])))),
                )
              : interText('NO AVAILABLE  LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _expandableAssignments() {
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
        title: interText('ASSIGNMENTS'),
        children: [
          ovalButton('CREATE ASSIGNMENT',
              onPress: () => Navigator.of(context)
                  .pushNamed(NavigatorRoutes.addAssignment)),
          Gap(15),
          assignmentDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: assignmentDocs.length,
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          materialDoc: assignmentDocs[index],
                          onEdit: () => NavigatorRoutes.editAssignment(context,
                              assignmentID: assignmentDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this assignment?',
                              deleteWord: 'Delete',
                              deleteEntry: () =>
                                  deleteAssignment(assignmentDocs[index])))),
                )
              : interText('NO AVAILABLE ASSIGNMENTS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _expandableQuizzes() {
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
        title: interText('QUIZZES'),
        children: [
          ovalButton('CREATE QUIZ',
              onPress: () =>
                  Navigator.of(context).pushNamed(NavigatorRoutes.addQuiz)),
          Gap(15),
          quizDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quizDocs.length,
                      itemBuilder: (context, index) => teacherMaterialEntry(
                          context,
                          materialDoc: quizDocs[index],
                          onEdit: () => NavigatorRoutes.editQuiz(context,
                              quizID: quizDocs[index].id),
                          onDelete: () => displayDeleteEntryDialog(context,
                              message:
                                  'Are you sure you want to delete this quiz?',
                              deleteWord: 'Delete',
                              deleteEntry: () => deleteQuiz(quizDocs[index])))),
                )
              : interText('NO AVAILABLE QUIZZES', fontSize: 20)
        ],
      ),
    );
  }
}
