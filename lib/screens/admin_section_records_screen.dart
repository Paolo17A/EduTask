// ignore_for_file: avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:edutask/widgets/edutask_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AdminSectionRecordsScreen extends StatefulWidget {
  const AdminSectionRecordsScreen({super.key});

  @override
  State<AdminSectionRecordsScreen> createState() =>
      _AdminSectionRecordsScreenState();
}

class _AdminSectionRecordsScreenState extends State<AdminSectionRecordsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> sectionDocs = [];

  final sectionNameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllSections();
  }

  void getAllSections() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final sections =
          await FirebaseFirestore.instance.collection('sections').get();
      sectionDocs = sections.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all sections: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void addNewSection() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (sectionNameController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please provide a section name.')));
      return;
    }
    try {
      Navigator.of(context).pop();
      setState(() {
        _isLoading = true;
      });
      String sectionID = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(sectionID)
          .set({
        'name': sectionNameController.text,
        'SCIENCE': '',
        'MATHEMATICS': '',
        'ENGLISH': '',
        'AP': '',
        'FILIPINO': '',
        'EPP': '',
        'MAPEH': '',
        'ESP': '',
        'students': []
      });
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully added new section')));
      getAllSections();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all sections: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: homeAppBarWidget(context, mayGoBack: true),
        body: switchedLoadingContainer(
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  _studentRecordsHeader(),
                  _sectionsContainer(),
                  const Gap(20),
                  ovalButton('ADD SECTION', onPress: showAddSectionDialog)
                ],
              )),
            )));
  }

  Widget _studentRecordsHeader() {
    return Row(children: [interText('Section Records', fontSize: 25)]);
  }

  Widget _sectionsContainer() {
    return sectionDocs.isNotEmpty
        ? _sectionEntries()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: interText('NO SECTIONS AVAILABLE',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center),
          );
  }

  Widget _sectionEntries() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: sectionDocs.length,
        itemBuilder: (context, index) {
          final sectionData =
              sectionDocs[index].data() as Map<dynamic, dynamic>;
          String name = sectionData['name'];
          return GestureDetector(
              onTap: () {},
              child: Container(
                color: index % 2 == 0
                    ? Colors.grey.withOpacity(0.9)
                    : Colors.white,
                height: 50,
                child: all10Pix(
                  child: Row(
                    children: [
                      interText(name, fontSize: 21, color: Colors.black)
                    ],
                  ),
                ),
              ));
        });
  }

  void showAddSectionDialog() {
    sectionNameController.clear();
    showDialog(
        context: context,
        builder: (context) => GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: AlertDialog(
                content: SizedBox(
                  //width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Column(children: [
                    interText('ADD NEW SECTION',
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                    all10Pix(
                        child: EduTaskTextField(
                            text: 'Section Name',
                            controller: sectionNameController,
                            textInputType: TextInputType.text,
                            displayPrefixIcon: null)),
                    const Gap(40),
                    ovalButton('ADD SECTION', onPress: addNewSection)
                  ]),
                ),
              ),
            ));
  }
}
