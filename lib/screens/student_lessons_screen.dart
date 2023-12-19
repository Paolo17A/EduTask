import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../widgets/custom_text_widgets.dart';

class StudentLessonsScreen extends StatefulWidget {
  const StudentLessonsScreen({super.key});

  @override
  State<StudentLessonsScreen> createState() => _StudentLessonsScreenState();
}

class _StudentLessonsScreenState extends State<StudentLessonsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> lessonDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAssignedLessons();
  }

  void getAssignedLessons() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final userData = user.data() as Map<dynamic, dynamic>;

      String section = userData['section'];
      final sectionDoc = await FirebaseFirestore.instance
          .collection('sections')
          .doc(section)
          .get();
      final sectionData = sectionDoc.data() as Map<dynamic, dynamic>;
      List<dynamic> lessonIDs = sectionData['lessons'];
      if (lessonIDs.isNotEmpty) {
        final lessons = await FirebaseFirestore.instance
            .collection('lessons')
            .where(FieldPath.documentId, whereIn: lessonIDs)
            .get();
        lessonDocs = lessons.docs;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting assigned lessons: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      drawer: appDrawer(context, userType: 'STUDENT'),
      bottomNavigationBar:
          userBottomNavBar(context, index: 1, userType: 'STUDENT'),
      body: switchedLoadingContainer(
          _isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
              children: [
                _assignedLessonsHeader(),
                Gap(30),
                _lessonsContainer()
              ],
            )),
          )),
    );
  }

  Widget _assignedLessonsHeader() {
    return interText('ASSIGNED LESSONS',
        fontSize: 40, textAlign: TextAlign.center, color: Colors.black);
  }

  Widget _lessonsContainer() {
    return lessonDocs.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: lessonDocs.length,
            itemBuilder: (context, index) {
              final lessonData =
                  lessonDocs[index].data() as Map<dynamic, dynamic>;
              String title = lessonData['title'];
              return ElevatedButton(
                  onPressed: () => NavigatorRoutes.selectedLesson(context,
                      lessonID: lessonDocs[index].id),
                  child: interText(title, fontWeight: FontWeight.bold));
            },
          )
        : interText('NO ASSIGNED LESSONS AVAILABLE',
            fontSize: 30, color: Colors.black, textAlign: TextAlign.center);
  }
}
