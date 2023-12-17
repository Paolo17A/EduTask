import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../widgets/custom_text_widgets.dart';
import '../widgets/edutask_text_field_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _isLoading = false;
  final idNumberController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  void sendPasswordResetEmail() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      if (idNumberController.text.isEmpty || emailController.text.isEmpty) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Please fill up all fields.')));
        return;
      }
      if (!emailController.text.contains('@') ||
          !emailController.text.contains('.com')) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('Please enter a valid email address.')));
        return;
      }
      setState(() {
        _isLoading = true;
      });

      final similarEmails = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: emailController.text)
          .get();

      if (similarEmails.docs.isEmpty) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(
                'No user with email address \'${emailController.text}\' exists.')));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final similarID = await FirebaseFirestore.instance
          .collection('users')
          .where('IDNumber', isEqualTo: idNumberController.text)
          .get();

      if (similarID.docs.isEmpty) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(
                'No user with ID Number \'${idNumberController.text}\' exists.')));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully sent reset password email.')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error sending password reset email: $error')));
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
                    authenticationIcon(context,
                        iconData: Icons.lock_reset_rounded),
                    const Gap(30),
                    interText('PASSWORD RESET',
                        color: Colors.black, fontSize: 35),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          _studentNumber(),
                          _emailAddress(),
                          ovalButton('RESET PASSWORD',
                              onPress: sendPasswordResetEmail)
                        ],
                      ),
                    ),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: interText('< Back'))
                  ],
                )),
              ),
            )),
      ),
    );
  }

  Widget _studentNumber() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Student Number', fontSize: 18),
        EduTaskTextField(
            text: 'Student Number',
            controller: idNumberController,
            textInputType: TextInputType.number,
            displayPrefixIcon: const Icon(Icons.numbers)),
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
}
