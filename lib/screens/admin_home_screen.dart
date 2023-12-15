import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: homeAppBarWidget(),
      body: switchedLoadingContainer(
          _isLoading,
          Column(
            children: [welcomeWidgets(), _homeButtons()],
          )),
    );
  }

  Widget welcomeWidgets() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          interText('WELCOME, $userType', fontSize: 50),
          buildProfileImageWidget(profileImageURL: profileImageURL)
        ],
      ),
    );
  }

  Widget _homeButtons() {
    return all20Pix(
        child: Column(
      children: [
        _homeButton('STUDENT RECORDS', () {}),
        _homeButton('TEACHER RECORDS', () {}),
        _homeButton(
            'SECTION RECORDS',
            () =>
                Navigator.of(context).pushNamed(NavigatorRoutes.adminSections))
      ],
    ));
  }

  Widget _homeButton(String label, Function onPress) {
    return all10Pix(
        child: ovalButton(label,
            onPress: onPress, width: MediaQuery.of(context).size.width * 0.75));
  }
}
