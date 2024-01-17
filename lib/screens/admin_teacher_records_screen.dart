import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/profile_image_provider.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../widgets/app_drawer_widget.dart';

class AdminTeacherRecordsScreen extends ConsumerStatefulWidget {
  const AdminTeacherRecordsScreen({super.key});

  @override
  ConsumerState<AdminTeacherRecordsScreen> createState() =>
      _AdminTeacherRecordsScreenState();
}

class _AdminTeacherRecordsScreenState
    extends ConsumerState<AdminTeacherRecordsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> teacherDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllTeachers();
  }

  void getAllTeachers() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final teachers = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'TEACHER')
          .get();
      teacherDocs = teachers.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all teachers: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context,
          backgroundColor: CustomColors.verySoftCyan,
          mayGoBack: true,
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed(NavigatorRoutes.adminAddTeacher),
                style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.moderateCyan),
                child: interText('ADD\nTEACHER',
                    textAlign: TextAlign.center, color: Colors.white))
          ]),
      drawer: appDrawer(context,
          backgroundColor: CustomColors.verySoftCyan,
          userType: 'ADMIN',
          profileImageURL: ref.read(profileImageProvider)),
      body: switchedLoadingContainer(
          _isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
              children: [_teacherHeader(), const Gap(35), _teachersContainer()],
            )),
          )),
    );
  }

  Widget _teacherHeader() {
    return interText('Teacher Records',
        fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black);
  }

  Widget _teachersContainer() {
    return teacherDocs.isNotEmpty
        ? _teacherEntries()
        : interText('NO TEACHERS AVAILABLE',
            fontWeight: FontWeight.bold, fontSize: 55, color: Colors.black);
  }

  Widget _teacherEntries() {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: teacherDocs.length,
          itemBuilder: (context, index) {
            Color backgroundColor = index % 2 == 0
                ? CustomColors.moderateCyan.withOpacity(0.5)
                : Colors.white;
            return userRecordEntry(
                userDoc: teacherDocs[index],
                color: backgroundColor,
                onTap: () => NavigatorRoutes.selectedUserRecord(context,
                    userDoc: teacherDocs[index]));
          }),
    );
  }
}
