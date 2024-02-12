import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/color_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../util/url_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class AdminSelectedLessonScreen extends StatefulWidget {
  final DocumentSnapshot lessonDoc;
  const AdminSelectedLessonScreen({super.key, required this.lessonDoc});

  @override
  State<AdminSelectedLessonScreen> createState() =>
      _AdminSelectedLessonScreenState();
}

class _AdminSelectedLessonScreenState extends State<AdminSelectedLessonScreen> {
  String title = '';
  String subject = '';
  String teacherID = '';
  List<dynamic> associatedSections = [];
  String lessonContent = '';
  List<dynamic> additionalResources = [];

  @override
  void initState() {
    super.initState();
    final lessonData = widget.lessonDoc.data() as Map<dynamic, dynamic>;
    title = lessonData['title'];
    subject = lessonData['subject'];
    teacherID = lessonData['teacherID'];
    associatedSections = lessonData['associatedSections'];
    lessonContent = lessonData['content'];
    additionalResources = lessonData['additionalResources'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: all20Pix(
              child: Column(
            children: [
              _basicLessonData(),
              assignedSections(associatedSections),
              _lessonContent()
            ],
          )),
        ),
      ),
    );
  }

  Widget _basicLessonData() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      interText('Title: $title', fontWeight: FontWeight.bold, fontSize: 24),
      Gap(12),
      interText('Subject: $subject', fontSize: 20),
      teacherName(teacherID),
      Divider(thickness: 4),
    ]);
  }

  Widget _lessonContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Lesson Content', fontWeight: FontWeight.bold, fontSize: 20),
        _content(),
        if (additionalResources.isNotEmpty) _additionalResources(),
        Divider(thickness: 4)
      ],
    );
  }

  Widget _content() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(border: Border.all()),
      padding: EdgeInsets.all(10),
      child: interText(lessonContent, fontSize: 18),
    );
  }

  Widget _additionalResources() {
    return vertical10horizontal4(
      Column(
        children: [
          Row(children: [
            interText('Additional Resources:',
                fontWeight: FontWeight.bold, fontSize: 16)
          ]),
          SizedBox(
            height: 50,
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: additionalResources.length,
                itemBuilder: (context, index) {
                  Map<dynamic, dynamic> externalResource =
                      additionalResources[index] as Map<dynamic, dynamic>;
                  return SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: ElevatedButton(
                          onPressed: () async =>
                              launchThisURL(externalResource['downloadLink']),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(),
                              backgroundColor: CustomColors.softOrange),
                          child: interText(externalResource['fileName'],
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15)));
                }),
          ),
        ],
      ),
    );
  }
}
