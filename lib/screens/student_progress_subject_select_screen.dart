import 'package:edutask/util/color_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

class StudentProgressSubjectSelectScreen extends StatelessWidget {
  const StudentProgressSubjectSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          homeAppBarWidget(context, backgroundColor: CustomColors.softOrange),
      body: SingleChildScrollView(
        child: all20Pix(
            child: Column(
          children: [
            subjectButton(context, label: 'AP'),
            subjectButton(context, label: 'ENGLISH'),
            subjectButton(context, label: 'EPP'),
            subjectButton(context, label: 'ESP'),
            subjectButton(context, label: 'FILIPINO'),
            subjectButton(context, label: 'MAPEH'),
            subjectButton(context, label: 'MATHEMATICS'),
            subjectButton(context, label: 'SCIENCE')
          ],
        )),
      ),
    );
  }

  Widget subjectButton(BuildContext context, {required String label}) {
    return vertical10horizontal4(SizedBox(
      width: double.infinity,
      height: 175,
      child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.softOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: interText(label, fontWeight: FontWeight.bold, fontSize: 16)),
    ));
  }
}
