import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_image_provider.dart';
import '../util/color_util.dart';
import '../util/delete_entry_dialog_util.dart';
import '../widgets/app_bar_widgets.dart';
import '../widgets/app_bottom_nav_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';

class AdminAllLessonsScreen extends ConsumerStatefulWidget {
  const AdminAllLessonsScreen({super.key});

  @override
  ConsumerState<AdminAllLessonsScreen> createState() =>
      _AdminAllLessonsScreenState();
}

class _AdminAllLessonsScreenState extends ConsumerState<AdminAllLessonsScreen> {
  bool _isLoading = false;
  List<DocumentSnapshot> lessonDocs = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getAllLessons());
  }

  void getAllLessons() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final lessons =
          await FirebaseFirestore.instance.collection('lessons').get();
      lessonDocs = lessons.docs;
      lessonDocs.sort((a, b) {
        final lessonA = a.data() as Map<dynamic, dynamic>;
        final lessonB = b.data() as Map<dynamic, dynamic>;
        DateTime lessonADateLastModified =
            (lessonA['dateLastModified'] as Timestamp).toDate();
        DateTime lessonBDateLastModified =
            (lessonB['dateLastModified'] as Timestamp).toDate();
        return lessonBDateLastModified.compareTo(lessonADateLastModified);
      });
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all lessons: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void deleteLesson(DocumentSnapshot lessonDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final lessonData = lessonDoc.data() as Map<dynamic, dynamic>;

      //  1. Disassociate this lesson from every associated section
      List<dynamic> associatedSections = lessonData['associatedSections'];
      for (var section in associatedSections) {
        await FirebaseFirestore.instance
            .collection('sections')
            .doc(section)
            .update({
          'lessons': FieldValue.arrayRemove([lessonDoc.id])
        });
      }

      //  2. Delete the lessonDoc
      await FirebaseFirestore.instance
          .collection('lessons')
          .doc(lessonDoc.id)
          .delete();
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully deleted this lesson.')));
      getAllLessons();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting this lesson: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      drawer: appDrawer(context,
          userType: 'ADMIN', profileImageURL: ref.read(profileImageProvider)),
      bottomNavigationBar: adminBottomNavBar(context, index: 2),
      body: switchedLoadingContainer(
          _isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
              children: [_lessonsHeader(), _lessonEntries()],
            )),
          )),
    );
  }

  Widget _lessonsHeader() {
    return vertical10horizontal4(
      interText('ALL LESSONS', textAlign: TextAlign.center, fontSize: 28),
    );
  }

  Widget _lessonEntries() {
    return lessonDocs.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: lessonDocs.length,
            itemBuilder: (context, index) {
              return adminMaterialEntry(context,
                  materialDoc: lessonDocs[index],
                  color: CustomColors.softOrange.withOpacity(0.5),
                  onView: () => NavigatorRoutes.adminSelectedLesson(context,
                      lessonDoc: lessonDocs[index]),
                  onDelete: () => displayDeleteEntryDialog(context,
                      message: 'Are you sure you want to delete this lesson?',
                      deleteWord: 'Delete',
                      deleteEntry: () => deleteLesson(lessonDocs[index])));
            })
        : interText('NO LESSONS AVAILABLE',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
            fontSize: 36);
  }
}
