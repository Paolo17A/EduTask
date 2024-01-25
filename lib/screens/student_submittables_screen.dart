import 'package:edutask/providers/current_user_type_provider.dart';
import 'package:edutask/providers/profile_image_provider.dart';
import 'package:edutask/providers/student_section_provider.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../util/future_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class StudentSubmittablesScreen extends ConsumerStatefulWidget {
  const StudentSubmittablesScreen({super.key});

  @override
  ConsumerState<StudentSubmittablesScreen> createState() =>
      _StudentSubmittablesScreenState();
}

class _StudentSubmittablesScreenState
    extends ConsumerState<StudentSubmittablesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      drawer: appDrawer(context,
          userType: ref.read(currentUserTypeProvider),
          profileImageURL: ref.read(profileImageProvider)),
      bottomNavigationBar: clientBottomNavBar(context, index: -1),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: studentSubmittablesButton(context,
          backgroundColor: Colors.yellow, doNothing: true),
      body: SingleChildScrollView(
        child: all10Pix(
            child: Column(
          children: [
            interText('PENDING SCHOOLWORK',
                fontWeight: FontWeight.bold,
                fontSize: 36,
                textAlign: TextAlign.center),
            Gap(32),
            _pendingAssignments(),
            _pendingQuizzes()
          ],
        )),
      ),
    );
  }

  Widget _pendingAssignments() {
    return all10Pix(
        child: Container(
      color: CustomColors.verySoftOrange,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          interText('ASSIGNMENTS', fontWeight: FontWeight.bold, fontSize: 20),
          FutureBuilder(
              future: getPendingAssignments(ref.read(studentSectionProvider)),
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
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return pendingAssignmentEntry(context,
                                    assignmentDoc: snapshot.data![index]);
                              }),
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
          interText('QUIZZES', fontWeight: FontWeight.bold, fontSize: 20),
          FutureBuilder(
              future: getPendingQuizzes(ref.read(studentSectionProvider)),
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
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return pendingQuizEntry(context,
                                    quizDoc: snapshot.data![index]);
                              })
                        ])
                      : interText('YOU HAVE NO PENDING QUIZZES TO ANSWER',
                          fontSize: 24, textAlign: TextAlign.center);
                }
              })
        ],
      ),
    ));
  }
}
