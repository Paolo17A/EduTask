import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/url_util.dart';

class SelectedLessonScreen extends StatefulWidget {
  final String lessonID;
  const SelectedLessonScreen({super.key, required this.lessonID});

  @override
  State<SelectedLessonScreen> createState() => _SelectedLessonScreenState();
}

class _SelectedLessonScreenState extends State<SelectedLessonScreen> {
  bool _isLoading = true;

  String title = '';
  String content = '';
  List<dynamic> additionalResources = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getLessonData();
  }

  void getLessonData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final lesson = await FirebaseFirestore.instance
          .collection('lessons')
          .doc(widget.lessonID)
          .get();
      final lessonData = lesson.data() as Map<dynamic, dynamic>;
      title = lessonData['title'];
      content = lessonData['content'];
      additionalResources = lessonData['additionalResources'];
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting lesson data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      body: switchedLoadingContainer(
          _isLoading,
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: all20Pix(
                child: Column(
                  children: [
                    _title(),
                    Gap(20),
                    _content(),
                    if (additionalResources.isNotEmpty) _additionalResources()
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _title() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: interText(title,
            fontWeight: FontWeight.bold,
            fontSize: 30,
            textAlign: TextAlign.center));
  }

  Widget _content() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(border: Border.all()),
      padding: EdgeInsets.all(10),
      child: interText(content, fontSize: 18),
    );
  }

  Widget _additionalResources() {
    return vertical10horizontal4(
      SizedBox(
        height: 50,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
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
                          shape: RoundedRectangleBorder()),
                      child: interText(externalResource['fileName'],
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)));
            }),
      ),
    );
  }
}
