import 'package:edutask/util/color_util.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/current_user_type_provider.dart';
import '../providers/profile_image_provider.dart';
import '../widgets/app_bottom_nav_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_button_widgets.dart';

class StudentProgressSubjectSelectScreen extends ConsumerWidget {
  const StudentProgressSubjectSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      drawer: appDrawer(context,
          userType: ref.read(currentUserTypeProvider),
          profileImageURL: ref.read(profileImageProvider)),
      bottomNavigationBar: clientBottomNavBar(context, index: 2),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: studentSubmittablesButton(context),
      body: SingleChildScrollView(
        child: all20Pix(
            child: Column(
          children: [
            interText('GRADES OVERVIEW',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center),
            subjectButton(context, label: 'AP'),
            subjectButton(context, label: 'ENGLISH'),
            subjectButton(context, label: 'EPP'),
            subjectButton(context, label: 'ESP'),
            subjectButton(context, label: 'FILIPINO'),
            subjectButton(context, label: 'MAPEH'),
            subjectButton(context, label: 'MATHEMATICS'),
            subjectButton(context, label: 'SCIENCE'),
            Gap(20)
          ],
        )),
      ),
    );
  }

  Widget subjectButton(BuildContext context, {required String label}) {
    return vertical10horizontal4(SizedBox(
      width: double.infinity,
      height: 75,
      child: ElevatedButton(
          onPressed: () =>
              NavigatorRoutes.studentSubjectGrades(context, subject: label),
          style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.softOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
          child: interText(label,
              fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white)),
    ));
  }
}
