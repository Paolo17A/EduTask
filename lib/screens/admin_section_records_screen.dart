// ignore_for_file: avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
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
                  ovalButton('ADD SECTION',
                      onPress: () => Navigator.of(context)
                          .pushNamed(NavigatorRoutes.addSection))
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
              onTap: () => NavigatorRoutes.selectedSection(context,
                  sectionDoc: sectionDocs[index]),
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
}
