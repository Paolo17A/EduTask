import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:edutask/widgets/dropdown_widget.dart';
import 'package:edutask/widgets/edutask_text_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TeacherRegisterScreen extends StatefulWidget {
  const TeacherRegisterScreen({super.key});

  @override
  State<TeacherRegisterScreen> createState() => _TeacherRegisterScreenState();
}

enum RegistrastionStates { register, profile }

class _TeacherRegisterScreenState extends State<TeacherRegisterScreen> {
  bool _isLoading = false;
  RegistrastionStates currentState = RegistrastionStates.register;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String handledSubject = '';
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

  void loginTeacherUser() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error logging in admin: $error')));
    }
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
      registerThisTeacher();
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

  void registerThisTeacher() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      if (handledSubject.isEmpty ||
          firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty) {
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
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'userType': 'TEACHER',
        'email': emailController.text,
        'password': passwordController.text,
        'subject': handledSubject,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'handledSections': [],
        'profileImageURL': ''
      });
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully registered new teacher!')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.teacherLogin);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error registering new teacher: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  //  BUILD WIDGETS
  //============================================================================
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
                      interText('TEACHER REGISTER',
                          color: Colors.black, fontSize: 35),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30)),
                          child: currentState == RegistrastionStates.register
                              ? _registerFieldsContainer()
                              : _profileFieldsContainer()),
                    ],
                  )),
                ),
              ))),
    );
  }

  Widget _registerFieldsContainer() {
    return all20Pix(
        child: Column(
      children: [
        _emailAddress(),
        _password(),
        _confirmPassword(),
        _navigatorButtons()
      ],
    ));
  }

  Widget _profileFieldsContainer() {
    return all20Pix(
        child: Column(
      children: [
        _sectionDropdown(),
        _firstName(),
        _lastName(),
        _navigatorButtons()
      ],
    ));
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

  Widget _firstName() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('First Name', fontSize: 18),
        EduTaskTextField(
            text: 'First Name',
            controller: firstNameController,
            textInputType: TextInputType.text,
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
            textInputType: TextInputType.text,
            displayPrefixIcon: const Icon(Icons.person)),
      ],
    ));
  }

  Widget _navigatorButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ovalButton('< BACK', onPress: goPreviousState),
        ovalButton('NEXT >', onPress: goNextState)
      ],
    );
  }
}
