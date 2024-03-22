import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/delete_entry_dialog_util.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../util/future_util.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/edutask_text_field_widget.dart';

class AdminEditSection extends StatefulWidget {
  final String sectionID;
  const AdminEditSection({super.key, required this.sectionID});

  @override
  State<AdminEditSection> createState() => _AdminEditSectionState();
}

class _AdminEditSectionState extends State<AdminEditSection> {
  bool _isLoading = true;
  bool _isInitialized = false;
  final sectionNameController = TextEditingController();

  //  TEACHERS
  List<DocumentSnapshot> teacherDocs = [];
  List<DocumentSnapshot> availableAdvisers = [];
  List<DocumentSnapshot> availableTeachers = [];
  String selectedAdviserID = '';
  List<dynamic> assignedTeachers = [];

  //  STUDENTS
  List<DocumentSnapshot> studentDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) getSectionData();
  }

  void getSectionData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      //  Get Section Data
      final section = await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .get();
      final sectionData = section.data() as Map<dynamic, dynamic>;
      sectionNameController.text = sectionData['name'];
      selectedAdviserID = sectionData['adviser'];
      assignedTeachers = sectionData['teachers'];

      //  Get Teacher Data
      List<DocumentSnapshot> teacherDocs = await getTeacherDocs();
      availableAdvisers = teacherDocs.where((teacher) {
        final teacherData = teacher.data() as Map<dynamic, dynamic>;
        String advisorySection = teacherData['advisorySection'];
        return advisorySection.isEmpty || teacher.id == selectedAdviserID;
      }).toList();
      availableTeachers = teacherDocs.where((teacher) {
        return !assignedTeachers.contains(teacher.id) &&
            teacher.id != selectedAdviserID;
      }).toList();

      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting section data: $error')));
      setState(() {
        _isLoading = true;
      });
    }
  }

  void editThisSection() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      //  Start updating section data with new data
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .update({
        'name': sectionNameController.text,
        'adviser': selectedAdviserID,
        'teachers': assignedTeachers
      });

      final sectionDoc = await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .get();
      navigator.pop();
      NavigatorRoutes.adminSelectedSection(context,
          sectionDoc: sectionDoc, isReplacing: true);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error editing this section: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void changeSectionAdviser(String oldAdviserID, String newAdviserID) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(oldAdviserID)
          .update({'advisorySection': ''});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newAdviserID)
          .update({'advisorySection': widget.sectionID});
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .update({'adviser': newAdviserID});
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Successfully changed this section\'s adviser')));
      getSectionData();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error changing: ${error.toString()}')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void assignNewTeacher(String teacherID) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(teacherID)
          .update({
        'handledSections': FieldValue.arrayUnion([widget.sectionID])
      });
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .update({
        'teachers': FieldValue.arrayUnion([teacherID])
      });
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Successfully assigned new teacher to this section.')));
      getSectionData();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error assigning new teacher: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void unassignThisTeacher(String teacherID) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(teacherID)
          .update({
        'handledSections': FieldValue.arrayRemove([widget.sectionID])
      });
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(widget.sectionID)
          .update({
        'teachers': FieldValue.arrayRemove([teacherID])
      });
      scaffoldMessenger.showSnackBar(SnackBar(
          content:
              Text('Successfully unassigned this teacher from this section.')));
      getSectionData();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error unassigning this teacher: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  //  BUILD WIDGETS
  //============================================================================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: homeAppBarWidget(context, mayGoBack: true),
        bottomNavigationBar: adminBottomNavBar(context, index: 0),
        body: switchedLoadingContainer(
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  _sectionName(),
                  _availableAdvisers(),
                  _availableTeachers(),
                  Gap(20),
                  ovalButton('SAVE CHANGES',
                      onPress: editThisSection,
                      backgroundColor: CustomColors.softOrange)
                ],
              )),
            )),
      ),
    );
  }

  //  TEACHER WIDGETS
  //============================================================================
  Widget _sectionName() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Section Name', fontSize: 18),
        EduTaskTextField(
            text: 'Section Name',
            controller: sectionNameController,
            textInputType: TextInputType.text,
            displayPrefixIcon: const Icon(Icons.lock)),
      ],
    ));
  }

  Widget _availableAdvisers() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Section Adviser', fontSize: 18),
        if (availableAdvisers.isNotEmpty)
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(5),
            child: userDocumentSnapshotDropdownWidget(
                context,
                selectedAdviserID.isNotEmpty
                    ? selectedAdviserID
                    : availableAdvisers.first.id, (newVal) {
              changeSectionAdviser(selectedAdviserID, newVal!);
            }, availableAdvisers),
          )
        else
          interText('NO OTHER AVAILABLE ADVISERS AVAILABLE',
              fontWeight: FontWeight.bold)
      ],
    ));
  }

  Widget _availableTeachers() {
    return vertical10horizontal4(ExpansionTile(
      title: interText('Assigned Teachers', fontWeight: FontWeight.bold),
      collapsedBackgroundColor: CustomColors.softOrange,
      backgroundColor: CustomColors.verySoftOrange,
      textColor: Colors.black,
      iconColor: Colors.black,
      collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), side: BorderSide()),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), side: BorderSide()),
      children: [
        if (availableTeachers.isNotEmpty)
          ovalButton('ASSIGN NEW TEACHER',
              onPress: showAvailableTeachersDialog,
              backgroundColor: CustomColors.softOrange),
        if (assignedTeachers.isNotEmpty)
          all10Pix(
            child: Column(
              children: assignedTeachers.map((teacher) {
                return _assignedTeacherEntry(teacher);
              }).toList(),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(20),
            child: interText('NO ASSIGNED TEACHERS YET',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                textAlign: TextAlign.center),
          )
      ],
    ));
  }

  Widget _assignedTeacherEntry(String teacher) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
            color: CustomColors.softOrange,
            border: Border.all(),
            borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.all(10),
        child: FutureBuilder(
            future: getUserName(teacher),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return interText('Error getting teacher');
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    interText(snapshot.data!, fontSize: 16),
                    IconButton(
                        onPressed: () => displayDeleteEntryDialog(context,
                            message:
                                'Are you sure you want to unassign this teacher from this section?',
                            deleteWord: 'Remove',
                            deleteEntry: () => unassignThisTeacher(teacher)),
                        icon: Icon(
                          Icons.delete,
                          color: Colors.black,
                        ))
                  ],
                );
              }
            }),
      ),
    );
  }

  void showAvailableTeachersDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                  child: Column(
                children: [
                  interText('ASSIGN A TEACHER TO THIS SECTION',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center),
                  Gap(20),
                  Column(
                      children: (availableTeachers.map((teacher) {
                    final teacherData = teacher.data() as Map<dynamic, dynamic>;
                    String formattedName =
                        '${teacherData['firstName']} ${teacherData['lastName']}';
                    return ovalButton(formattedName, width: double.infinity,
                        onPress: () {
                      Navigator.of(context).pop();
                      assignNewTeacher(teacher.id);
                    }, backgroundColor: CustomColors.verySoftOrange);
                  }).toList())),
                ],
              )),
            ));
  }
}
