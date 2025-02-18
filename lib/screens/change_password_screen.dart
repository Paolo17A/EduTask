import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/current_user_type_provider.dart';
import 'package:edutask/providers/profile_image_provider.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../util/color_util.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/edutask_text_field_widget.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  bool _isLoading = false;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  void changeUserPassword() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmNewPasswordController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all the fields.')));
      return;
    }
    if (newPasswordController.text != confirmNewPasswordController.text) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('The new passwords do not match.')));
      return;
    }
    if (newPasswordController.text.length < 6) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Your password must be at least six characers long.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final userData = user.data() as Map<dynamic, dynamic>;
      if (userData['password'] != currentPasswordController.text) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('Your current password is incorrect.')));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await FirebaseAuth.instance.currentUser!
          .updatePassword(newPasswordController.text);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'password': newPasswordController.text});

      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Password changed successfully.')));
      setState(() {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();
        _isLoading = false;
      });
      return;
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error changing user password: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: homeAppBarWidget(context, mayGoBack: true),
          drawer: appDrawer(context,
              profileImageURL: ref.read(profileImageProvider),
              userType: ref.read(currentUserTypeProvider)),
          body: stackedLoadingContainer(
              context,
              _isLoading,
              SingleChildScrollView(
                child: all20Pix(
                    child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: CustomColors.veryLightGrey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      _currentPassword(),
                      _newPassword(),
                      _confirmNewPassword(),
                      vertical20Pix(
                        child: ovalButton('CHANGE PASSWORD',
                            onPress: () => changeUserPassword(),
                            backgroundColor: CustomColors.veryLightGrey),
                      )
                    ],
                  ),
                )),
              )),
        ));
  }

  Widget _currentPassword() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Current Password', fontSize: 18),
        EduTaskTextField(
            text: 'Current Password',
            controller: currentPasswordController,
            textInputType: TextInputType.visiblePassword,
            displayPrefixIcon: const Icon(Icons.lock)),
      ],
    ));
  }

  Widget _newPassword() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('New Password', fontSize: 18),
        EduTaskTextField(
            text: 'New Password',
            controller: newPasswordController,
            textInputType: TextInputType.visiblePassword,
            displayPrefixIcon: const Icon(Icons.lock)),
      ],
    ));
  }

  Widget _confirmNewPassword() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Confirm New Password', fontSize: 18),
        EduTaskTextField(
            text: 'Confirm New Password',
            controller: confirmNewPasswordController,
            textInputType: TextInputType.visiblePassword,
            displayPrefixIcon: const Icon(Icons.lock)),
      ],
    ));
  }
}
