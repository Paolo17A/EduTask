import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_image_provider.dart';
import '../util/color_util.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
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
      ref.read(profileImageProvider.notifier).setProfileImage(profileImageURL);
      print('PROFILE URL ${ref.read(profileImageProvider)}');
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
            backgroundColor: CustomColors.verySoftOrange, mayGoBack: true),
        drawer: appDrawer(context,
            backgroundColor: CustomColors.verySoftOrange,
            userType: userType,
            profileImageURL: ref.read(profileImageProvider)),
        bottomNavigationBar: userBottomNavBar(context,
            index: 0,
            userType: 'STUDENT',
            backgroundColor: CustomColors.verySoftOrange),
        body: switchedLoadingContainer(
            _isLoading,
            SingleChildScrollView(
              child: Column(
                children: [
                  welcomeWidgets(
                      userType: 'STUDENT',
                      profileImageURL: profileImageURL,
                      containerColor: CustomColors.verySoftOrange)
                ],
              ),
            )),
      ),
    );
  }
}
