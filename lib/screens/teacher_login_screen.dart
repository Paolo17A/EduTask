// ignore_for_file: avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:edutask/widgets/edutask_text_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../widgets/custom_button_widgets.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  bool _isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void loginTeacherUser() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final userData = user.data() as Map<dynamic, dynamic>;
      if (userData['userType'] != 'TEACHER') {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('This log-in is for teachers only.')));
        await FirebaseAuth.instance.signOut();
        emailController.clear();
        passwordController.clear();
        return;
      }
      setState(() {
        _isLoading = false;
      });
      navigator.pushNamed(NavigatorRoutes.teacherHome);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error logging in teacher: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: authenticationAppBarWidget(),
          body: stackedLoadingContainer(
              context,
              _isLoading,
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: all20Pix(
                      child: Column(
                    children: [
                      authenticationIcon(context, iconData: Icons.people),
                      const Gap(30),
                      interText('TEACHER LOG-IN',
                          color: Colors.black, fontSize: 35),
                      _fieldsContainer(),
                      logInBottomRow(context,
                          onRegister: () => Navigator.of(context)
                              .pushNamed(NavigatorRoutes.teacherRegister))
                    ],
                  )),
                ),
              ))),
    );
  }

  Widget _fieldsContainer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30)),
      child: all20Pix(
          child: Column(
        children: [
          _emailAddress(),
          _password(),
          ovalButton('LOG-IN', onPress: loginTeacherUser)
        ],
      )),
    );
  }

  Widget _emailAddress() {
    return vertical10horizontal4(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Email Address', fontSize: 18),
          EduTaskTextField(
              text: 'Email Address',
              controller: emailController,
              textInputType: TextInputType.emailAddress,
              displayPrefixIcon: const Icon(Icons.email)),
        ],
      ),
    );
  }

  Widget _password() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Password', fontSize: 18),
        EduTaskTextField(
            text: 'Password',
            controller: passwordController,
            textInputType: TextInputType.visiblePassword,
            displayPrefixIcon: const Icon(Icons.lock)),
      ],
    ));
  }
}
