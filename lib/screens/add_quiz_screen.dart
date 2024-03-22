import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/selected_quiz_type_provider.dart';
import 'package:edutask/providers/selected_subject_provider.dart';
import 'package:edutask/util/color_util.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/util/string_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:edutask/widgets/edutask_text_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../widgets/bool_choices_radio_widget.dart';
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
  List<dynamic> quizQuestions = [];

  int selectedQuarter = 1;

  //  MULTIPLE CHOICE VARIABLES
  final List<TextEditingController> _choicesControllers = [];
  final List<String> choiceLetters = ['a', 'b', 'c', 'd'];
  String? _correctChoiceString;
  final GlobalKey<ChoicesRadioWidgetState> stringChoice = GlobalKey();

  //  TRUE OR FALSE VARIABLES
  bool? _correctChoiceBool;
  final GlobalKey<BoolChoicesRadioWidgetState> boolChoice = GlobalKey();

  //  IDENTIFICATION VARIABLES
  final TextEditingController _identificationController =
      TextEditingController();

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
    _identificationController.dispose();
  }

  void previousQuestion() {
    if (currentQuestion == 0) {
      return;
    }
    setState(() {
      currentQuestion--;
      _questionController.text = quizQuestions[currentQuestion]['question'];
      if (ref.read(selectedQuizTypeProvider) == QuizTypes.multipleChoice) {
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
      } else if (ref.read(selectedQuizTypeProvider) == QuizTypes.trueOrFalse) {
        _correctChoiceBool = quizQuestions[currentQuestion]['answer'];
        boolChoice.currentState?.setChoice(_correctChoiceBool!);
      } else if (ref.read(selectedQuizTypeProvider) ==
          QuizTypes.identification) {
        _identificationController.text =
            quizQuestions[currentQuestion]['answer'];
      }
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
    if (ref.read(selectedQuizTypeProvider) == QuizTypes.multipleChoice) {
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
    }
    if (ref.read(selectedQuizTypeProvider) == QuizTypes.trueOrFalse &&
        _correctChoiceBool == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select between True or False.')));
      return;
    } else if (ref.read(selectedQuizTypeProvider) == QuizTypes.identification &&
        _identificationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please input the correct answer.')));
      return;
    }

    //  Create a custom map for this object
    //  Create a multiple choice question map
    if (ref.read(selectedQuizTypeProvider) == QuizTypes.multipleChoice) {
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
    }
    //  Create a true or false question map
    else if (ref.read(selectedQuizTypeProvider) == QuizTypes.trueOrFalse) {
      Map<String, dynamic> averageQuestionEntry = {
        'question': _questionController.text.trim(),
        'answer': _correctChoiceBool
      };
      if (currentQuestion == quizQuestions.length) {
        quizQuestions.add(averageQuestionEntry);
      } else {
        quizQuestions[currentQuestion] = averageQuestionEntry;
      }
    }
    //  Create an identification question map
    else if (ref.read(selectedQuizTypeProvider) == QuizTypes.identification) {
      Map<String, dynamic> difficultQuestionEntry = {
        'question': _questionController.text.trim(),
        'answer': _identificationController.text.trim()
      };
      if (currentQuestion == quizQuestions.length) {
        quizQuestions.add(difficultQuestionEntry);
      } else {
        quizQuestions[currentQuestion] = difficultQuestionEntry;
      }
    }

    //  STORE THE INPUTTED DATA AND REBUILD THE WIDGET
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
        if (ref.read(selectedQuizTypeProvider) == QuizTypes.multipleChoice) {
          for (int i = 0; i < _choicesControllers.length; i++) {
            _choicesControllers[i].text =
                selectedQuestion['options'][choiceLetters[i]];
          }
          _correctChoiceString = selectedQuestion['answer'];
          stringChoice.currentState?.setChoice(_correctChoiceString!);
        } else if (ref.read(selectedQuizTypeProvider) ==
            QuizTypes.trueOrFalse) {
          _correctChoiceBool = selectedQuestion['answer'];
          boolChoice.currentState?.setChoice(_correctChoiceBool!);
        } else if (ref.read(selectedQuizTypeProvider) ==
            QuizTypes.identification) {
          _identificationController.text = selectedQuestion['answer'];
        }
      } else {
        _questionController.clear();
        if (ref.read(selectedQuizTypeProvider) == QuizTypes.multipleChoice) {
          for (TextEditingController choice in _choicesControllers) {
            choice.clear();
          }
          _correctChoiceString = null;
          stringChoice.currentState?.resetChoice();
        } else if (ref.read(selectedQuizTypeProvider) ==
            QuizTypes.trueOrFalse) {
          _correctChoiceBool = null;
          boolChoice.currentState?.resetChoice();
        } else if (ref.read(selectedQuizTypeProvider) ==
            QuizTypes.identification) {
          _identificationController.clear();
        }
      }
    });
  }

  void addNewQuiz() async {
    FocusScope.of(context).unfocus();
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
        'quizType': ref.read(selectedQuizTypeProvider),
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
          color: CustomColors.verySoftOrange,
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
          if (ref.read(selectedQuizTypeProvider) == QuizTypes.multipleChoice)
            _multipleChoiceQuestionInput()
          else if (ref.read(selectedQuizTypeProvider) == QuizTypes.trueOrFalse)
            _trueOrFalseQuestionInput()
          else if (ref.read(selectedQuizTypeProvider) ==
              QuizTypes.identification)
            _identificationQuestionInput(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ovalButton('PREVIOUS',
                onPress: previousQuestion,
                backgroundColor: CustomColors.softOrange),
            ovalButton(currentQuestion == 9 ? 'SUBMIT' : 'NEXT',
                onPress: nextQuestion, backgroundColor: CustomColors.softOrange)
          ])
        ],
      ),
    );
  }

  Widget _multipleChoiceQuestionInput() {
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

  Widget _trueOrFalseQuestionInput() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: BoolChoicesRadioWidget(
            key: boolChoice,
            initialBool: _correctChoiceBool,
            choiceSelectCallback: (boolVal) {
              if (boolVal != null) {
                setState(() {
                  _correctChoiceBool = boolVal;
                });
              }
            }));
  }

  Widget _identificationQuestionInput() {
    return vertical20Pix(
      child: EduTaskTextField(
          text: 'Correct Answer',
          controller: _identificationController,
          textInputType: TextInputType.text,
          displayPrefixIcon: null),
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
