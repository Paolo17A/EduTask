import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/color_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/dropdown_widget.dart';
import 'package:edutask/widgets/edutask_text_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/navigator_util.dart';
import '../widgets/custom_text_widgets.dart';

class AdminAddTeacherScreen extends StatefulWidget {
  const AdminAddTeacherScreen({super.key});

  @override
  State<AdminAddTeacherScreen> createState() => _AdminAddTeacherScreenState();
}

class _AdminAddTeacherScreenState extends State<AdminAddTeacherScreen> {
  bool _isLoading = false;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final teacherNumberController = TextEditingController();
  String handledSubject = '';

  void finishTeacherRegistration() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      if (firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          teacherNumberController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty ||
          handledSubject.isEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('Please fill up all provided fields.')));
        return;
      }
      if (!emailController.text.contains('@') ||
          !emailController.text.contains('.com')) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('Please input a valid email address.')));
        return;
      }
      if (passwordController.text != confirmPasswordController.text) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('The passwords do not match')));
        return;
      }
      if (passwordController.text.length < 6) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('The password must be at least 6 characters long.')));
        return;
      }

      setState(() {
        _isLoading = true;
      });
      //  Store admin's current data locally
      final currentUser = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final currentUserData = currentUser.data() as Map<dynamic, dynamic>;
      String userEmail = currentUserData['email'];
      String userPassword = currentUserData['password'];
      await FirebaseAuth.instance.signOut();

      //  Create new student and initialize their data.
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'userType': 'TEACHER',
        'email': emailController.text,
        'password': passwordController.text,
        'IDNumber': teacherNumberController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'handledSections': [],
        'subject': handledSubject,
        'profileImageURL': ''
      });

      //  Sign out the newly created student and return to admin or teacher's account
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: userPassword);
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Sucessfully created new student user!')));

      setState(() {
        _isLoading = false;
      });
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.adminTeacherRecords);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error registering new student: $error')));
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
        appBar: homeAppBarWidget(context, mayGoBack: true, actions: [
          ElevatedButton(
              onPressed: finishTeacherRegistration,
              style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.veryLightGrey),
              child: interText('SAVE\nTEACHER',
                  color: Colors.black, textAlign: TextAlign.center))
        ]),
        bottomNavigationBar: adminBottomNavBar(context, index: 0),
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  _teacherHeader(),
                  _emailAddress(),
                  _password(),
                  _confirmPassword(),
                  Gap(20),
                  _teacherIDNumber(),
                  _teacherFirstName(),
                  _teacherLastName(),
                  Gap(20),
                  _sectionDropdown()
                ],
              )),
            )),
      ),
    );
  }

  Widget _teacherHeader() {
    return interText('New\n Teacher Profile',
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        textAlign: TextAlign.center);
  }

  Widget _emailAddress() {
    return vertical10horizontal4(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Teacher Email Address', fontSize: 20),
          EduTaskTextField(
              text: '',
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
        interText('Password', fontSize: 20),
        EduTaskTextField(
            text: '',
            controller: passwordController,
            textInputType: TextInputType.visiblePassword,
            displayPrefixIcon: const Icon(Icons.lock)),
      ],
    ));
  }

  Widget _confirmPassword() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Confirm Password', fontSize: 20),
        EduTaskTextField(
            text: '',
            controller: confirmPasswordController,
            textInputType: TextInputType.visiblePassword,
            displayPrefixIcon: const Icon(Icons.lock)),
      ],
    ));
  }

  Widget _teacherIDNumber() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Teacher ID Number', fontSize: 20, color: Colors.black),
        EduTaskTextField(
            text: '',
            controller: teacherNumberController,
            textInputType: TextInputType.number,
            displayPrefixIcon: null)
      ],
    ));
  }

  Widget _teacherFirstName() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Teacher First Name', fontSize: 20, color: Colors.black),
        EduTaskTextField(
            text: '',
            controller: firstNameController,
            textInputType: TextInputType.name,
            displayPrefixIcon: null)
      ],
    ));
  }

  Widget _teacherLastName() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Teacher Last Name', fontSize: 20, color: Colors.black),
        EduTaskTextField(
            text: '',
            controller: lastNameController,
            textInputType: TextInputType.name,
            displayPrefixIcon: null)
      ],
    ));
  }

  Widget _sectionDropdown() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Handled Subject', fontSize: 18),
        Container(
          decoration: BoxDecoration(
              border: Border.all(), borderRadius: BorderRadius.circular(20)),
          child: dropdownWidget(handledSubject, (newVal) {
            setState(() {
              handledSubject = newVal!;
            });
          }, [
            'SCIENCE',
            'MATHEMATICS',
            'ENGLISH',
            'AP',
            'FILIPINO',
            'EPP',
            'MAPEH',
            'ESP'
          ], '', false),
        ),
      ],
    ));
  }
}
