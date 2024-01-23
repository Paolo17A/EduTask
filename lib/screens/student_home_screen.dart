import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/current_user_type_provider.dart';
import 'package:edutask/util/future_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/profile_image_provider.dart';
import '../util/color_util.dart';
import '../util/navigator_util.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  bool _isLoading = true;
  String profileImageURL = '';
  String section = '';

//List<DocumentSnapshot> pendingAssignments = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getBasicUserData();
  }

  void getBasicUserData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final userData = user.data() as Map<dynamic, dynamic>;
      profileImageURL = userData['profileImageURL'];
      section = userData['section'];
      ref.read(profileImageProvider.notifier).setProfileImage(profileImageURL);

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting basic user data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: homeAppBarWidget(context,
            backgroundColor: CustomColors.veryDarkGrey, mayGoBack: true),
        drawer: appDrawer(context,
            userType: ref.read(currentUserTypeProvider),
            profileImageURL: ref.read(profileImageProvider)),
        bottomNavigationBar: clientBottomNavBar(context, index: 0),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: studentSubmittablesButton(context),
        body: switchedLoadingContainer(
            _isLoading,
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  welcomeWidgets(
                      userType: 'STUDENT',
                      profileImageURL: profileImageURL,
                      containerColor: CustomColors.verySoftOrange),
                  _sectionName(),
                  _pendingAssignments(),
                  _pendingQuizzes()
                ],
              ),
            )),
      ),
    );
  }

  Widget _sectionName() {
    return all10Pix(
      child: FutureBuilder(
          future: getSectionName(section),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return interText('Error getting section');
            } else {
              return interText('Section: ${snapshot.data}',
                  fontWeight: FontWeight.bold, fontSize: 16);
            }
          }),
    );
  }

  Widget _pendingAssignments() {
    return all10Pix(
        child: Container(
      color: CustomColors.verySoftOrange,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          interText('PENDING ASSIGNMENTS',
              fontWeight: FontWeight.bold, fontSize: 20),
          FutureBuilder(
              future: getPendingAssignments(section),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return interText('Error getting assignments');
                } else {
                  return snapshot.data!.isNotEmpty
                      ? Column(children: [
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: min(2, snapshot.data!.length),
                              itemBuilder: (context, index) {
                                return _pendingAssignmentEntry(
                                    snapshot.data![index]);
                              }),
                          if (snapshot.data!.length > 2)
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                      onPressed: () {},
                                      child: interText('VIEW ALL'))
                                ])
                        ])
                      : interText('YOU HAVE NO PENDING ASSIGNMENTS TO SUBMIT.',
                          fontSize: 24, textAlign: TextAlign.center);
                }
              })
        ],
      ),
    ));
  }

  Widget _pendingQuizzes() {
    return all10Pix(
        child: Container(
      color: CustomColors.verySoftOrange,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          interText('PENDING QUIZZES',
              fontWeight: FontWeight.bold, fontSize: 20),
          FutureBuilder(
              future: getPendingQuizzes(section),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return interText('Error getting quizzes');
                } else {
                  return snapshot.data!.isNotEmpty
                      ? Column(children: [
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: min(2, snapshot.data!.length),
                              itemBuilder: (context, index) {
                                return _pendingQuizEntry(snapshot.data![index]);
                              }),
                          if (snapshot.data!.length > 2)
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                      onPressed: () {},
                                      child: interText('VIEW ALL'))
                                ])
                        ])
                      : interText('YOU HAVE NO PENDING ASSIGNMENTS TO SUBMIT.',
                          fontSize: 24, textAlign: TextAlign.center);
                }
              })
        ],
      ),
    ));
  }

  Widget _pendingAssignmentEntry(DocumentSnapshot assignmentDoc) {
    final assignmentData = assignmentDoc.data() as Map<dynamic, dynamic>;
    String title = assignmentData['title'];
    String subject = assignmentData['subject'];
    DateTime deadline = (assignmentData['deadline'] as Timestamp).toDate();
    return ElevatedButton(
        onPressed: () => NavigatorRoutes.answerAssignment(context,
            assignmentID: assignmentDoc.id, fromHomeScreen: true),
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: CustomColors.softOrange,
            foregroundColor: Colors.white),
        child: Container(
          padding: EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              interText('Subject: $subject',
                  fontWeight: FontWeight.bold, fontSize: 18),
              interText(
                  'Deadline: ${DateFormat('MMM dd, yyyy').format(deadline)}',
                  fontSize: 18),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: interText(title, fontSize: 16))
            ],
          ),
        ));
  }

  Widget _pendingQuizEntry(DocumentSnapshot quizDoc) {
    final quizData = quizDoc.data() as Map<dynamic, dynamic>;
    String title = quizData['title'];
    String subject = quizData['subject'];
    return ElevatedButton(
        onPressed: () =>
            NavigatorRoutes.answerQuiz(context, quizID: quizDoc.id),
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: CustomColors.softOrange,
            foregroundColor: Colors.white),
        child: Container(
          padding: EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              interText('Subject: $subject',
                  fontWeight: FontWeight.bold, fontSize: 18),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: interText(title, fontSize: 16))
            ],
          ),
        ));
  }
}
