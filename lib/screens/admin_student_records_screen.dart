import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AdminStudentRecordsScreen extends StatefulWidget {
  const AdminStudentRecordsScreen({super.key});

  @override
  State<AdminStudentRecordsScreen> createState() =>
      _AdminStudentRecordsScreenState();
}

class _AdminStudentRecordsScreenState extends State<AdminStudentRecordsScreen> {
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
      appBar: homeAppBarWidget(context, mayGoBack: true),
      drawer: appDrawer(context, userType: 'ADMIN'),
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
            fontWeight: FontWeight.bold, fontSize: 55, color: Colors.black);
  }

  Widget _studentEntries() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: studentDocs.length,
        itemBuilder: (context, index) {
          Color backgroundColor =
              index % 2 == 0 ? Colors.grey.withOpacity(0.5) : Colors.white;
          return userRecordEntry(
              userDoc: studentDocs[index],
              color: backgroundColor,
              onTap: () => NavigatorRoutes.selectedUserRecord(context,
                  userDoc: studentDocs[index]));
        });
  }
}
