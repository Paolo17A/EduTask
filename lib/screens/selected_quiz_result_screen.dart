import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/string_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';

class SelectedQuizResultScreen extends StatefulWidget {
  final String quizResultID;
  const SelectedQuizResultScreen({super.key, required this.quizResultID});

  @override
  State<SelectedQuizResultScreen> createState() =>
      _SelectedQuizResultScreenState();
}

class _SelectedQuizResultScreenState extends State<SelectedQuizResultScreen> {
  bool _isLoading = true;
  //  QUIZ RESULTS
  num grade = 0;
  List<dynamic> userAnswers = [];
  String quizType = QuizTypes.multipleChoice;
  String quizTitle = '';
  List<dynamic> quizQuestions = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getThisQuizResult();
  }

  void getThisQuizResult() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      //  Get Quiz Result Data
      final quizResult = await FirebaseFirestore.instance
          .collection('quizResults')
          .doc(widget.quizResultID)
          .get();
      final quizResultData = quizResult.data() as Map<dynamic, dynamic>;
      grade = quizResultData['grade'];
      userAnswers = quizResultData['answers'];
      String quizID = quizResultData['quizID'];

      //  Get Quiz Data
      final quiz = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizID)
          .get();
      final quizData = quiz.data() as Map<dynamic, dynamic>;
      quizTitle = quizData['title'];
      final quizContent = quizData['quizContent'];
      quizType = quizData['quizType'];
      quizQuestions = jsonDecode(quizContent);

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting this quiz result: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context,
          backgroundColor: CustomColors.verySoftOrange, mayGoBack: true),
      body: switchedLoadingContainer(
          _isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
              children: [_quizTitle(), _quizScore(), _questionsAndAnswers()],
            )),
          )),
    );
  }

  Widget _quizTitle() {
    return vertical20Pix(
        child: interText(quizTitle,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            textAlign: TextAlign.center));
  }

  Widget _quizScore() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: CustomColors.verySoftOrange,
          borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.all(15),
      child: interText(
          'You got ${grade.toString()} out of ${quizQuestions.length.toString()} items correct.',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          textAlign: TextAlign.center),
    );
  }

  Widget _questionsAndAnswers() {
    return vertical20Pix(
      child: Container(
        decoration: BoxDecoration(
            color: CustomColors.verySoftOrange,
            borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.all(15),
        child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: quizQuestions.length,
            itemBuilder: (context, index) {
              String formattedQuestion =
                  '${index + 1}. ${(quizQuestions[index]['question'].toString())}';

              String yourAnswer = '';
              String correctAnswer = '';
              bool isCorrect = userAnswers[index].toString().toLowerCase() ==
                  quizQuestions[index]['answer'].toString().toLowerCase();
              if (quizType == QuizTypes.multipleChoice) {
                yourAnswer =
                    'Your Answer: ${userAnswers[index]}) ${quizQuestions[index]['options'][userAnswers[index]]}';
                correctAnswer =
                    'Correct Answer: ${quizQuestions[index]['answer']}) ${quizQuestions[index]['options'][quizQuestions[index]['answer']]}';
              } else {
                yourAnswer = 'Your Answer: ${userAnswers[index]}';
                correctAnswer =
                    'Correct Answer: ${quizQuestions[index]['answer']}';
              }

              return vertical10horizontal4(
                Container(
                  decoration: BoxDecoration(
                      color: CustomColors.softOrange,
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      interText(formattedQuestion),
                      Gap(7),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            interText(yourAnswer,
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold),
                            if (!isCorrect)
                              interText(correctAnswer,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
