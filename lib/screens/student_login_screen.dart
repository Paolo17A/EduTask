// ignore_for_file: avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/student_section_provider.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:edutask/widgets/edutask_text_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/current_user_type_provider.dart';
import '../util/color_util.dart';
import '../widgets/custom_button_widgets.dart';

class StudentLoginScreen extends ConsumerStatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  ConsumerState<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends ConsumerState<StudentLoginScreen> {
  bool _isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void loginTeacherUser() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all fields')));
      return;
    }
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
      if (userData['userType'] != 'STUDENT') {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('This log-in is for students only.')));
        await FirebaseAuth.instance.signOut();
        emailController.clear();
        passwordController.clear();
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (userData['adminApproved'] == false) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content:
                Text('This account has not yet been approved by the admin.')));
        await FirebaseAuth.instance.signOut();
        emailController.clear();
        passwordController.clear();
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        DateTime dateEmailVerificationSent =
            (userData['dateEmailVerificationSent'] as Timestamp).toDate();
        if (DateTime.now().difference(dateEmailVerificationSent).inMinutes <
            50) {
          scaffoldMessenger.showSnackBar(SnackBar(
              content: Text(
                  'Please check your email for the email verification link.')));
        } else {
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({'dateEmailVerificationSent': DateTime.now()});
          await FirebaseAuth.instance.currentUser!.sendEmailVerification();
          scaffoldMessenger.showSnackBar(SnackBar(
              content: Text(
                  'A new email verification link has been sent to your email.')));
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (userData['section'].toString().isEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('You have not yet been assigned a section')));
        await FirebaseAuth.instance.signOut();
        emailController.clear();
        passwordController.clear();
        setState(() {
          _isLoading = false;
        });
        return;
      }
      //  reset the password in firebase in case users forgot their password and reset it using an email link.
      if (userData['password'] != passwordController.text) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'password': passwordController.text});
      }

      setState(() {
        _isLoading = false;
      });
      ref.read(currentUserTypeProvider.notifier).setCurrentUserType('STUDENT');
      ref
          .read(studentSectionProvider.notifier)
          .setStudentSection(userData['section'].toString());
      navigator.pushNamed(NavigatorRoutes.studentHome);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error logging in student: $error')));
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
                      interText('STUDENT\nLOG-IN',
                          textAlign: TextAlign.center,
                          color: Colors.black,
                          fontSize: 35),
                      authenticationIcon(context, iconData: Icons.person),
                      const Gap(30),
                      _fieldsContainer(),
                      logInBottomRow(context,
                          onRegister: () => Navigator.of(context)
                              .pushNamed(NavigatorRoutes.studentRegister))
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
          color: CustomColors.veryLightGrey,
          image: DecorationImage(
              image: AssetImage('assets/images/central_elem_logo.png'),
              fit: BoxFit.contain,
              opacity: 0.25),
          borderRadius: BorderRadius.circular(30)),
      child: all20Pix(
          child: Column(
        children: [
          _emailAddress(),
          _password(),
          ovalButton('LOG-IN >',
              onPress: loginTeacherUser,
              backgroundColor: CustomColors.veryLightGrey)
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
