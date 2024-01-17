import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/profile_image_provider.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';

class AdminSectionRecordsScreen extends ConsumerStatefulWidget {
  const AdminSectionRecordsScreen({super.key});

  @override
  ConsumerState<AdminSectionRecordsScreen> createState() =>
      _AdminSectionRecordsScreenState();
}

class _AdminSectionRecordsScreenState
    extends ConsumerState<AdminSectionRecordsScreen> {
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
        appBar: homeAppBarWidget(context,
            backgroundColor: CustomColors.verySoftCyan, mayGoBack: true),
        drawer: appDrawer(context,
            backgroundColor: CustomColors.verySoftCyan,
            userType: 'ADMIN',
            profileImageURL: ref.read(profileImageProvider)),
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
                          .pushNamed(NavigatorRoutes.addSection),
                      backgroundColor: CustomColors.moderateCyan)
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
              onTap: () => NavigatorRoutes.adminSelectedSection(context,
                  sectionDoc: sectionDocs[index]),
              child: Container(
                decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? CustomColors.moderateCyan.withOpacity(0.5)
                        : Colors.white,
                    border: Border.all()),
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
