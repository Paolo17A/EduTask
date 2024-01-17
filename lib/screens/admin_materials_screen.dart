import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/profile_image_provider.dart';
import '../util/color_util.dart';
import '../widgets/app_bar_widgets.dart';
import '../widgets/app_bottom_nav_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_padding_widgets.dart';

class AdminMaterialsScreen extends ConsumerWidget {
  const AdminMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context, Ref) {
    return Scaffold(
      appBar: homeAppBarWidget(context,
          backgroundColor: CustomColors.verySoftCyan, mayGoBack: true),
      drawer: appDrawer(context,
          backgroundColor: CustomColors.verySoftCyan,
          userType: 'ADMIN',
          profileImageURL: Ref.read(profileImageProvider)),
      bottomNavigationBar: adminBottomNavBar(context, index: 2),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: all20Pix(
              child: Column(
            children: [
              interText('LEARNING MATERIALS',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center),
              Gap(20),
              homeButton(context,
                  label: 'LESSONS',
                  onPress: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.adminAllLessons)),
              homeButton(context,
                  label: 'ASSIGNMENTS',
                  onPress: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.adminAllAssignments)),
              homeButton(context,
                  label: 'QUIZZES',
                  onPress: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.adminAllQuizzes))
            ],
          )),
        ),
      ),
    );
  }
}
