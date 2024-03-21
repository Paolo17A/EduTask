import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/selected_subject_provider.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:edutask/widgets/edutask_text_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../widgets/dropdown_widget.dart';
import '../widgets/string_choices_radio_widget.dart';

class AddQuizScreen extends ConsumerStatefulWidget {
  const AddQuizScreen({super.key});

  @override
  ConsumerState<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends ConsumerState<AddQuizScreen> {
  bool _isLoading = false;

  int currentQuestion = 0;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  int selectedQuarter = 1;
  final List<TextEditingController> _choicesControllers = [];
  final List<String> choiceLetters = ['a', 'b', 'c', 'd'];
  String? _correctChoiceString;
  final GlobalKey<ChoicesRadioWidgetState> stringChoice = GlobalKey();
  List<dynamic> quizQuestions = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      _choicesControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _questionController.dispose();
    for (var choice in _choicesControllers) {
      choice.dispose();
    }
  }

  void previousQuestion() {
    if (currentQuestion == 0) {
      return;
    }
    setState(() {
      currentQuestion--;

      _questionController.text = quizQuestions[currentQuestion]['question'];
      _choicesControllers[0].text =
          quizQuestions[currentQuestion]['options']['a'];
      _choicesControllers[1].text =
          quizQuestions[currentQuestion]['options']['b'];
      _choicesControllers[2].text =
          quizQuestions[currentQuestion]['options']['c'];
      _choicesControllers[3].text =
          quizQuestions[currentQuestion]['options']['d'];
      _correctChoiceString = quizQuestions[currentQuestion]['answer'];
      stringChoice.currentState?.setChoice(_correctChoiceString!);
    });
  }

  void nextQuestion() {
    //  VALIDATION GUARDS
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please provide a title for this quiz.')));
      return;
    }
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide a question.')));
      return;
    }
    if (_correctChoiceString == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Please select a correct answer from the four choices.')));
      return;
    }
    for (int i = 0; i < _choicesControllers.length; i++) {
      if (_choicesControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please provide four choices to choose from.')));
        return;
      }
    }

    //  Create a custom map for this object

    Map<String, dynamic> easyQuestionEntry = {
      'question': _questionController.text.trim(),
      'options': {
        'a': _choicesControllers[0].text.trim(),
        'b': _choicesControllers[1].text.trim(),
        'c': _choicesControllers[2].text.trim(),
        'd': _choicesControllers[3].text.trim()
      },
      'answer': _correctChoiceString
    };
    if (currentQuestion == quizQuestions.length) {
      quizQuestions.add(easyQuestionEntry);
    } else {
      quizQuestions[currentQuestion] = easyQuestionEntry;
    }

    setState(() {
      currentQuestion++;
      if (currentQuestion == 10) {
        //currentQuestion--;
        addNewQuiz();
        return;
      }
      if (currentQuestion <= quizQuestions.length - 1) {
        Map<dynamic, dynamic> selectedQuestion = quizQuestions[currentQuestion];
        _questionController.text = selectedQuestion['question'];
        for (int i = 0; i < _choicesControllers.length; i++) {
          _choicesControllers[i].text =
              selectedQuestion['options'][choiceLetters[i]];
        }
        _correctChoiceString = selectedQuestion['answer'];
        stringChoice.currentState?.setChoice(_correctChoiceString!);
      } else {
        _questionController.clear();

        for (TextEditingController choice in _choicesControllers) {
          choice.clear();
        }
        _correctChoiceString = null;
        stringChoice.currentState?.resetChoice();
      }
    });
  }

  void addNewQuiz() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final customLessons =
          await FirebaseFirestore.instance.collection('quizzes').get();
      final existingLesson = customLessons.docs.where((lesson) {
        final lessonData = lesson.data();
        String title = lessonData['title'];
        return title == _titleController.text.trim();
      });
      if (existingLesson.isNotEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('A quiz with this title already exists')));
        setState(() {
          _isLoading = false;
        });
        return;
      }
      String encodedQuiz = jsonEncode(quizQuestions);

      String quizID = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance.collection('quizzes').doc(quizID).set({
        'teacherID': FirebaseAuth.instance.currentUser!.uid,
        'subject': ref.read(selectedSubjectProvider),
        'title': _titleController.text.trim(),
        'quizContent': encodedQuiz,
        'associatedSections': [],
        'dateLastModified': DateTime.now(),
        'quarter': selectedQuarter
      });

      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Successfully added new quiz')));
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.lessonPlan);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error adding new quiz: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  //  BUILD WIDGETS
  //============================================================================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: homeAppBarWidget(context),
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  _quizTitle(),
                  _quizInputContainer(),
                  _quarterDropdown()
                ],
              )),
            )),
      ),
    );
  }

  Widget _quizTitle() {
    return vertical10horizontal4(
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${ref.read(selectedSubjectProvider)} QUIZ TITLE',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        EduTaskTextField(
            text: 'Quiz Title',
            controller: _titleController,
            textInputType: TextInputType.text,
            displayPrefixIcon: null),
      ]),
    );
  }

  Widget _quizInputContainer() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.9),
          border: Border.all(),
          borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            interText('Question #${currentQuestion + 1}',
                fontWeight: FontWeight.bold)
          ]),
          Gap(5),
          EduTaskTextField(
              text: 'Question',
              controller: _questionController,
              textInputType: TextInputType.text,
              displayPrefixIcon: null),
          const SizedBox(height: 15),
          _easyQuestionInput(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ElevatedButton(
                onPressed: previousQuestion,
                child: interText('PREVIOUS', fontWeight: FontWeight.bold)),
            ElevatedButton(
                onPressed: nextQuestion,
                child: interText(currentQuestion == 9 ? 'SUBMIT' : 'NEXT',
                    fontWeight: FontWeight.bold))
          ])
        ],
      ),
    );
  }

  Widget _easyQuestionInput() {
    return Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _choicesControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      interText(choiceLetters[index],
                          fontWeight: FontWeight.bold),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: EduTaskTextField(
                            text: 'Choice',
                            controller: _choicesControllers[index],
                            textInputType: TextInputType.text,
                            displayPrefixIcon: null),
                      )
                    ]),
              );
            }),
        vertical20Pix(
          child: StringChoicesRadioWidget(
              key: stringChoice,
              initialString: _correctChoiceString,
              choiceSelectCallback: (stringVal) {
                if (stringVal != null) {
                  setState(() {
                    _correctChoiceString = stringVal;
                  });
                }
              },
              choiceLetters: choiceLetters),
        ),
      ],
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
}
