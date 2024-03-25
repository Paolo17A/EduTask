import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/student_section_provider.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../util/color_util.dart';
import '../util/navigator_util.dart';
import '../widgets/app_bar_widgets.dart';

import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class StudentSubjectMaterialsScreen extends ConsumerStatefulWidget {
  final String subject;
  const StudentSubjectMaterialsScreen({super.key, required this.subject});

  @override
  ConsumerState<StudentSubjectMaterialsScreen> createState() =>
      _StudentSubjectMaterialsScreenState();
}

class _StudentSubjectMaterialsScreenState
    extends ConsumerState<StudentSubjectMaterialsScreen> {
  Future<DocumentSnapshot?> getTeacherDoc() async {
    final section = await FirebaseFirestore.instance
        .collection('sections')
        .doc(ref.read(studentSectionProvider))
        .get();
    final sectionData = section.data() as Map<dynamic, dynamic>;
    if (section[widget.subject].toString().isEmpty) {
      return null;
    }
    final teacher = await FirebaseFirestore.instance
        .collection('users')
        .doc(sectionData[widget.subject])
        .get();
    return teacher;
  }

  Future<List<DocumentSnapshot>> getSectionLessons() async {
    final lessons = await FirebaseFirestore.instance
        .collection('lessons')
        .where('associatedSections',
            arrayContains: ref.read(studentSectionProvider))
        .where('subject', isEqualTo: widget.subject)
        .get();
    return lessons.docs;
  }

  Future<List<DocumentSnapshot>> getSectionAssignments() async {
    final assignments = await FirebaseFirestore.instance
        .collection('assignments')
        .where('associatedSections',
            arrayContains: ref.read(studentSectionProvider))
        .where('subject', isEqualTo: widget.subject)
        .get();
    return assignments.docs;
  }

  Future<List<DocumentSnapshot>> getSectionQuizzes() async {
    final quizzes = await FirebaseFirestore.instance
        .collection('quizzes')
        .where('associatedSections',
            arrayContains: ref.read(studentSectionProvider))
        .where('subject', isEqualTo: widget.subject)
        .get();
    return quizzes.docs;
  }

  Future<DocumentSnapshot?> getSubmission(String assignmentID) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('submissions')
        .where('assignmentID', isEqualTo: assignmentID)
        .where('studentID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      return result.docs.first;
    } else {
      return null;
    }
  }

  Future<DocumentSnapshot?> getQuizResult(String quizID) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('quizResults')
        .where('quizID', isEqualTo: quizID)
        .where('studentID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      return result.docs.first;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      bottomNavigationBar: clientBottomNavBar(context, index: 1),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: studentSubmittablesButton(context),
      body: SingleChildScrollView(
        child: all20Pix(
            child: Column(
          children: [
            interText('Subject: ${widget.subject}',
                fontWeight: FontWeight.bold, fontSize: 36),
            _teacherName(),
            _expandableLessons(),
            _expandableAssignments(),
            _expandableQuizzes()
          ],
        )),
      ),
    );
  }

  Widget _teacherName() {
    return FutureBuilder(
        future: getTeacherDoc(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return interText('-');
          } else {
            if (snapshot.hasData) {
              final teacherData =
                  snapshot.data!.data() as Map<dynamic, dynamic>;
              final formattedName =
                  '${teacherData['firstName']} ${teacherData['lastName']}';
              return interText('Teacher: $formattedName', fontSize: 20);
            } else {
              return interText('No Teacher Available');
            }
          }
        });
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
          FutureBuilder(
              future: getSectionLessons(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return interText('Error getting section lessons');
                }
                List<DocumentSnapshot> quarter1LessonDocs = [];
                List<DocumentSnapshot> quarter2LessonDocs = [];
                List<DocumentSnapshot> quarter3LessonDocs = [];
                List<DocumentSnapshot> quarter4LessonDocs = [];

                quarter1LessonDocs = snapshot.data!.where((lesson) {
                  final lessonData = lesson.data() as Map<dynamic, dynamic>;
                  return lessonData['quarter'] == 1;
                }).toList();

                quarter2LessonDocs = snapshot.data!.where((lesson) {
                  final lessonData = lesson.data() as Map<dynamic, dynamic>;
                  return lessonData['quarter'] == 2;
                }).toList();

                quarter3LessonDocs = snapshot.data!.where((lesson) {
                  final lessonData = lesson.data() as Map<dynamic, dynamic>;
                  return lessonData['quarter'] == 3;
                }).toList();

                quarter4LessonDocs = snapshot.data!.where((lesson) {
                  final lessonData = lesson.data() as Map<dynamic, dynamic>;
                  return lessonData['quarter'] == 4;
                }).toList();
                return snapshot.data!.isNotEmpty
                    ? Column(
                        children: [
                          _quarterLessons(1, quarter1LessonDocs),
                          _quarterLessons(2, quarter2LessonDocs),
                          _quarterLessons(3, quarter3LessonDocs),
                          _quarterLessons(4, quarter4LessonDocs)
                        ],
                      )
                    : interText('NO AVAILABLE LESSONS', fontSize: 20);
              })
        ],
      ),
    );
  }

  Widget _quarterLessons(
      int quarter, List<DocumentSnapshot> quarterLessonDocs) {
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
        title: interText('QUARTER $quarter'),
        children: [
          quarterLessonDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarterLessonDocs.length,
                      itemBuilder: (context, index) {
                        final lessonData = quarterLessonDocs[index].data()
                            as Map<dynamic, dynamic>;
                        String title = lessonData['title'];
                        return all10Pix(
                          child: ElevatedButton(
                              onPressed: () => NavigatorRoutes.selectedLesson(
                                  context,
                                  lessonID: quarterLessonDocs[index].id),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColors.verySoftOrange),
                              child: interText(title,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        );
                      }),
                )
              : interText('NO AVAILABLE LESSONS', fontSize: 20)
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
          FutureBuilder(
              future: getSectionAssignments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return interText('Error getting section assignments');
                }
                List<DocumentSnapshot> quarter1AssignmentDocs = [];
                List<DocumentSnapshot> quarter2AssignmentDocs = [];
                List<DocumentSnapshot> quarter3AssignmentDocs = [];
                List<DocumentSnapshot> quarter4AssignmentDocs = [];
                quarter1AssignmentDocs = snapshot.data!.where((assignment) {
                  final assignmentData =
                      assignment.data() as Map<dynamic, dynamic>;
                  return assignmentData['quarter'] == 1;
                }).toList();
                quarter2AssignmentDocs = snapshot.data!.where((assignment) {
                  final assignmentData =
                      assignment.data() as Map<dynamic, dynamic>;
                  return assignmentData['quarter'] == 2;
                }).toList();
                quarter3AssignmentDocs = snapshot.data!.where((assignment) {
                  final assignmentData =
                      assignment.data() as Map<dynamic, dynamic>;
                  return assignmentData['quarter'] == 3;
                }).toList();
                quarter4AssignmentDocs = snapshot.data!.where((assignment) {
                  final assignmentData =
                      assignment.data() as Map<dynamic, dynamic>;
                  return assignmentData['quarter'] == 4;
                }).toList();

                return snapshot.data!.isNotEmpty
                    ? Column(
                        children: [
                          _quarterAssignments(1, quarter1AssignmentDocs),
                          _quarterAssignments(2, quarter2AssignmentDocs),
                          _quarterAssignments(3, quarter3AssignmentDocs),
                          _quarterAssignments(4, quarter4AssignmentDocs),
                        ],
                      )
                    : interText('NO AVAILABLE ASSIGNMENTS', fontSize: 20);
              })
        ],
      ),
    );
  }

  Widget _quarterAssignments(
      int quarter, List<DocumentSnapshot> quarterAssignmentDocs) {
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
        title: interText('QUARTER $quarter'),
        children: [
          quarterAssignmentDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarterAssignmentDocs.length,
                      itemBuilder: (context, index) {
                        final assignmentData = quarterAssignmentDocs[index]
                            .data() as Map<dynamic, dynamic>;
                        String title = assignmentData['title'];
                        return Container(
                          color: CustomColors.softOrange,
                          padding: EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: interText(title,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: _assignmentActionButton(
                                    quarterAssignmentDocs[index].id),
                              )
                            ],
                          ),
                        );
                      }),
                )
              : interText('NO AVAILABLE LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _assignmentActionButton(String assignmentID) {
    return FutureBuilder(
      future: getSubmission(assignmentID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return interText('Error getting assignment status');
        } else if (!snapshot.hasData) {
          return ovalButton('ANSWER\nASSIGNMENT',
              onPress: () => NavigatorRoutes.answerAssignment(context,
                  assignmentID: assignmentID),
              backgroundColor: CustomColors.verySoftOrange);
        }
        return ovalButton('VIEW\nSUBMISSION',
            onPress: () => NavigatorRoutes.selectedSubmission(context,
                submissionID: snapshot.data!.id),
            backgroundColor: CustomColors.softOrange);
      },
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
          FutureBuilder(
              future: getSectionQuizzes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return interText('Error getting section quizzes');
                }
                List<DocumentSnapshot> quarter1QuizDocs = [];
                List<DocumentSnapshot> quarter2QuizDocs = [];
                List<DocumentSnapshot> quarter3QuizDocs = [];
                List<DocumentSnapshot> quarter4QuizDocs = [];
                quarter1QuizDocs = snapshot.data!.where((quiz) {
                  final quizData = quiz.data() as Map<dynamic, dynamic>;
                  return quizData['quarter'] == 1;
                }).toList();
                quarter2QuizDocs = snapshot.data!.where((quiz) {
                  final quizData = quiz.data() as Map<dynamic, dynamic>;
                  return quizData['quarter'] == 2;
                }).toList();
                quarter3QuizDocs = snapshot.data!.where((quiz) {
                  final quizData = quiz.data() as Map<dynamic, dynamic>;
                  return quizData['quarter'] == 3;
                }).toList();
                quarter4QuizDocs = snapshot.data!.where((quiz) {
                  final quizData = quiz.data() as Map<dynamic, dynamic>;
                  return quizData['quarter'] == 4;
                }).toList();
                return snapshot.data!.isNotEmpty
                    ? Column(
                        children: [
                          _quarterQuizzes(1, quarter1QuizDocs),
                          _quarterQuizzes(2, quarter2QuizDocs),
                          _quarterQuizzes(3, quarter3QuizDocs),
                          _quarterQuizzes(4, quarter4QuizDocs),
                        ],
                      )
                    : interText('NO AVAILABLE QUIZZES', fontSize: 20);
              })
        ],
      ),
    );
  }

  Widget _quarterQuizzes(int quarter, List<DocumentSnapshot> quarterQuizDocs) {
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
        title: interText('QUARTER $quarter'),
        children: [
          quarterQuizDocs.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: quarterQuizDocs.length,
                      itemBuilder: (context, index) {
                        return _quizEntry(quarterQuizDocs[index], index);
                      }),
                )
              : interText('NO AVAILABLE LESSONS', fontSize: 20)
        ],
      ),
    );
  }

  Widget _quizEntry(DocumentSnapshot quizDoc, int index) {
    final quizData = quizDoc.data() as Map<dynamic, dynamic>;
    String title = quizData['title'];

    return all10Pix(
      child: Container(
        color: CustomColors.softOrange,
        padding: EdgeInsets.all(5),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              interText(title,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
          _quizActionButton(quizDoc.id)
        ]),
      ),
    );
  }

  Widget _quizActionButton(String quizID) {
    return FutureBuilder(
      future: getQuizResult(quizID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return interText('Error getting quiz status');
        } else if (!snapshot.hasData) {
          return ovalButton('ANSWER\nQUIZ',
              onPress: () =>
                  NavigatorRoutes.answerQuiz(context, quizID: quizID),
              backgroundColor: CustomColors.verySoftOrange);
        }
        return ovalButton('VIEW\nRESULTS',
            onPress: () => NavigatorRoutes.selectedQuizResult(context,
                quizResultID: snapshot.data!.id),
            backgroundColor: CustomColors.verySoftOrange);
      },
    );
  }
}
