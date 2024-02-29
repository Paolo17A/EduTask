import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/color_util.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../util/future_util.dart';
import 'custom_text_widgets.dart';

Widget authenticationIcon(BuildContext context, {required IconData iconData}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      height: 150,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: CustomColors.veryLightGrey),
      child: Transform.scale(
          scale: 5, child: Icon(iconData, color: Colors.black)));
}

Widget logInBottomRow(BuildContext context, {required Function onRegister}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: interText('< Back', fontSize: 15)),
      TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(NavigatorRoutes.resetPassword),
          child: interText('Forgot Password?', fontSize: 15)),
      TextButton(
          onPressed: () => onRegister(),
          child: interText('Register', fontSize: 15))
    ],
  );
}

Widget buildProfileImageWidget(
    {required String profileImageURL, double radius = 40}) {
  return Column(children: [
    profileImageURL.isNotEmpty
        ? CircleAvatar(
            radius: radius, backgroundImage: NetworkImage(profileImageURL))
        : CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey,
            child: Icon(
              Icons.person,
              size: radius * 1.5,
              color: Colors.black,
            )),
  ]);
}

Widget welcomeWidgets(
    {required String userType,
    required String profileImageURL,
    required containerColor}) {
  return SizedBox(
    width: double.infinity,
    child: Column(
      children: [
        all10Pix(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            interText('WELCOME,\n$userType', fontSize: 30),
            buildProfileImageWidget(profileImageURL: profileImageURL)
          ]),
        ),
        Container(height: 15, color: containerColor)
      ],
    ),
  );
}

Widget userRecordEntry(
    {required DocumentSnapshot userDoc,
    required Color color,
    required Function onTap}) {
  final userData = userDoc.data() as Map<dynamic, dynamic>;
  String formattedName = '${userData['firstName']} ${userData['lastName']}';
  String profileImageURL = userData['profileImageURL'];
  return GestureDetector(
    onTap: () => onTap(),
    child: Container(
      color: color,
      height: 50,
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        buildProfileImageWidget(profileImageURL: profileImageURL, radius: 15),
        const Gap(16),
        interText(formattedName, fontSize: 16)
      ]),
    ),
  );
}

Widget sectionTeacherContainer(BuildContext context,
    {required String subjectLabel, required String formattedName}) {
  return vertical10horizontal4(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText(subjectLabel),
        Container(
            width: MediaQuery.of(context).size.width * 0.4,
            color: CustomColors.softOrange.withOpacity(0.75),
            padding: EdgeInsets.all(10),
            child: Center(
              child: Row(children: [
                interText(formattedName.isNotEmpty ? formattedName : 'N/A',
                    fontSize: 12)
              ]),
            ))
      ],
    ),
  );
}

Widget teacherMaterialEntry(BuildContext context,
    {required DocumentSnapshot materialDoc,
    required Function onEdit,
    required Function onDelete}) {
  final materialData = materialDoc.data() as Map<dynamic, dynamic>;
  String title = materialData['title'];
  String subject = materialData['subject'];
  return vertical10horizontal4(Container(
    decoration: BoxDecoration(
      color: Colors.grey,
      border: Border.all(),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.all(10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              interText(title, fontSize: 15),
              interText(subject, fontSize: 13)
            ],
          )),
      Row(
        children: [
          IconButton(
              onPressed: () => onEdit(),
              icon: Icon(
                Icons.edit,
                color: Colors.black,
              )),
          IconButton(
              onPressed: () => onDelete(),
              icon: Icon(
                Icons.delete,
                color: Colors.black,
              )),
        ],
      )
    ]),
  ));
}

Widget adminMaterialEntry(BuildContext context,
    {required DocumentSnapshot materialDoc,
    required Color color,
    required Function onView,
    required Function onDelete}) {
  final materialData = materialDoc.data() as Map<dynamic, dynamic>;
  String title = materialData['title'];
  return vertical10horizontal4(Container(
    decoration: BoxDecoration(
      color: color,
      border: Border.all(),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.all(10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: interText(title, fontSize: 15)),
      Row(
        children: [
          IconButton(
              onPressed: () => onView(),
              icon: Icon(
                Icons.visibility,
                color: Colors.black,
              )),
          IconButton(
              onPressed: () => onDelete(),
              icon: Icon(
                Icons.delete,
                color: Colors.black,
              )),
        ],
      )
    ]),
  ));
}

Widget sectionMaterialEntry(BuildContext context,
    {required DocumentSnapshot materialDoc, required Function onRemove}) {
  final materialData = materialDoc.data() as Map<dynamic, dynamic>;
  String title = materialData['title'];
  return vertical10horizontal4(Container(
    decoration: BoxDecoration(
      color: CustomColors.softOrange,
      border: Border.all(),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.all(10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: interText(title, fontSize: 15)),
      ovalButton('REMOVE',
          onPress: () => onRemove(),
          backgroundColor: CustomColors.verySoftOrange)
    ]),
  ));
}

Widget studentEntry(BuildContext context,
    {required DocumentSnapshot studentDoc,
    required Function onPress,
    Color backgroundColor = CustomColors.softOrange}) {
  final studentData = studentDoc.data() as Map<dynamic, dynamic>;
  String profileImageURL = studentData['profileImageURL'];
  String formattedName =
      '${studentData['firstName']} ${studentData['lastName']}';
  return vertical10horizontal4(InkWell(
    onTap: () => onPress(),
    child: Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(10),
      child: Row(children: [
        buildProfileImageWidget(profileImageURL: profileImageURL, radius: 20),
        Gap(20),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,
            child: interText(formattedName, fontSize: 15)),
      ]),
    ),
  ));
}

