import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/util/quit_dialogue_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => displayQuitDialogue(context),
      child: Scaffold(
        appBar: authenticationAppBarWidget(),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              welcomeButton(context,
                  onPress: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.studentLogin),
                  iconData: Icons.person,
                  label: 'STUDENT'),
              welcomeButton(context,
                  onPress: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.teacherLogin),
                  iconData: Icons.people,
                  label: 'TEACHER'),
              welcomeButton(context,
                  onPress: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.adminLogin),
                  iconData: Icons.book,
                  label: 'ADMIN')
            ],
          ),
        ),
      ),
    );
  }
}
