import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:edutask/widgets/edutask_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AdminSectionsScreen extends StatefulWidget {
  const AdminSectionsScreen({super.key});

  @override
  State<AdminSectionsScreen> createState() => _AdminSectionsScreenState();
}

class _AdminSectionsScreenState extends State<AdminSectionsScreen> {
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
    try {
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
        appBar: homeAppBarWidget(),
        body: switchedLoadingContainer(
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  _studentRecordsHeader(),
                  _sectionsContainer(),
                  const Gap(20),
                  ovalButton('ADD SECTION', onPress: () {})
                ],
              )),
            )));
  }

  Widget _studentRecordsHeader() {
    return Row(children: [
      interText('Section Records', fontWeight: FontWeight.bold, fontSize: 25)
    ]);
  }

  Widget _sectionsContainer() {
    return sectionDocs.isNotEmpty
        ? _sectionEntries()
        : interText('NO SECTIONS AVAILABLE',
            fontSize: 35,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center);
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
              child: Container(
            color: index % 2 == 0 ? Colors.grey.withOpacity(0.9) : Colors.white,
            child: Row(
              children: [interText(name, fontSize: 21, color: Colors.black)],
            ),
          ));
        });
  }

  void showAddSectionHeader() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(children: [
                  interText('ADD NEW SECTION',
                      color: Colors.black,
                      fontSize: 27,
                      fontWeight: FontWeight.bold),
                  all10Pix(
                      child: EduTaskTextField(
                          text: 'Section Name',
                          controller: sectionNameController,
                          textInputType: TextInputType.text,
                          displayPrefixIcon: null)),
                  const Gap(40),
                  ovalButton('ADD SECTION', onPress: () {})
                ]),
              ),
            ));
  }
}