Widget teacherName(String teacherID) {
  return FutureBuilder(
      future: getUserName(teacherID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return interText('-');
        } else {
          return interText('Created By: ${snapshot.data}', fontSize: 20);
        }
      });
}

Widget studentName(String studentID) {
  return FutureBuilder(
      future: getUserName(studentID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return interText('-');
        } else {
          return interText('Submitted By: ${snapshot.data}', fontSize: 20);
        }
      });
}

Widget assignmentName(String assignmentID) {
  return FutureBuilder(
      future: getAssignmentTitle(assignmentID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return interText('-');
        } else {
          return interText('Assignment: ${snapshot.data}', fontSize: 16);
        }
      });
}

Widget assignedSections(List<dynamic> associatedSections) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      interText('Assigned Sections', fontWeight: FontWeight.bold, fontSize: 20),
      associatedSections.isNotEmpty
          ? FutureBuilder(
              future: getSectionNames(associatedSections),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return interText('-');
                } else {
                  return Column(
                    children: [
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 0.5),
                                  color:
                                      CustomColors.softOrange.withOpacity(0.5),
                                ),
                                padding: EdgeInsets.all(4),
                                child: interText(snapshot.data![index],
                                    fontSize: 16));
                          })
                    ],
                  );
                }
              })
          : interText('THIS LESSON IS NOT ASSIGNED TO ANY SECTION',
              fontWeight: FontWeight.bold, fontSize: 36),
      Gap(8),
      Divider(thickness: 4),
    ],
  );
}

Widget pendingAssignmentEntry(BuildContext context,
    {required DocumentSnapshot assignmentDoc}) {
  final assignmentData = assignmentDoc.data() as Map<dynamic, dynamic>;
  String title = assignmentData['title'];
  String subject = assignmentData['subject'];
  DateTime deadline = (assignmentData['deadline'] as Timestamp).toDate();
  return ElevatedButton(
      onPressed: () => NavigatorRoutes.answerAssignment(context,
          assignmentID: assignmentDoc.id, fromHomeScreen: true),
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: CustomColors.softOrange,
          foregroundColor: Colors.white),
      child: Container(
        padding: EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            interText('Subject: $subject',
                fontWeight: FontWeight.bold, fontSize: 18),
            interText(
                'Deadline: ${DateFormat('MMM dd, yyyy').format(deadline)}',
                fontSize: 18),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: interText(title, fontSize: 16))
          ],
        ),
      ));
}

Widget pendingQuizEntry(BuildContext context,
    {required DocumentSnapshot quizDoc}) {
  final quizData = quizDoc.data() as Map<dynamic, dynamic>;
  String title = quizData['title'];
  String subject = quizData['subject'];
  return ElevatedButton(
      onPressed: () => NavigatorRoutes.answerQuiz(context, quizID: quizDoc.id),
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: CustomColors.softOrange,
          foregroundColor: Colors.white),
      child: Container(
        padding: EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            interText('Subject: $subject',
                fontWeight: FontWeight.bold, fontSize: 18),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: interText(title, fontSize: 16))
          ],
        ),
      ));
}

Widget submittedAssignmentEntry(BuildContext context,
    {required DocumentSnapshot submissionDoc}) {
  final submissionData = submissionDoc.data() as Map<dynamic, dynamic>;
  num grade = submissionData['grade'];
  String assignmentID = submissionData['assignmentID'];
  return all10Pix(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder(
                future: getCorrespondingAssignment(assignmentID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return interText('-');
                  } else {
                    final assignmentData =
                        snapshot.data!.data() as Map<dynamic, dynamic>;
                    String title = assignmentData['title'];
                    return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: interText(title, fontWeight: FontWeight.bold));
                  }
                }),
            interText('${grade.toString()}/10', fontWeight: FontWeight.bold)
          ],
        ),
        Gap(8),
        LinearPercentIndicator(
          backgroundColor: CustomColors.veryLightGrey,
          progressColor: CustomColors.softOrange,
          width: MediaQuery.of(context).size.width * 0.84,
          padding: EdgeInsets.zero,
          lineHeight: 20,
          barRadius: Radius.circular(20),
          percent: (grade / 100),
        )
      ],
    ),
  );
}

Widget answeredQuizEntry(BuildContext context,
    {required DocumentSnapshot quizResultDoc}) {
  final quizResultData = quizResultDoc.data() as Map<dynamic, dynamic>;
  num grade = quizResultData['grade'];
  String quizID = quizResultData['quizID'];
  return all10Pix(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder(
                future: getCorrespondingQuiz(quizID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return interText('-');
                  } else {
                    final assignmentData =
                        snapshot.data!.data() as Map<dynamic, dynamic>;
                    String title = assignmentData['title'];
                    return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: interText(title, fontWeight: FontWeight.bold));
                  }
                }),
            interText('${grade.toString()}/10', fontWeight: FontWeight.bold)
          ],
        ),
        Gap(8),
        LinearPercentIndicator(
          backgroundColor: CustomColors.veryLightGrey,
          progressColor: CustomColors.softOrange,
          width: MediaQuery.of(context).size.width * 0.84,
          padding: EdgeInsets.zero,
          lineHeight: 20,
          barRadius: Radius.circular(20),
          percent: (grade / 10),
        )
      ],
    ),
  );
}
