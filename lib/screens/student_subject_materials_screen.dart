import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_bar_widgets.dart';

class StudentSubjectMaterialsScreen extends ConsumerStatefulWidget {
  final String subject;
  const StudentSubjectMaterialsScreen({super.key, required this.subject});

  @override
  ConsumerState<StudentSubjectMaterialsScreen> createState() =>
      _StudentSubjectMaterialsScreenState();
}

class _StudentSubjectMaterialsScreenState
    extends ConsumerState<StudentSubjectMaterialsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      bottomNavigationBar: clientBottomNavBar(context, index: 1),
      body: SingleChildScrollView(
        child: all20Pix(
            child: Column(
          children: [],
        )),
      ),
    );
  }
}
