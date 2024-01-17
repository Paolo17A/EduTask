import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/edutask_text_field_widget.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

enum RegistrastionStates { register, profile }

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  bool _isLoading = false;
  RegistrastionStates currentState = RegistrastionStates.register;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final studentNumberController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
  }

  void goPreviousState() {
    if (currentState == RegistrastionStates.register) {
      Navigator.of(context).pop();
    } else if (currentState == RegistrastionStates.profile) {
      setState(() {
        currentState = RegistrastionStates.register;
      });
    }
  }

  void goNextState() async {
    if (currentState == RegistrastionStates.register) {
      validateRegisterEntries();
    } else if (currentState == RegistrastionStates.profile) {
      finishStudentRegistration();
    }
  }

  void validateRegisterEntries() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      if (emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
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
      final similarUsers = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: emailController.text)
          .get();
      if (similarUsers.docs.isNotEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('This email address is already taken')));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });
      setState(() {
        currentState = RegistrastionStates.profile;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error validating field entries: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void finishStudentRegistration() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      if (firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          studentNumberController.text.isEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('Please fill up all provided fields.')));
        return;
      }
      setState(() {
        _isLoading = true;
      });
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      await FirebaseFirestore.instance
          .collection('grades')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'SCIENCE': {'assignments': {}, 'quizzes': {}},
        'MATHEMATICS': {'assignments': {}, 'quizzes': {}},
        'ENGLISH': {'assignments': {}, 'quizzes': {}},
        'AP': {'assignments': {}, 'quizzes': {}},
        'FILIPINO': {'assignments': {}, 'quizzes': {}},
        'EPP': {'assignments': {}, 'quizzes': {}},
        'MAPEH': {'assignments': {}, 'quizzes': {}},
        'ESP': {'assignments': {}, 'quizzes': {}}
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'userType': 'STUDENT',
        'email': emailController.text,
        'password': passwordController.text,
        'IDNumber': studentNumberController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'section': '',
        'profileImageURL': ''
      });
      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Sucessfully created new student user!')));
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.studentLogin);
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
        appBar: authenticationAppBarWidget(),
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  interText('STUDENT REGISTRATION',
                      color: Colors.black,
                      fontSize: 36,
                      textAlign: TextAlign.center),
                  authenticationIcon(context, iconData: Icons.person),
                  const Gap(30),
                  if (currentState == RegistrastionStates.register)
                    _registerFieldsContainer()
                  else if (currentState == RegistrastionStates.profile)
                    _profileFieldsContainer()
                ],
              )),
            )),
      ),
    );
  }

  Widget _registerFieldsContainer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
          color: CustomColors.veryLightGrey,
          image: DecorationImage(
              image: AssetImage('assets/images/central_elem_logo.png'),
              fit: BoxFit.contain,
              opacity: 0.25),
          borderRadius: BorderRadius.circular(30)),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _emailAddress(),
          _password(),
          _confirmPassword(),
          _navigatorButtons()
        ],
      ),
    );
  }

  Widget _profileFieldsContainer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
          color: CustomColors.softOrange.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30)),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _studentNumber(),
          _firstName(),
          _lastName(),
          _navigatorButtons()
        ],
      ),
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

  Widget _confirmPassword() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Confirm Password', fontSize: 18),
        EduTaskTextField(
            text: 'Confirm Password',
            controller: confirmPasswordController,
            textInputType: TextInputType.visiblePassword,
            displayPrefixIcon: const Icon(Icons.lock)),
      ],
    ));
  }

  Widget _studentNumber() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Student Number', fontSize: 18),
        EduTaskTextField(
            text: 'Student Number',
            controller: studentNumberController,
            textInputType: TextInputType.number,
            displayPrefixIcon: const Icon(Icons.numbers)),
      ],
    ));
  }

  Widget _firstName() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('First Name', fontSize: 18),
        EduTaskTextField(
            text: 'First Name',
            controller: firstNameController,
            textInputType: TextInputType.name,
            displayPrefixIcon: const Icon(Icons.person)),
      ],
    ));
  }

  Widget _lastName() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Last Name', fontSize: 18),
        EduTaskTextField(
            text: 'Last Name',
            controller: lastNameController,
            textInputType: TextInputType.name,
            displayPrefixIcon: const Icon(Icons.person)),
      ],
    ));
  }

  Widget _navigatorButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ovalButton('< BACK',
            onPress: goPreviousState,
            backgroundColor: CustomColors.veryLightGrey),
        ovalButton('NEXT >',
            onPress: goNextState, backgroundColor: CustomColors.veryLightGrey)
      ],
    );
  }
}
