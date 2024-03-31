import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/string_util.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';
import '../widgets/app_bar_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class AdminSelectedQuizScreen extends StatefulWidget {
  final DocumentSnapshot quizDoc;
  const AdminSelectedQuizScreen({super.key, required this.quizDoc});

  @override
  State<AdminSelectedQuizScreen> createState() =>
      _AdminSelectedQuizScreenState();
}

class _AdminSelectedQuizScreenState extends State<AdminSelectedQuizScreen> {
  String quizTitle = '';
  String subject = '';
  String teacherID = '';
  List<dynamic> associatedSections = [];
  List<dynamic> quizQuestions = [];
  int quarter = 0;
  String quizType = QuizTypes.multipleChoice;

  @override
  void initState() {
    super.initState();
    final quizData = widget.quizDoc.data() as Map<dynamic, dynamic>;
    quizTitle = quizData['title'];
    subject = quizData['subject'];
    teacherID = quizData['teacherID'];
    associatedSections = quizData['associatedSections'];
    final quizContent = quizData['quizContent'];
    quizQuestions = jsonDecode(quizContent);
    quarter = quizData['quarter'];
    quizType = quizData['quizType'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBarWidget(context, mayGoBack: true),
      bottomNavigationBar: adminBottomNavBar(context, index: 2),
      body: SingleChildScrollView(
        child: all20Pix(
            child: Column(
          children: [
            _basicQuizData(),
            assignedSections(associatedSections),
            _questionsAndAnswers()
          ],
        )),
      ),
    );
  }

  Widget _basicQuizData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText(quizTitle,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            textAlign: TextAlign.center),
        Gap(12),
        interText('Subject: $subject', fontSize: 20),
        teacherName(teacherID),
        interText('Quarter: ${quarter.toString()}', fontSize: 18),
        Divider(thickness: 4)
      ],
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
              dynamic answer = quizQuestions[index]['answer'];
              return vertical10horizontal4(
                Container(
                  decoration: BoxDecoration(
                      color: CustomColors.softOrange,
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      _formattedQuestion(formattedQuestion),
                      if (quizType == QuizTypes.multipleChoice)
                        _multipleChoices(
                            quizQuestions[index]['options'], answer)
                      else if (quizType == QuizTypes.trueOrFalse)
                        _boolChoices(answer)
                      else if (quizType == QuizTypes.identification)
                        _identificationAnswer(answer)
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget _formattedQuestion(String formattedQuestion) {
    return Row(children: [
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: interText(formattedQuestion))
    ]);
  }

  Widget _multipleChoices(Map<String, dynamic> options, String answer) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          //runAlignment: WrapAlignment.spaceBetween,
          runSpacing: 20,
          children: options.entries
              .map((entry) => Container(
                  width: MediaQuery.of(context).size.width * 0.32,
                  height: 60,
                  decoration: BoxDecoration(
                      color: entry.key == answer
                          ? CustomColors.verySoftOrange
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(4),
                  child:
                      interText('${entry.key}) ${entry.value}', fontSize: 12)))
              .toList()),
    );
  }

  Widget _boolChoices(bool answer) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 30,
            decoration: BoxDecoration(
                color:
                    answer == true ? CustomColors.verySoftOrange : Colors.white,
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(4),
            child: interText('TRUE',
                fontSize: 15,
                fontWeight:
                    answer == true ? FontWeight.bold : FontWeight.normal),
          ),
          Gap(6),
          Container(
            width: double.infinity,
            height: 30,
            decoration: BoxDecoration(
                color: answer == false
                    ? CustomColors.verySoftOrange
                    : Colors.white,
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(4),
            child: interText('FALSE',
                fontSize: 15,
                fontWeight:
                    answer == false ? FontWeight.bold : FontWeight.normal),
          )
        ],
      ),
    );
  }

  Widget _identificationAnswer(String answer) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
          color: CustomColors.verySoftOrange,
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(4),
      child: interText(answer, fontSize: 15, fontWeight: FontWeight.w700),
    );
  }
}
