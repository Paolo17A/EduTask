import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/color_util.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_bottom_nav_bar_widget.dart';
import '../widgets/edutask_text_field_widget.dart';

class AdminEditTeacherScreen extends ConsumerStatefulWidget {
  final String teacherID;
  const AdminEditTeacherScreen({super.key, required this.teacherID});

  @override
  ConsumerState<AdminEditTeacherScreen> createState() =>
      _AdminEditTeacherScreenState();
}

class _AdminEditTeacherScreenState
    extends ConsumerState<AdminEditTeacherScreen> {
  bool _isLoading = true;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final teacherNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final teacher = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.teacherID)
          .get();
      final teacherData = teacher.data() as Map<dynamic, dynamic>;
      teacherNumberController.text = teacherData['IDNumber'];
      firstNameController.text = teacherData['firstName'];
      lastNameController.text = teacherData['lastName'];
      setState(() {
        _isLoading = false;
      });
    });
  }

  void saveTeacherData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.teacherID)
          .update({
        'IDNumber': teacherNumberController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text
      });
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully saved teacher data.')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.adminTeacherRecords);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error saving teacher data: $error')));
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
              onPressed: saveTeacherData,
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
                  _teacherIDNumber(),
                  _teacherFirstName(),
                  _teacherLastName()
                ],
              )),
            )),
      ),
    );
  }

  Widget _teacherHeader() {
    return interText('Edit\n Teacher Profile',
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        textAlign: TextAlign.center);
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
}
