import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../util/color_util.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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
      //onPopInvoked: (value) => displayQuitDialogue(context),
      child: Scaffold(
        appBar: homeAppBarWidget(context,
            backgroundColor: CustomColors.verySoftCyan, mayGoBack: true),
        drawer: appDrawer(context,
            backgroundColor: CustomColors.verySoftCyan, userType: userType),
        body: switchedLoadingContainer(
            _isLoading,
            Column(
              children: [
                welcomeWidgets(
                    userType: 'ADMIN',
                    profileImageURL: profileImageURL,
                    containerColor: CustomColors.verySoftCyan),
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
        _homeButton(
            'STUDENT RECORDS',
            () => Navigator.of(context)
                .pushNamed(NavigatorRoutes.adminStudentRecords)),
        _homeButton(
            'TEACHER RECORDS',
            () => Navigator.of(context)
                .pushNamed(NavigatorRoutes.adminTeacherRecords)),
        _homeButton(
            'SECTION RECORDS',
            () => Navigator.of(context)
                .pushNamed(NavigatorRoutes.adminSectionRecords))
      ],
    ));
  }

  Widget _homeButton(String label, Function onPress) {
    return all10Pix(
        child: ovalButton(label,
            onPress: onPress,
            width: MediaQuery.of(context).size.width * 0.75,
            height: 125,
            backgroundColor: CustomColors.moderateCyan));
  }
}
