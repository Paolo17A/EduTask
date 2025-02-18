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

import '../util/color_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class TeacherHandledSectionsScreen extends StatefulWidget {
  const TeacherHandledSectionsScreen({super.key});

  @override
  State<TeacherHandledSectionsScreen> createState() =>
      _TeacherHandledSectionsScreenState();
}

class _TeacherHandledSectionsScreenState
    extends State<TeacherHandledSectionsScreen> {
  bool _isLoading = true;
  String advisorySection = '';
  List<DocumentSnapshot> handledSectionDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getHandledSections();
  }

  void getHandledSections() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final userData = user.data() as Map<dynamic, dynamic>;
      advisorySection = userData['advisorySection'];
      List<dynamic> handledSections = userData['handledSections'];
      if (handledSections.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final sections = await FirebaseFirestore.instance
          .collection('sections')
          .where(FieldPath.documentId, whereIn: handledSections)
          .get();
      handledSectionDocs = sections.docs;

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

  //  BUILD WIDGETS
  //============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      drawer: appDrawer(context, userType: 'TEACHER'),
      bottomNavigationBar: teacherBottomNavBar(context, index: 1),
      floatingActionButton: teacherAnnouncementButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: switchedLoadingContainer(
          _isLoading,
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  if (advisorySection.isNotEmpty) _advisorySection(),
                  handledSectionHeader(),
                  _handledSectionsContainer()
                ],
              )),
            ),
          )),
    );
  }

  Widget _advisorySection() {
    return Column(
      children: [
        interText('ADVISORY SECTION',
            fontSize: 30, textAlign: TextAlign.center, color: Colors.black),
        FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('sections')
                .doc(advisorySection)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return interText(
                    'Error getting advisory section: ${snapshot.error.toString()}');
              }
              DocumentSnapshot sectionDoc = snapshot.data!;
              return SizedBox(
                  width: double.infinity,
                  child: _handledSectionEntry(sectionDoc));
            }),
        Gap(30)
      ],
    );
  }

  Widget handledSectionHeader() {
    return interText('HANDLED SECTIONS',
        fontSize: 30, textAlign: TextAlign.center, color: Colors.black);
  }

  Widget _handledSectionsContainer() {
    return handledSectionDocs.isNotEmpty
        ? _sectionEntries()
        : interText('YOU HAVE NO ASSIGNED SECTIONS TO HANDLE YET.',
            fontWeight: FontWeight.bold,
            fontSize: 30,
            textAlign: TextAlign.center);
  }

  Widget _sectionEntries() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: handledSectionDocs.length,
        itemBuilder: (context, index) {
          return _handledSectionEntry(handledSectionDocs[index]);
        });
  }

  Widget _handledSectionEntry(DocumentSnapshot sectionDoc) {
    final sectionData = sectionDoc.data() as Map<dynamic, dynamic>;
    String name = sectionData['name'];
    return vertical10horizontal4(SizedBox(
      height: 60,
      child: ElevatedButton(
          onPressed: () => NavigatorRoutes.teacherSelectedSection(context,
              sectionID: sectionDoc.id),
          style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.softOrange),
          child: interText(name, fontSize: 28, color: Colors.white)),
    ));
  }
}
