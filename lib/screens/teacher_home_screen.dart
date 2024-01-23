import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/current_user_type_provider.dart';
import 'package:edutask/util/future_util.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../providers/profile_image_provider.dart';
import '../util/color_util.dart';
import '../widgets/app_bottom_nav_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  bool _isLoading = true;
  String profileImageURL = '';
  String subject = '';

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
      ref.read(profileImageProvider.notifier).setProfileImage(profileImageURL);
      subject = userData['subject'];

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
        appBar: homeAppBarWidget(context, mayGoBack: true),
        drawer: appDrawer(context,
            profileImageURL: ref.read(profileImageProvider),
            userType: ref.read(currentUserTypeProvider),
            isHome: true,
            subject: subject),
        bottomNavigationBar: userBottomNavBar(context,
            index: 0,
            userType: 'TEACHER',
            backgroundColor: CustomColors.lightGreyishLimeGreen),
        body: switchedLoadingContainer(
            _isLoading,
            SingleChildScrollView(
              child: Column(
                children: [
                  welcomeWidgets(
                      userType: 'TEACHER',
                      profileImageURL: ref.read(profileImageProvider),
                      containerColor: CustomColors.lightGreyishLimeGreen),
                  all20Pix(
                      child: Column(
                    children: [
                      _pendingSubmissions(),
                      //_teacherSchedule(),
                    ],
                  ))
                ],
              ),
            )),
      ),
    );
  }

  Widget _pendingSubmissions() {
    return vertical20Pix(
      child: Container(
        width: double.infinity,
        //height: 200,
        color: CustomColors.softLimeGreen.withOpacity(0.5),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            interText('PENDING SUBMISSIONS',
                fontWeight: FontWeight.bold, fontSize: 15),
            const Gap(16),
            FutureBuilder(
                future: getSubmissionsToCheck(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return interText(
                        'Error getting pending student submission');
                  } else {
                    return snapshot.data!.isNotEmpty
                        ? Column(children: [
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: min(2, snapshot.data!.length),
                                itemBuilder: (context, index) {
                                  return _pendingSubmissionEntry(
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
                        : interText('NO PENDING STUDENT SUBMISSIONS TO GRADE.',
                            fontSize: 24, textAlign: TextAlign.center);
                  }
                })
          ],
        ),
      ),
    );
  }

  Widget _pendingSubmissionEntry(DocumentSnapshot submissionDoc) {
    final submissionData = submissionDoc.data() as Map<dynamic, dynamic>;
    String assignmentID = submissionData['assignmentID'];
    String studentID = submissionData['studentID'];
    DateTime dateSubmitted =
        (submissionData['dateSubmitted'] as Timestamp).toDate();
    return ElevatedButton(
        onPressed: () => NavigatorRoutes.selectedSubmission(context,
            submissionID: submissionDoc.id),
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: CustomColors.softLimeGreen.withOpacity(0.5),
            foregroundColor: Colors.white),
        child: Container(
          padding: EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              studentName(studentID),
              interText(
                  'Date Submitted: ${DateFormat('MMM dd, yyyy').format(dateSubmitted)}',
                  fontSize: 18),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: assignmentName(assignmentID))
            ],
          ),
        ));
  }
}
