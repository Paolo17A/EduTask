import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:emailjs/emailjs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/edutask_text_field_widget.dart';

class TeacherMakeAnnouncementScreen extends StatefulWidget {
  const TeacherMakeAnnouncementScreen({super.key});

  @override
  State<TeacherMakeAnnouncementScreen> createState() =>
      _TeacherMakeAnnouncementScreenState();
}

class _TeacherMakeAnnouncementScreenState
    extends State<TeacherMakeAnnouncementScreen> {
  bool _isLoading = true;

  List<DocumentSnapshot> associatedSections = [];

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      try {
        final user = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        final userData = user.data() as Map<dynamic, dynamic>;
        List<dynamic> relatedSections = [];
        String advisorySection = userData['advisorySection'];
        if (advisorySection.isNotEmpty) {
          relatedSections.add(advisorySection);
        }
        List<dynamic> handledSections = userData['handledSections'];
        if (handledSections.isNotEmpty) {
          relatedSections.addAll(handledSections);
        }
        if (relatedSections.isEmpty) {
          scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('You have no assigned sections')));
          navigator.pop();
          return;
        }
        final sections = await FirebaseFirestore.instance
            .collection('sections')
            .where(FieldPath.documentId, whereIn: relatedSections)
            .get();
        associatedSections = sections.docs;
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error making new announcement: $error')));
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
  }

  void makeNewAnnouncement() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Please provide a title and content for this lesson.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      String announcementID = DateTime.now().millisecondsSinceEpoch.toString();
      //  1. Create Lesson Document and indicate it's associated sections
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcementID)
          .set({
        'title': titleController.text,
        'content': contentController.text,
        'dateTimeAnnounced': DateTime.now(),
        'associatedSections': associatedSections.map((e) => e.id).toList()
      });

      //  2. Get all associated students.
      List<dynamic> associatedStudentIDs = [];
      for (var section in associatedSections) {
        final sectionData = section.data() as Map<dynamic, dynamic>;
        List<dynamic> students = sectionData['students'];
        associatedStudentIDs.addAll(students);
      }

      if (associatedStudentIDs.isNotEmpty) {
        final students = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: associatedStudentIDs)
            .get();
        for (var student in students.docs) {
          final studentData = student.data();
          String email = studentData['email'];
          String firstName = studentData['firstName'];
          String lastName = studentData['lastName'];
          await EmailJS.send(
              'service_8qicz6r',
              'template_6zzxsku',
              {
                'to_email': email,
                'to_name': '$firstName $lastName',
                'message_content':
                    'A new announcement has been made: ${titleController.text}'
              },
              Options(
                  publicKey: 'u6vTOeKnZ6uLR3BVX',
                  privateKey: 'e-HosRtW2lC5-XlLVt1WV'));
        }
      }

      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully made new announcement.')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Error making new announcement: $error'),
        behavior: SnackBarBehavior.floating,
      ));
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
        appBar: homeAppBarWidget(context, mayGoBack: true),
        bottomNavigationBar: teacherBottomNavBar(context, index: -1),
        /*floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: teacherAnnouncementButton(context,
            backgroundColor: Colors.yellow, doNothing: true),*/
        body: stackedLoadingContainer(
          context,
          _isLoading,
          SingleChildScrollView(
            child: all10Pix(
                child: Column(
              children: [
                _newAnnouncementHeader(),
                Gap(30),
                _announcementTitle(),
                _announcementContent(),
                ovalButton('CREATE ANNOUCEMENT',
                    onPress: makeNewAnnouncement,
                    backgroundColor: CustomColors.softOrange)
              ],
            )),
          ),
        ),
      ),
    );
  }

  Widget _newAnnouncementHeader() {
    return interText('NEW ANNOUNCEMENT',
        fontSize: 40, textAlign: TextAlign.center, color: Colors.black);
  }

  Widget _announcementTitle() {
    return vertical10horizontal4(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Announcement Title', fontSize: 18),
          EduTaskTextField(
              text: 'Announcement Title',
              controller: titleController,
              textInputType: TextInputType.text,
              displayPrefixIcon: null),
        ],
      ),
    );
  }

  Widget _announcementContent() {
    return vertical10horizontal4(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Announcement Content', fontSize: 18),
          EduTaskTextField(
              text: 'Announcement Content',
              controller: contentController,
              textInputType: TextInputType.multiline,
              displayPrefixIcon: null),
        ],
      ),
    );
  }
}
