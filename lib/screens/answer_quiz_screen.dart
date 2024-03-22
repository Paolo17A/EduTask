// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/util/quit_dialogue_util.dart';
import 'package:edutask/util/string_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:edutask/widgets/edutask_text_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../util/color_util.dart';
import '../widgets/answer_button.dart';
import '../widgets/bool_answer_button.dart';

class AnswerQuizScreen extends StatefulWidget {
  final String quizID;
  const AnswerQuizScreen({super.key, required this.quizID});

  @override
  State<AnswerQuizScreen> createState() => _AnswerQuizScreenState();
}

class _AnswerQuizScreenState extends State<AnswerQuizScreen> {
  bool _isLoading = true;

  //  DISPLAYS
  String title = '';
  List<dynamic> quizQuestions = [];
  List<dynamic> selectedAnswers = [];
  String subject = '';
  String quizType = QuizTypes.multipleChoice;

  //  CORRECT ANSWER VARIABLES
  Map<String, dynamic>? easyOptions;
  int currentQuestionIndex = 0;
  final TextEditingController _identificationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getQuizData();
    });
  }

  void getQuizData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final quiz = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizID)
          .get();
      final quizData = quiz.data() as Map<dynamic, dynamic>;
      title = quizData['title'];
      quizQuestions = jsonDecode(quizData['quizContent']);
      selectedAnswers = List.generate(quizQuestions.length, (index) => null);
      subject = quizData['subject'];
      quizType = quizData['quizType'];

      if (quizType == QuizTypes.multipleChoice) {
        easyOptions = quizQuestions[currentQuestionIndex]['options'];
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting quiz data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _checkIfSelected(dynamic selectedAnswer) {
    bool selectedValue = false;

    setState(() {
      if (selectedAnswers[currentQuestionIndex] != null &&
          selectedAnswers[currentQuestionIndex] == selectedAnswer) {
        selectedValue = true;
      }
    });
    return selectedValue;
  }

  void _previousQuestion() {
    if (currentQuestionIndex == 0) {
      return;
    }
    currentQuestionIndex--;
    setState(() {
      _updateOptions();
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex == quizQuestions.length - 1) {
      if (quizType == QuizTypes.identification) {
        _answerHardQuestion();
      }
      //  Check if all items have been answered
      for (int i = 0; i < selectedAnswers.length; i++) {
        if (selectedAnswers[i] == null) {
          setState(() {
            currentQuestionIndex = i;
            _updateOptions();
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('You have not yet answered question # ${i + 1}')));
          return;
        }
      }
      _submitQuizAnswers();
      return;
    }
    if (quizType == QuizTypes.identification) {
      _answerHardQuestion();
    }
    currentQuestionIndex++;
    setState(() {
      _updateOptions();
    });
  }

  void _answerQuestion(String selectedAnswer) {
    setState(() {
      _processIfAnswerAlreadySelected(selectedAnswer);
    });
  }

  void _answerMediumQuestion(bool selectedAnswer) {
    setState(() {
      _processIfAnswerAlreadySelected(selectedAnswer);
    });
  }

  void _answerHardQuestion() {
    FocusScope.of(context).unfocus();
    if (_identificationController.text.isEmpty) {
      selectedAnswers[currentQuestionIndex] = null;
    } else {
      selectedAnswers[currentQuestionIndex] = _identificationController.text;
    }
  }

  void _processIfAnswerAlreadySelected(dynamic selectedAnswer) {
    if (selectedAnswers[currentQuestionIndex] != null &&
        selectedAnswers[currentQuestionIndex] == selectedAnswer) {
      selectedAnswers[currentQuestionIndex] = null;
    } else {
      selectedAnswers[currentQuestionIndex] = selectedAnswer;
    }
  }

  void _updateOptions() {
    easyOptions = quizQuestions[currentQuestionIndex]['options'];
    if (quizType == QuizTypes.identification) {
      if (selectedAnswers[currentQuestionIndex] == null) {
        _identificationController.clear();
      } else {
        _identificationController.text =
            selectedAnswers[currentQuestionIndex].toString();
      }
    }
  }

  void _submitQuizAnswers() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    //final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      String quizResultID = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance
          .collection('quizResults')
          .doc(quizResultID)
          .set({
        'studentID': FirebaseAuth.instance.currentUser!.uid,
        'quizID': widget.quizID,
        'subject': subject,
        "answers": selectedAnswers,
        "grade": countCorrectAnswers(),
      });

      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully submitted this quiz.')));
      NavigatorRoutes.selectedQuizResult(context,
          quizResultID: quizResultID, isReplacing: true);
      // navigator.pop();
      // navigator.pushReplacementNamed(NavigatorRoutes.studentSubmittables);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error submitting quiz answers: $error')));
    }
  }

  int countCorrectAnswers() {
    int numCorrect = 0;
    for (int i = 0; i < quizQuestions.length; i++) {
      if (quizType == QuizTypes.multipleChoice ||
          quizType == QuizTypes.trueOrFalse) {
        if (quizQuestions[i]['answer'] == selectedAnswers[i]) {
          numCorrect++;
        }
      } else {
        if (quizQuestions[i]['answer'].toString().toLowerCase() ==
            selectedAnswers[i].toString().toLowerCase()) {
          numCorrect++;
        }
      }
    }
    return numCorrect;
  }

  //  BUILD WIDGETS
  //============================================================================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () async => displayExitDialogue(context),
        child: Scaffold(
          appBar: homeAppBarWidget(context, mayGoBack: true),
          body: switchedLoadingContainer(
              _isLoading,
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: all20Pix(
                      child: Column(
                    children: [
                      _quizTitle(),
                      if (!_isLoading) _quizQuestionWidgets(),
                      _bottomNavigatorButtons()
                    ],
                  )),
                ),
              )),
        ),
      ),
    );
  }

  Widget _quizTitle() {
    return vertical20Pix(
      child: interText(title,
          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _quizQuestionWidgets() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: CustomColors.verySoftOrange,
          borderRadius: BorderRadius.circular(30)),
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          _questionContainer(
              '${currentQuestionIndex + 1}. ${quizQuestions[currentQuestionIndex]['question']}'),
          if (quizType == QuizTypes.multipleChoice)
            ...easyOptions!.entries.map((option) {
              return AnswerButton(
                letter: option.key,
                answer: '${option.key}) ${option.value}',
                onTap: () => _answerQuestion(option.key),
                isSelected: _checkIfSelected(option.key),
              );
            }).toList()
          else if (quizType == QuizTypes.trueOrFalse)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BoolAnswerButton(
                  boolVal: true,
                  answer: 'True',
                  onTap: () => _answerMediumQuestion(true),
                  isSelected: _checkIfSelected(true),
                ),
                const SizedBox(width: 25),
                BoolAnswerButton(
                  boolVal: false,
                  answer: 'False',
                  onTap: () => _answerMediumQuestion(false),
                  isSelected: _checkIfSelected(false),
                ),
              ],
            )
          else if (quizType == QuizTypes.identification)
            EduTaskTextField(
                text: 'Answer',
                controller: _identificationController,
                textInputType: TextInputType.text,
                displayPrefixIcon: null)
        ],
      ),
    );
  }

  Widget _questionContainer(String question) {
    return vertical10horizontal4(
      Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: interText(question, color: Colors.black, fontSize: 20))
        ],
      ),
    );
  }

  Widget _bottomNavigatorButtons() {
    return vertical10horizontal4(
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ovalButton('< PREV',
                  onPress: _previousQuestion,
                  backgroundColor: CustomColors.softOrange,
                  color: Colors.white),
              ovalButton('NEXT >',
                  onPress: _nextQuestion,
                  backgroundColor: CustomColors.softOrange,
                  color: Colors.white)
            ],
          ),
        ],
      ),
    );
  }
}
