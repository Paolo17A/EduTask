import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/edutask_text_field_widget.dart';

class EditLessonScreen extends StatefulWidget {
  final String lessonID;
  const EditLessonScreen({super.key, required this.lessonID});

  @override
  State<EditLessonScreen> createState() => _EditLessonScreenState();
}

class _EditLessonScreenState extends State<EditLessonScreen> {
  bool _isLoading = false;
  bool _isInitialized = false;

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  List<dynamic> additionalResources = [];
  final List<TextEditingController> _fileNameControllers = [];
  final List<TextEditingController> _downloadLinkControllers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) _getLessonData();
  }

  Future _getLessonData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final lesson = await FirebaseFirestore.instance
          .collection('lessons')
          .doc(widget.lessonID)
          .get();
      final lessonData = lesson.data()!;
      titleController.text = lessonData['title'];
      contentController.text = lessonData['content'];

      //  Retrieve and handle additional resources
      additionalResources = lessonData['additionalResources'];
      for (int i = 0; i < additionalResources.length; i++) {
        Map<dynamic, dynamic> resourceEntry = additionalResources[i];
        _fileNameControllers.add(TextEditingController());
        _fileNameControllers[i].text = resourceEntry['fileName'];
        _downloadLinkControllers.add(TextEditingController());
        _downloadLinkControllers[i].text = resourceEntry['downloadLink'];
      }

      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting lesson data: $error')));
    }
  }

  void editLesson() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content:
              Text('Please provide a title and content for this lesson.')));
      return;
    }
    for (int i = 0; i < _downloadLinkControllers.length; i++) {
      if (_fileNameControllers[i].text.isEmpty ||
          _downloadLinkControllers[i].text.isEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text(
                'Please fill up all additional resource fields or delete unused ones.')));
        return;
      } else if (!Uri.tryParse(_downloadLinkControllers[i].text.trim())!
          .hasAbsolutePath) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content:
                Text('The URL provided in resource #${i + 1} is invalid')));
        return;
      }
    }
    try {
      setState(() {
        _isLoading = true;
      });

      List<Map<dynamic, dynamic>> additionalResources = [];
      for (int i = 0; i < _downloadLinkControllers.length; i++) {
        additionalResources.add({
          'fileName': _fileNameControllers[i].text.trim(),
          'downloadLink': _downloadLinkControllers[i].text.trim()
        });
      }

      //  1. Create Lesson Document and indicate it's associated sections
      await FirebaseFirestore.instance
          .collection('lessons')
          .doc(widget.lessonID)
          .update({
        'title': titleController.text,
        'content': contentController.text,
        'teacherID': FirebaseAuth.instance.currentUser!.uid,
        'additionalResources': additionalResources,
      });

      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully edited this lesson.')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.lessonPlan);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error adding new lesson: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: homeAppBarWidget(context,
            backgroundColor: CustomColors.lightGreyishLimeGreen,
            mayGoBack: true),
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  newLessonHeader(),
                  Gap(30),
                  _lessonTitle(),
                  _lessonContent(),
                  _additionalResources(),
                  ovalButton('EDIT LESSON',
                      onPress: editLesson,
                      backgroundColor: CustomColors.softLimeGreen)
                ],
              )),
            )),
      ),
    );
  }

  Widget newLessonHeader() {
    return interText('NEW LESSON',
        fontSize: 40, textAlign: TextAlign.center, color: Colors.black);
  }

  Widget _lessonTitle() {
    return vertical10horizontal4(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Lesson Title', fontSize: 18),
          EduTaskTextField(
              text: 'Lesson Title',
              controller: titleController,
              textInputType: TextInputType.text,
              displayPrefixIcon: null),
        ],
      ),
    );
  }

  Widget _lessonContent() {
    return vertical10horizontal4(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Lesson Content', fontSize: 18),
          EduTaskTextField(
              text: 'Lesson Content',
              controller: contentController,
              textInputType: TextInputType.multiline,
              displayPrefixIcon: null),
        ],
      ),
    );
  }

  Widget _additionalResources() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              interText('Additional Resources', fontWeight: FontWeight.bold),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _fileNameControllers.add(TextEditingController());
                    _downloadLinkControllers.add(TextEditingController());
                  });
                },
                style: ElevatedButton.styleFrom(shape: CircleBorder()),
                child: interText('+',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20),
              )
            ],
          ),
          if (_downloadLinkControllers.isNotEmpty)
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _downloadLinkControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(children: [
                            Row(
                              children: [
                                Text('Resource # ${index + 1}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w300)),
                              ],
                            ),
                            EduTaskTextField(
                                text: 'Name',
                                controller: _fileNameControllers[index],
                                textInputType: TextInputType.text,
                                displayPrefixIcon: null),
                            const SizedBox(height: 10),
                            EduTaskTextField(
                                text: 'URL',
                                controller: _downloadLinkControllers[index],
                                textInputType: TextInputType.url,
                                displayPrefixIcon: null),
                          ]),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _fileNameControllers.removeAt(index);
                              _downloadLinkControllers.removeAt(index);
                            });
                          },
                          style:
                              ElevatedButton.styleFrom(shape: CircleBorder()),
                          child: const Icon(Icons.delete_rounded,
                              color: Colors.black),
                        )
                      ],
                    ),
                  );
                }),
        ],
      ),
    );
  }
}
