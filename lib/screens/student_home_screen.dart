import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/providers/current_user_type_provider.dart';
import 'package:edutask/util/future_util.dart';
import 'package:edutask/widgets/app_bar_widgets.dart';
import 'package:edutask/widgets/app_bottom_nav_bar_widget.dart';
import 'package:edutask/widgets/app_drawer_widget.dart';
import 'package:edutask/widgets/custom_button_widgets.dart';
import 'package:edutask/widgets/custom_container_widgets.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/profile_image_provider.dart';
import '../util/color_util.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  bool _isLoading = true;
  String profileImageURL = '';
  String section = '';

//List<DocumentSnapshot> pendingAssignments = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getBasicUserData();
  }

  void getBasicUserData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final userData = user.data() as Map<dynamic, dynamic>;
      profileImageURL = userData['profileImageURL'];
      section = userData['section'];
      ref.read(profileImageProvider.notifier).setProfileImage(profileImageURL);

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting basic user data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: homeAppBarWidget(context,
            backgroundColor: CustomColors.veryDarkGrey, mayGoBack: true),
        drawer: appDrawer(context,
            userType: ref.read(currentUserTypeProvider),
            profileImageURL: ref.read(profileImageProvider)),
        bottomNavigationBar: clientBottomNavBar(context, index: 0),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: studentSubmittablesButton(context),
        body: switchedLoadingContainer(
            _isLoading,
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  welcomeWidgets(
                      userType: 'STUDENT',
                      profileImageURL: profileImageURL,
                      containerColor: CustomColors.verySoftOrange),
                  _sectionName(),
                  _announcements()
                ],
              ),
            )),
      ),
    );
  }

  Widget _announcements() {
    return all10Pix(
        child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('announcements')
                .where('associatedSections', arrayContains: section)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return interText('Error getting section');
              }
              return Column(
                children: [
                  interText('ANNOUNCEMENTS',
                      fontWeight: FontWeight.bold, fontSize: 16),
                  snapshot.data!.docs.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final annoucementData =
                                snapshot.data!.docs[index].data();
                            String title = annoucementData['title'];
                            String content = annoucementData['content'];
                            DateTime dateTimeAnnounced =
                                (annoucementData['dateTimeAnnounced']
                                        as Timestamp)
                                    .toDate();
                            return all10Pix(
                              child: ElevatedButton(
                                  onPressed: () => _viewAnnouncement(
                                      snapshot.data!.docs[index]),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: CustomColors.softOrange,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  child: all10Pix(
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            interText(
                                                DateFormat('MMM dd, YYY')
                                                    .format(dateTimeAnnounced),
                                                color: Colors.black),
                                            interText(title,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 20),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7,
                                              child: interText(content,
                                                  color: Colors.black,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                            );
                          })
                      : interText('NO ANNOUNCEMENTS AVAILABLE'),
                ],
              );
            }));
  }

  Widget _sectionName() {
    return all10Pix(
      child: FutureBuilder(
          future: getSectionName(section),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return interText('Error getting section');
            } else {
              return interText('Section: ${snapshot.data}',
                  fontWeight: FontWeight.bold, fontSize: 16);
            }
          }),
    );
  }

  void _viewAnnouncement(DocumentSnapshot announcementDoc) {
    final annoucementData = announcementDoc.data() as Map<dynamic, dynamic>;
    String title = annoucementData['title'];
    String content = annoucementData['content'];
    DateTime dateTimeAnnounced =
        (annoucementData['dateTimeAnnounced'] as Timestamp).toDate();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    interText(title,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 25),
                    Row(children: [
                      interText(
                          DateFormat('MMM dd, YYY').format(dateTimeAnnounced),
                          color: Colors.black)
                    ]),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: interText(content),
                    ),
                    ovalButton('CLOSE',
                        onPress: () => Navigator.of(context).pop(),
                        backgroundColor: CustomColors.softOrange)
                  ],
                ),
              ),
            ));
  }
}
