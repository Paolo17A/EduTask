import 'package:edutask/providers/current_user_type_provider.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/util/quit_dialogue_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(currentUserTypeProvider.notifier).setCurrentUserType('');
  }

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
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Gap(10),
              Image.asset('assets/images/central_elem_logo.png'),
              interText('Please select your user type...',
                  fontWeight: FontWeight.bold, fontSize: 18),
              Gap(10),
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
