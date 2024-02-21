import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/current_user_type_provider.dart';
import 'package:edutask/util/delete_entry_dialog_util.dart';
import 'package:edutask/util/future_util.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:emailjs/emailjs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';

class SelectedUserRecordScreen extends ConsumerStatefulWidget {
  final DocumentSnapshot userDoc;
  const SelectedUserRecordScreen({super.key, required this.userDoc});

  @override
  ConsumerState<SelectedUserRecordScreen> createState() =>
      _SelectedUserRecordScreenState();
}

class _SelectedUserRecordScreenState
    extends ConsumerState<SelectedUserRecordScreen> {
  bool _isLoading = false;
  String userType = '';
  String formattedName = '';
  String idNumber = '';
  String email = '';
  String profileImageURL = '';

  //  TEACHER
  String advisorySection = '';
  String advisorySectionName = '';
  List<dynamic> handledSections = [];
  List<DocumentSnapshot> handledSectionDocs = [];

  //  STUDENT
  String section = '';
  String sectionName = '';
  List<DocumentSnapshot> availableSectionDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData = widget.userDoc.data() as Map<dynamic, dynamic>;
    formattedName = '${userData['firstName']} ${userData['lastName']}';
    idNumber = userData['IDNumber'];
    email = userData['email'];
    profileImageURL = userData['profileImageURL'];
    userType = userData['userType'];
    if (userType == 'TEACHER') {
      handledSections = userData['handledSections'];
      advisorySection = userData['advisorySection'];
      if (advisorySection.isNotEmpty) {
        getAdvisorySection();
      }
      if (handledSections.isNotEmpty) getHandledSections();
    } else if (userType == 'STUDENT') {
      section = userData['section'];
      if (section.isNotEmpty)
        getStudentSection();
      else
        getAvailableSections();
    }
  }

  void getAdvisorySection() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      advisorySectionName = await getSectionName(advisorySection);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting advisory section: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void getHandledSections() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final sections = await FirebaseFirestore.instance
          .collection('sections')
          .where(FieldPath.documentId, whereIn: handledSections)
          .get();
      handledSectionDocs = sections.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting handled sections: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void getStudentSection() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final sections = await FirebaseFirestore.instance
          .collection('sections')
          .doc(section)
          .get();
      final sectionData = sections.data() as Map<dynamic, dynamic>;
      sectionName = sectionData['name'];
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting student section: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void getAvailableSections() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final sections =
          await FirebaseFirestore.instance.collection('sections').get();
      availableSectionDocs = sections.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting handled sections: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void assignStudentToSection(DocumentSnapshot sectionDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      navigator.pop();
      setState(() {
        _isLoading = true;
      });
      final sectionData = sectionDoc.data() as Map<dynamic, dynamic>;
      String name = sectionData['name'];
      //  1. Set the student's section parameter to the section's ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userDoc.id)
          .update({'section': sectionDoc.id});

      //  2.Add user to section's students
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(sectionDoc.id)
          .update({
        'students': FieldValue.arrayUnion([widget.userDoc.id])
      });
      section = sectionDoc.id;
      await EmailJS.send(
          'service_8qicz6r',
          'template_6zzxsku',
          {
            'to_email': email,
            'to_name': formattedName,
            'message_content': 'You have been assigned to section $name.'
          },
          Options(
              publicKey: 'u6vTOeKnZ6uLR3BVX',
              privateKey: 'e-HosRtW2lC5-XlLVt1WV'));
      getStudentSection();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error assigning student a section: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void deleteStudentUser() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    String userEmail = '';
    String userPassword = '';
    try {
      setState(() {
        _isLoading = true;
      });
      print(FirebaseAuth.instance.currentUser == null ? 'no user' : 'meron');
      //  Store admin's current data locally
      final currentUser = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final currentUserData = currentUser.data() as Map<dynamic, dynamic>;
      userEmail = currentUserData['email'];
      userPassword = currentUserData['password'];
      await FirebaseAuth.instance.signOut();
      //  1. Delete all of this students submissions
      final submissions = await FirebaseFirestore.instance
          .collection('submissions')
          .where('studentID', isEqualTo: widget.userDoc.id)
          .get();
      for (var submission in submissions.docs) {
        await submission.reference.delete();
      }
      //  2. Delete all of this students quiz results
      final quizResults = await FirebaseFirestore.instance
          .collection('quizResults')
          .where('studentID', isEqualTo: widget.userDoc.id)
          .get();
      for (var quizResult in quizResults.docs) {
        await quizResult.reference.delete();
      }
      //  3. Remove this student from their section
      if (section.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('sections')
            .doc(section)
            .update({
          'students': FieldValue.arrayRemove([widget.userDoc.id])
        });
      }

      //  4. Delete the grades document
      await FirebaseFirestore.instance
          .collection('grades')
          .doc(widget.userDoc.id)
          .delete();
      //  5. Sign in to the student's account and delete it
      final studentData = widget.userDoc.data() as Map<dynamic, dynamic>;
      String instructorEmail = studentData['email'];
      String instructorPassword = studentData['password'];
      final instructorToDelete = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: instructorEmail, password: instructorPassword);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(instructorToDelete.user!.uid)
          .delete();
      await instructorToDelete.user!.delete();
      //  Log-back in to admin or user's account and refresh the page
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: userPassword);
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Successfully deleted all records for this student.')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.adminStudentRecords);
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content:
              Text('Error deleting all records for this student: $error')));
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: userPassword);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void deleteTeacherUser() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    String userEmail = '';
    String userPassword = '';
    try {
      if (advisorySection.isNotEmpty) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(
                'This teacher has an advisory section. Assign a different adviser to this section first before deleting this user.')));
        return;
      }
      setState(() {
        _isLoading = true;
      });
      //  Get Teacher Data

      //  1. Get all created assignments
      final assignments = await FirebaseFirestore.instance
          .collection('assignments')
          .where('teacherID', isEqualTo: widget.userDoc.id)
          .get();
      final assignmentDocs = assignments.docs;
      final assignmentIDs = assignmentDocs.map((e) => e.id).toList();
      //  If this teacher has created an assignment, delete all of the submissions created by students
      if (assignmentIDs.isNotEmpty) {
        final submissions = await FirebaseFirestore.instance
            .collection('submissions')
            .where('assignmentID', whereIn: assignmentIDs)
            .get();
        //  Delete submissions
        for (var submission in submissions.docs) {
          await submission.reference.delete();
        }
        //  Delete assignments
        for (var assignment in assignmentDocs) {
          await assignment.reference.delete();
        }
      }

      //  2. Get all created lessons
      final lessons = await FirebaseFirestore.instance
          .collection('lessons')
          .where('teacherID', isEqualTo: widget.userDoc.id)
          .get();
      final lessonDocs = lessons.docs;
      final lessonIDs = lessonDocs.map((e) => e.id).toList();
      //  Delete lessons
      for (var lesson in lessonDocs) {
        await lesson.reference.delete();
      }
      //  3. Get all created quizzes
      final quizzes = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('teacherID', isEqualTo: widget.userDoc.id)
          .get();
      final quizDocs = quizzes.docs;
      final quizIDs = quizDocs.map((e) => e.id).toList();
      if (quizIDs.isNotEmpty) {
        final quizResults = await FirebaseFirestore.instance
            .collection('quizResults')
            .where('quizID', whereIn: quizIDs)
            .get();
        //  Delete quiz results
        for (var quizResult in quizResults.docs) {
          await quizResult.reference.delete();
        }
        //  Delete quizzes
        for (var quiz in quizDocs) {
          await quiz.reference.delete();
        }
      }

      //  4. Update the teacher's associated sections
      for (var section in handledSections) {
        await FirebaseFirestore.instance
            .collection('sections')
            .doc(section)
            .update({
          'assignments': FieldValue.arrayRemove(assignmentIDs),
          'lessons': FieldValue.arrayRemove(lessonIDs),
          'quizzes': FieldValue.arrayRemove(quizIDs),
          'teachers': FieldValue.arrayRemove([widget.userDoc.id]),
        });
      }
      //  If the teacher was an adviser of a section, remove that section's adviser
      if (advisorySection.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('sections')
            .doc(advisorySection)
            .update({'adviser': ''});
      }

      //  5. Store admin's current data locally
      final currentUser = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final currentUserData = currentUser.data() as Map<dynamic, dynamic>;
      userEmail = currentUserData['email'];
      userPassword = currentUserData['password'];
      await FirebaseAuth.instance.signOut();

      //  6. Sign in to the student's account and delete it
      final studentData = widget.userDoc.data() as Map<dynamic, dynamic>;
      String instructorEmail = studentData['email'];
      String instructorPassword = studentData['password'];
      final instructorToDelete = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: instructorEmail, password: instructorPassword);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(instructorToDelete.user!.uid)
          .delete();
      await instructorToDelete.user!.delete();

      //  7. Log-back in to admin or user's account and refresh the page
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: userPassword);

      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Successfully deleted all records for this teacher.')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.adminTeacherRecords);
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content:
              Text('Error deleting all records for this teacher: $error')));
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: userPassword);
      setState(() {
        _isLoading = false;
      });
    }
  }

  //  BUILD WIDGETS
  //============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true, actions: [
        ElevatedButton(
            onPressed: () {
              if (userType == 'STUDENT') {
                NavigatorRoutes.adminEditStudent(context,
                    studentID: widget.userDoc.id);
              } else if (userType == 'TEACHER') {
                NavigatorRoutes.adminEditTeacher(context,
                    teacherDoc: widget.userDoc);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.veryLightGrey),
            child: interText('EDIT\nUSER',
                color: Colors.black, textAlign: TextAlign.center))
      ]),
      floatingActionButton: ref.read(currentUserTypeProvider) == 'ADMIN'
          ? ElevatedButton(
              onPressed: () => displayDeleteEntryDialog(context,
                      message:
                          'Are you sure you want to delete this user and all their associated work?',
                      deleteWord: 'Delete', deleteEntry: () {
                    if (userType == 'STUDENT') {
                      deleteStudentUser();
                    } else if (userType == 'TEACHER') {
                      deleteTeacherUser();
                    }
                  }),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Icon(Icons.delete, color: Colors.white))
          : null,
      body: switchedLoadingContainer(
        _isLoading,
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: all20Pix(
              child: Column(
            children: [
              interText(
                  userType == 'TEACHER' ? 'Teacher Profile' : 'Student Profile',
                  fontSize: 40),
              _userNameContainer(formattedName),
              _basicUserData(context,
                  idNumber: idNumber,
                  email: email,
                  profileImageURL: profileImageURL),
              const Gap(20),
              if (userType == 'TEACHER')
                _handledSections(handledSections: handledSections)
              else if (userType == 'STUDENT')
                _studentSection(),
            ],
          )),
        ),
      ),
    );
  }

  Widget _userNameContainer(String formattedName) {
    return Container(
      width: double.infinity,
      height: 50,
      color: CustomColors.veryLightGrey,
      child: Center(
        child: all10Pix(
          child: Row(
            children: [interText(formattedName, fontSize: 20)],
          ),
        ),
      ),
    );
  }

  Widget _basicUserData(BuildContext context,
      {required String idNumber,
      required String email,
      required String profileImageURL}) {
    return vertical20Pix(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                interText('ID Number', fontSize: 20),
                Container(
                  width: double.infinity,
                  color: CustomColors.veryLightGrey,
                  child: Center(
                      child: Row(
                    children: [
                      const Gap(5),
                      interText(idNumber),
                    ],
                  )),
                ),
                const Gap(15),
                interText('Email', fontSize: 20),
                Container(
                  width: double.infinity,
                  color: CustomColors.veryLightGrey,
                  child: Center(
                      child: Row(
                    children: [
                      const Gap(5),
                      SizedBox(
                          width: (MediaQuery.of(context).size.width * 0.5) - 5,
                          child: interText(email)),
                    ],
                  )),
                ),
                if (userType == 'TEACHER') _advisorySection()
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: buildProfileImageWidget(
                profileImageURL: profileImageURL,
                radius: MediaQuery.of(context).size.width * 0.2),
          )
        ],
      ),
    );
  }

  Widget _handledSections({required List<dynamic> handledSections}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Handled Sections', fontSize: 20),
        Container(
            width: double.infinity,
            color: CustomColors.veryLightGrey,
            padding: const EdgeInsets.all(10),
            child: handledSections.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: handledSectionDocs.map((section) {
                      final sectionData =
                          section.data() as Map<dynamic, dynamic>;
                      String name = sectionData['name'];
                      return interText(name);
                    }).toList())
                : Center(child: interText('NO HANDLED SECTIONS'))),
      ],
    );
  }

  Widget _advisorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(20),
        interText('ADVISORY SECTION:', fontSize: 16),
        Container(
          width: double.infinity,
          color: CustomColors.veryLightGrey,
          child: Center(
              child: interText(
                  advisorySection.isNotEmpty ? advisorySectionName : 'N/A')),
        ),
      ],
    );
  }

  Widget _studentSection() {
    return section.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              interText('SECTION:', fontSize: 20),
              Container(
                width: double.infinity,
                color: CustomColors.veryLightGrey,
                padding: EdgeInsets.all(10),
                child: Center(child: interText(sectionName)),
              ),
            ],
          )
        : ovalButton('ASSIGN SECTION',
            onPress: showAvailableSectionsDialog,
            backgroundColor: CustomColors.softOrange);
  }

  void showAvailableSectionsDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Column(
                children: [
                  interText('SELECT A SECTION', fontSize: 24),
                  Gap(20),
                  Column(
                      children: availableSectionDocs.map((section) {
                    final sectionData = section.data() as Map<dynamic, dynamic>;
                    String sectionName = sectionData['name'];
                    return vertical10horizontal4(
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: ovalButton(sectionName,
                            onPress: () => assignStudentToSection(section),
                            backgroundColor: CustomColors.softOrange),
                      ),
                    );
                  }).toList())
                ],
              ),
            ));
  }
}
