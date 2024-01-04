import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../widgets/app_bottom_nav_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  bool _isLoading = true;
  String userType = '';
  String profileImageURL = '';

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
      userType = userData['userType'];
      profileImageURL = userData['profileImageURL'];

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
            backgroundColor: CustomColors.lightGreyishLimeGreen,
            mayGoBack: true),
        drawer: appDrawer(context,
            backgroundColor: CustomColors.lightGreyishLimeGreen,
            userType: userType),
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
                      profileImageURL: profileImageURL,
                      containerColor: CustomColors.lightGreyishLimeGreen),
                  all20Pix(
                      child: Column(
                    children: [_pendingSubmissions(), _teacherSchedule()],
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
        height: 200,
        color: CustomColors.softLimeGreen.withOpacity(0.5),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            interText('PENDING SUBMISSIONS',
                fontWeight: FontWeight.bold, fontSize: 15),
            const Gap(16),
            interText('No Pending Submissions to Check'),
          ],
        ),
      ),
    );
  }

  Widget _teacherSchedule() {
    return vertical20Pix(
      child: Container(
        width: double.infinity,
        height: 200,
        color: CustomColors.softLimeGreen.withOpacity(0.5),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            interText('SCHEDULE', fontWeight: FontWeight.bold, fontSize: 15),
            const Gap(16),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                    5,
                    (index) => Container(
                          height: 120,
                          width: 50,
                          color: Colors.white,
                        )))
          ],
        ),
      ),
    );
  }
}
