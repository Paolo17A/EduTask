import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/profile_image_provider.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';

class AdminStudentRecordsScreen extends ConsumerStatefulWidget {
  const AdminStudentRecordsScreen({super.key});

  @override
  ConsumerState<AdminStudentRecordsScreen> createState() =>
      _AdminStudentRecordsScreenState();
}

class _AdminStudentRecordsScreenState
    extends ConsumerState<AdminStudentRecordsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> studentDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllStudents();
  }

  void getAllStudents() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final students = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'STUDENT')
          .get();
      studentDocs = students.docs;
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
      appBar: homeAppBarWidget(context, mayGoBack: true, actions: [
        ElevatedButton(
            onPressed: () => Navigator.of(context)
                .pushNamed(NavigatorRoutes.adminAddStudent),
            style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.veryLightGrey),
            child: interText('ADD\nSTUDENT',
                textAlign: TextAlign.center,
                color: Colors.black,
                fontWeight: FontWeight.bold))
      ]),
      drawer: appDrawer(context,
          backgroundColor: CustomColors.veryDarkGrey,
          userType: 'ADMIN',
          profileImageURL: ref.read(profileImageProvider)),
      bottomNavigationBar: adminBottomNavBar(context, index: 0),
      body: switchedLoadingContainer(
          _isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
              children: [_studentHeader(), const Gap(35), _studentsContainer()],
            )),
          )),
    );
  }

  Widget _studentHeader() {
    return interText('Student Records',
        fontSize: 36, fontWeight: FontWeight.w900, color: Colors.black);
  }

  Widget _studentsContainer() {
    return studentDocs.isNotEmpty
        ? _studentEntries()
        : interText('NO STUDENTS AVAILABLE',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
            fontSize: 55,
            color: Colors.black);
  }

  Widget _studentEntries() {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: studentDocs.length,
          itemBuilder: (context, index) {
            Color backgroundColor = index % 2 == 0
                ? CustomColors.softOrange.withOpacity(0.5)
                : Colors.white;
            return userRecordEntry(
                userDoc: studentDocs[index],
                color: backgroundColor,
                displayVerificationStatus: true,
                onTap: () => NavigatorRoutes.selectedUserRecord(context,
                    userID: studentDocs[index].id,
                    previousRoute: NavigatorRoutes.adminStudentRecords));
          }),
    );
  }
}
