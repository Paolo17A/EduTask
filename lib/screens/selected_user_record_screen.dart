import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';

class SelectedUserRecordScreen extends StatefulWidget {
  final DocumentSnapshot userDoc;
  const SelectedUserRecordScreen({super.key, required this.userDoc});

  @override
  State<SelectedUserRecordScreen> createState() =>
      _SelectedUserRecordScreenState();
}

class _SelectedUserRecordScreenState extends State<SelectedUserRecordScreen> {
  bool _isLoading = false;
  String userType = '';
  String formattedName = '';
  String idNumber = '';
  String email = '';
  String profileImageURL = '';

  //  TEACHER
  List<dynamic> handledSections = [];
  List<DocumentSnapshot> handledSectionDocs = [];

  //  STUDENT
  String section = '';
  String sectionName = '';
  List<DocumentSnapshot> availableSectionDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData = widget.userDoc.data() as Map<dynamic, dynamic>;
    formattedName = '${userData['firstName']} ${userData['lastName']}';
    idNumber = userData['IDNumber'];
    email = userData['email'];
    profileImageURL = userData['profileImageURL'];
    userType = userData['userType'];
    if (userType == 'TEACHER') {
      handledSections = userData['handledSections'];
      if (handledSections.isNotEmpty) getHandledSections();
    } else if (userType == 'STUDENT') {
      section = userData['section'];
      if (section.isNotEmpty)
        getStudentSection();
      else
        getAvailableSections();
    }
  }

  void getHandledSections() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
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

  void getStudentSection() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final sections = await FirebaseFirestore.instance
          .collection('sections')
          .doc(section)
          .get();
      final sectionData = sections.data() as Map<dynamic, dynamic>;
      sectionName = sectionData['name'];
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting student section: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void getAvailableSections() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final sections =
          await FirebaseFirestore.instance.collection('sections').get();
      availableSectionDocs = sections.docs;
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

  void assignStudentToSection(DocumentSnapshot sectionDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      navigator.pop();
      setState(() {
        _isLoading = true;
      });

      //  1. Set the student's section parameter to the section's ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userDoc.id)
          .update({'section': sectionDoc.id});

      //  2.Add user to section's students
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(sectionDoc.id)
          .update({
        'students': FieldValue.arrayUnion([widget.userDoc.id])
      });
      section = sectionDoc.id;
      getStudentSection();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error assigning student a section: $error')));
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
      appBar: homeAppBarWidget(context,
          backgroundColor: CustomColors.verySoftCyan, mayGoBack: true),
      body: switchedLoadingContainer(
        _isLoading,
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: all20Pix(
              child: Column(
            children: [
              interText(
                  userType == 'TEACHER' ? 'Teacher Profile' : 'Student Profile',
                  fontSize: 40),
              _userNameContainer(formattedName),
              _basicUserData(context,
                  idNumber: idNumber,
                  email: email,
                  profileImageURL: profileImageURL),
              const Gap(20),
              if (userType == 'TEACHER')
                _handledSections(handledSections: handledSections)
              else if (userType == 'STUDENT')
                _studentSection()
            ],
          )),
        ),
      ),
    );
  }

  Widget _userNameContainer(String formattedName) {
    return Container(
      width: double.infinity,
      height: 50,
      color: CustomColors.moderateCyan.withOpacity(0.5),
      child: Center(
        child: all10Pix(
          child: Row(
            children: [interText(formattedName, fontSize: 20)],
          ),
        ),
      ),
    );
  }

  Widget _basicUserData(BuildContext context,
      {required String idNumber,
      required String email,
      required String profileImageURL}) {
    return vertical20Pix(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                interText('ID Number', fontSize: 20),
                Container(
                  width: double.infinity,
                  height: 30,
                  color: CustomColors.moderateCyan.withOpacity(0.5),
                  child: Center(
                      child: Row(
                    children: [
                      const Gap(5),
                      interText(idNumber),
                    ],
                  )),
                ),
                const Gap(15),
                interText('Email', fontSize: 20),
                Container(
                  width: double.infinity,
                  height: 30,
                  color: CustomColors.moderateCyan.withOpacity(0.5),
                  child: Center(
                      child: Row(
                    children: [
                      const Gap(5),
                      interText(email),
                    ],
                  )),
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: buildProfileImageWidget(
                profileImageURL: profileImageURL,
                radius: MediaQuery.of(context).size.width * 0.2),
          )
        ],
      ),
    );
  }

  Widget _handledSections({required List<dynamic> handledSections}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Handled Sections', fontSize: 20),
        Container(
            width: double.infinity,
            color: CustomColors.moderateCyan.withOpacity(0.5),
            padding: const EdgeInsets.all(10),
            child: handledSections.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: handledSectionDocs.map((section) {
                      final sectionData =
                          section.data() as Map<dynamic, dynamic>;
                      String name = sectionData['name'];
                      return interText(name);
                    }).toList())
                : Center(child: interText('NO HANDLED SECTIONS'))),
      ],
    );
  }

  Widget _studentSection() {
    return section.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              interText('SECTION:', fontSize: 20),
              Container(
                width: double.infinity,
                color: CustomColors.moderateCyan.withOpacity(0.5),
                padding: EdgeInsets.all(10),
                child: Center(child: interText(sectionName)),
              ),
            ],
          )
        : ovalButton('ASSIGN SECTION',
            onPress: showAvailableSectionsDialog,
            backgroundColor: CustomColors.moderateCyan);
  }

  void showAvailableSectionsDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Column(
                children: [
                  interText('SELECT A SECTION', fontSize: 24),
                  Gap(20),
                  Column(
                      children: availableSectionDocs.map((section) {
                    final sectionData = section.data() as Map<dynamic, dynamic>;
                    String sectionName = sectionData['name'];
                    return vertical10horizontal4(
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: ElevatedButton(
                            onPressed: () => assignStudentToSection(section),
                            child: interText(sectionName)),
                      ),
                    );
                  }).toList())
                ],
              ),
            ));
  }
}
