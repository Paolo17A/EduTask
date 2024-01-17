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

class AdminAllQuizzesScreen extends ConsumerStatefulWidget {
  const AdminAllQuizzesScreen({super.key});

  @override
  ConsumerState<AdminAllQuizzesScreen> createState() =>
      _AdminAllQuizzesScreenState();
}

class _AdminAllQuizzesScreenState extends ConsumerState<AdminAllQuizzesScreen> {
  bool _isLoading = false;
  List<DocumentSnapshot> quizDocs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getAllQuizzes());
  }

  void getAllQuizzes() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final quizzes =
          await FirebaseFirestore.instance.collection('quizzes').get();
      quizDocs = quizzes.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all quizzes: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void deleteQuiz(DocumentSnapshot quizDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final quizData = quizDoc.data() as Map<dynamic, dynamic>;

      //  1. Disassociate this quiz from every associated section
      List<dynamic> associatedSections = quizData['associatedSections'];
      for (var section in associatedSections) {
        await FirebaseFirestore.instance
            .collection('sections')
            .doc(section)
            .update({
          'quizzes': FieldValue.arrayRemove([quizDoc.id])
        });
      }

      //  2. Delete every result of this quiz
      final quizzes = await FirebaseFirestore.instance
          .collection('quizResults')
          .where('quizID', isEqualTo: quizDoc.id)
          .get();
      for (var quiz in quizzes.docs) {
        await quiz.reference.delete();
      }

      //  3. Delete the quizDoc
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizDoc.id)
          .delete();
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully deleted this quiz.')));
      getAllQuizzes();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting this quiz: $error')));
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
                child: Column(children: [_quizzesHeader(), _quizEntries()])),
          )),
    );
  }

  Widget _quizzesHeader() {
    return vertical10horizontal4(
        interText('ALL QUIZZES', textAlign: TextAlign.center, fontSize: 28));
  }

  Widget _quizEntries() {
    return quizDocs.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: quizDocs.length,
            itemBuilder: (context, index) {
              return adminMaterialEntry(context,
                  materialDoc: quizDocs[index],
                  color: CustomColors.moderateCyan.withOpacity(0.5),
                  onView: () => NavigatorRoutes.adminSelectedQuiz(context,
                      quizDoc: quizDocs[index]),
                  onDelete: () => displayDeleteEntryDialog(context,
                      message: 'Are you sure you want to delete this quiz?',
                      deleteWord: 'Delete',
                      deleteEntry: () => deleteQuiz(quizDocs[index])));
            })
        : interText('NO QUIZZES AVAILABLE',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
            fontSize: 36);
  }
}
