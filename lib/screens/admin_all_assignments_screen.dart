import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_image_provider.dart';
import '../util/color_util.dart';
import '../util/delete_entry_dialog_util.dart';
import '../util/navigator_util.dart';
import '../widgets/app_bar_widgets.dart';
import '../widgets/app_bottom_nav_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class AdminAllAssignmentsScreen extends ConsumerStatefulWidget {
  const AdminAllAssignmentsScreen({super.key});

  @override
  ConsumerState<AdminAllAssignmentsScreen> createState() =>
      _AdminAllAssignmentsScreenState();
}

class _AdminAllAssignmentsScreenState
    extends ConsumerState<AdminAllAssignmentsScreen> {
  bool _isLoading = false;
  List<DocumentSnapshot> assignmentDocs = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getAllAssignments());
  }

  void getAllAssignments() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final assignments =
          await FirebaseFirestore.instance.collection('assignments').get();
      assignmentDocs = assignments.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all assignments: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void deleteAssignment(DocumentSnapshot assignmentDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final assignmentData = assignmentDoc.data() as Map<dynamic, dynamic>;

      //  1. Disassociate this assignment from every associated section
      List<dynamic> associatedSections = assignmentData['associatedSections'];
      for (var section in associatedSections) {
        await FirebaseFirestore.instance
            .collection('sections')
            .doc(section)
            .update({
          'lessons': FieldValue.arrayRemove([assignmentDoc.id])
        });
      }

      //  2. Delete every submission of this assignment
      final submissions = await FirebaseFirestore.instance
          .collection('submissions')
          .where('assignmentID', isEqualTo: assignmentDoc.id)
          .get();
      for (var submission in submissions.docs) {
        await submission.reference.delete();
      }

      //  3. Delete the assignmentDoc
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(assignmentDoc.id)
          .delete();
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully deleted this assignment.')));
      getAllAssignments();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting this assignment: $error')));
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
      bottomNavigationBar: adminBottomNavBar(context, index: 2),
      body: switchedLoadingContainer(
          _isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
                    children: [_assignmentsHeader(), _assignmentEntries()])),
          )),
    );
  }

  Widget _assignmentsHeader() {
    return vertical10horizontal4(interText('ALL ASSIGNMENTS',
        textAlign: TextAlign.center, fontSize: 28));
  }

  Widget _assignmentEntries() {
    return assignmentDocs.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: assignmentDocs.length,
            itemBuilder: (context, index) {
              return adminMaterialEntry(context,
                  materialDoc: assignmentDocs[index],
                  color: CustomColors.moderateCyan.withOpacity(0.5),
                  onView: () => NavigatorRoutes.adminSelectedAssignment(context,
                      assignmentDoc: assignmentDocs[index]),
                  onDelete: () => displayDeleteEntryDialog(context,
                      message:
                          'Are you sure you want to delete this assignment?',
                      deleteWord: 'Delete',
                      deleteEntry: () =>
                          deleteAssignment(assignmentDocs[index])));
            })
        : interText('NO ASSIGNMENTS AVAILABLE',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
            fontSize: 36);
  }
}
