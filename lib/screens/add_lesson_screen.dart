import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/selected_subject_provider.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../util/string_util.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/edutask_text_field_widget.dart';

class AddLessonScreen extends ConsumerStatefulWidget {
  const AddLessonScreen({super.key});

  @override
  ConsumerState<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends ConsumerState<AddLessonScreen> {
  bool _isLoading = false;

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final List<File?> _documentFiles = [];
  final List<TextEditingController> _fileNameControllers = [];
  final List<TextEditingController> _downloadLinkControllers = [];
  int selectedQuarter = 1;

  void addNewLesson() async {
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

      String lessonID = DateTime.now().millisecondsSinceEpoch.toString();

      List<Map<dynamic, dynamic>> additionalResources = [];
      for (int i = 0; i < _downloadLinkControllers.length; i++) {
        additionalResources.add({
          'fileName': _fileNameControllers[i].text.trim(),
          'downloadLink': _downloadLinkControllers[i].text.trim()
        });
      }

      //  Handle Portfolio Entries
      List<Map<String, String>> documentEntries = [];
      for (var docFile in _documentFiles) {
        String hex =
            '${generateRandomHexString(6)}.${docFile!.path.split('.').last}';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('lessons')
            .child(lessonID)
            .child(hex);
        final uploadTask = storageRef.putFile(docFile);
        final taskSnapshot = await uploadTask.whenComplete(() {});
        final String downloadURL = await taskSnapshot.ref.getDownloadURL();
        documentEntries.add({
          'id': hex,
          'fileName': docFile.path.split('/').last,
          'docURL': downloadURL
        });
      }

      //  1. Create Lesson Document and indicate it's associated sections
      await FirebaseFirestore.instance.collection('lessons').doc(lessonID).set({
        'teacherID': FirebaseAuth.instance.currentUser!.uid,
        'subject': ref.read(selectedSubjectProvider),
        'title': titleController.text,
        'content': contentController.text,
        'additionalResources': additionalResources,
        'additionalDocuments': documentEntries,
        'associatedSections': [],
        'dateLastModified': DateTime.now(),
        'quarter': selectedQuarter
      });

      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully added new lesson.')));
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

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc'],
        allowMultiple: false);

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _documentFiles.add(file);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: homeAppBarWidget(context, mayGoBack: true),
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
                  _quarterDropdown(),
                  _additionalDocuments(),
                  _additionalResources(),
                  ovalButton('CREATE LESSON',
                      onPress: addNewLesson,
                      backgroundColor: CustomColors.softOrange)
                ],
              )),
            )),
      ),
    );
  }

  Widget newLessonHeader() {
    return interText('NEW ${ref.read(selectedSubjectProvider)} LESSON',
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

  Widget _quarterDropdown() {
    return vertical10horizontal4(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Quarter', fontSize: 18),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10)),
          child: dropdownWidget('QUARTER', (number) {
            setState(() {
              selectedQuarter = int.parse(number!);
            });
          }, ['1', '2', '3', '4'], selectedQuarter.toString(), false),
        ),
      ],
    ));
  }

  Widget _additionalDocuments() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              interText('Additional Documents', fontWeight: FontWeight.bold),
              ElevatedButton(
                onPressed: _pickDocument,
                style: ElevatedButton.styleFrom(shape: CircleBorder()),
                child: interText('+',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20),
              )
            ],
          ),
          if (_documentFiles.isNotEmpty)
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _documentFiles.length,
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
                            interText(
                                _documentFiles[index]!.path.split('/').last),
                          ]),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _documentFiles.removeAt(index);
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
