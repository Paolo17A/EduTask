import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/color_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/dropdown_widget.dart';
import 'package:edutask/widgets/edutask_text_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/navigator_util.dart';
import '../widgets/custom_text_widgets.dart';

class AdminAddStudentScreen extends StatefulWidget {
  const AdminAddStudentScreen({super.key});

  @override
  State<AdminAddStudentScreen> createState() => _AdminAddStudentScreenState();
}

class _AdminAddStudentScreenState extends State<AdminAddStudentScreen> {
  bool _isLoading = true;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final studentNumberController = TextEditingController();
  List<DocumentSnapshot> availableSectionDocs = [];
  String selectedSection = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getAvailableSections());
  }

  void getAvailableSections() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final sections =
          await FirebaseFirestore.instance.collection('sections').get();
      availableSectionDocs = sections.docs;
      selectedSection = availableSectionDocs.first.id;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting handled sections: $error')));
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
          studentNumberController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty ||
          selectedSection.isEmpty) {
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
        'section': selectedSection,
        'profileImageURL': ''
      });

      await FirebaseFirestore.instance
          .collection('sections')
          .doc(selectedSection)
          .update({
        'students':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
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
      navigator.pushReplacementNamed(NavigatorRoutes.adminStudentRecords);
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
        appBar: homeAppBarWidget(context,
            backgroundColor: CustomColors.verySoftCyan,
            mayGoBack: true,
            actions: [
              ElevatedButton(
                  onPressed: finishStudentRegistration,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.moderateCyan),
                  child: interText('SAVE\nSTUDENT',
                      color: Colors.white, textAlign: TextAlign.center))
            ]),
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  _studentHeader(),
                  _emailAddress(),
                  _password(),
                  _confirmPassword(),
                  Gap(20),
                  _studentIDNumber(),
                  _studentFirstName(),
                  _studentLastName(),
                  Gap(20),
                  if (availableSectionDocs.isNotEmpty) _sectionDropdown()
                ],
              )),
            )),
      ),
    );
  }

  Widget _studentHeader() {
    return interText('New\n Student Profile',
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
          interText('Student Email Address', fontSize: 20),
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

  Widget _studentIDNumber() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Student ID Number', fontSize: 20, color: Colors.black),
        EduTaskTextField(
            text: '',
            controller: studentNumberController,
            textInputType: TextInputType.number,
            displayPrefixIcon: null)
      ],
    ));
  }

  Widget _studentFirstName() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Student First Name', fontSize: 20, color: Colors.black),
        EduTaskTextField(
            text: '',
            controller: firstNameController,
            textInputType: TextInputType.name,
            displayPrefixIcon: null)
      ],
    ));
  }

  Widget _studentLastName() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Student Last Name', fontSize: 20, color: Colors.black),
        EduTaskTextField(
            text: '',
            controller: lastNameController,
            textInputType: TextInputType.name,
            displayPrefixIcon: null)
      ],
    ));
  }

  Widget _sectionDropdown() {
    return vertical10horizontal4(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Student Section', fontSize: 20, color: Colors.black),
          sectionDocumentSnapshotDropdownWidget(
              selectedSection.isNotEmpty
                  ? selectedSection
                  : availableSectionDocs.first.id, (newVal) {
            setState(() {
              selectedSection = newVal!;
            });
          }, availableSectionDocs),
        ],
      ),
    );
  }
}
