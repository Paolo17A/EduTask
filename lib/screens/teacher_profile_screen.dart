// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/edutask_text_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../util/color_util.dart';
import '../util/navigator_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  bool _editMode = false;
  String userType = '';
  String subject = '';
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  String profileImageURL = '';
  ImagePicker imagePicker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) getAdminProfile();
  }

  void getAdminProfile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final userData = user.data() as Map<dynamic, dynamic>;
      userType = userData['userType'];
      subject = userData['subject'];
      firstNameController.text = userData['firstName'];
      lastNameController.text = userData['lastName'];
      profileImageURL = userData['profileImageURL'];
      setState(() {
        _isLoading = false;
        _isInitialized = true;
        _editMode = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting teacher profile: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        return;
      }
      setState(() {
        _isLoading = true;
      });
      //  Handle Profile Image
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePics')
          .child(FirebaseAuth.instance.currentUser!.uid);
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profileImageURL': downloadURL});
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully changed profile picture.')));
      setState(() {
        profileImageURL = downloadURL;
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error changing profile picture: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeProfileImage() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      //  Handle Profile Image
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePics')
          .child(FirebaseAuth.instance.currentUser!.uid);
      await storageRef.delete();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profileImageURL': ''});
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully removed profile picture.')));
      setState(() {
        profileImageURL = '';
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error removing profile picture: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void editProfile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text
      });

      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully edited profile')));
      setState(() {
        _isLoading = false;
        _editMode = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error editing profile: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed(NavigatorRoutes.teacherHome);
        return false;
      },
      child: GestureDetector(
        onTap: () {
          final FocusScopeNode currentScope = FocusScope.of(context);
          if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
            FocusManager.instance.primaryFocus!.unfocus();
          }
        },
        child: Scaffold(
          appBar: homeAppBarWidget(context,
              backgroundColor: CustomColors.lightGreyishLimeGreen,
              mayGoBack: true),
          drawer: appDrawer(context,
              backgroundColor: CustomColors.lightGreyishLimeGreen,
              userType: userType),
          body: stackedLoadingContainer(
              context,
              _isLoading,
              SingleChildScrollView(
                child: all20Pix(
                    child: Column(
                  children: [
                    _basicTeacherData(),
                    const Gap(30),
                    if (_editMode)
                      ovalButton('CANCEL CHANGES',
                          onPress: () => getAdminProfile(),
                          backgroundColor: CustomColors.softLimeGreen),
                    ovalButton(_editMode ? 'SAVE CHANGES' : 'EDIT PROFILE',
                        onPress: () {
                      if (_editMode) {
                        editProfile();
                      } else {
                        setState(() {
                          _editMode = true;
                        });
                      }
                    }, backgroundColor: CustomColors.softLimeGreen)
                  ],
                )),
              )),
        ),
      ),
    );
  }

  Widget _basicTeacherData() {
    return vertical20Pix(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Subject Handled: $subject', fontSize: 23),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: Column(
                  children: [
                    buildProfileImageWidget(
                        profileImageURL: profileImageURL,
                        radius: MediaQuery.of(context).size.width * 0.2),
                    if (_editMode)
                      ovalButton('UPLOAD PHOTO',
                          onPress: _pickProfileImage,
                          backgroundColor: CustomColors.softLimeGreen),
                    if (_editMode && profileImageURL.isNotEmpty)
                      ovalButton('DELETE PHOTO',
                          onPress: _removeProfileImage,
                          backgroundColor: CustomColors.softLimeGreen)
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    interText('First Name', fontSize: 20),
                    EduTaskTextField(
                        text: 'First Name',
                        controller: firstNameController,
                        textInputType: TextInputType.name,
                        displayPrefixIcon: null,
                        enabled: _editMode),
                    const Gap(15),
                    interText('Last Name', fontSize: 20),
                    EduTaskTextField(
                        text: 'Last Name',
                        controller: lastNameController,
                        textInputType: TextInputType.name,
                        displayPrefixIcon: null,
                        enabled: _editMode)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
