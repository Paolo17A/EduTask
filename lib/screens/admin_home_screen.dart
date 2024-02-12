import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/profile_image_provider.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../util/color_util.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  bool _isLoading = false;
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
        appBar: homeAppBarWidget(context, mayGoBack: true),
        drawer: appDrawer(context,
            userType: userType,
            profileImageURL: ref.read(profileImageProvider)),
        bottomNavigationBar: adminBottomNavBar(context, index: 0),
        body: switchedLoadingContainer(
            _isLoading,
            Column(
              children: [
                welcomeWidgets(
                    userType: 'ADMIN',
                    profileImageURL: profileImageURL,
                    containerColor: CustomColors.verySoftOrange),
                _homeButtons()
              ],
            )),
      ),
    );
  }

  Widget _homeButtons() {
    return all20Pix(
        child: Column(
      children: [
        homeButton(context,
            label: 'STUDENT RECORDS',
            onPress: () => Navigator.of(context)
                .pushNamed(NavigatorRoutes.adminStudentRecords)),
        homeButton(context,
            label: 'TEACHER RECORDS',
            onPress: () => Navigator.of(context)
                .pushNamed(NavigatorRoutes.adminTeacherRecords)),
        homeButton(context,
            label: 'SECTION RECORDS',
            onPress: () => Navigator.of(context)
                .pushNamed(NavigatorRoutes.adminSectionRecords))
      ],
    ));
  }
}
