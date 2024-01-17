import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> getTeacherName(String teacherID) async {
  final teacher =
      await FirebaseFirestore.instance.collection('users').doc(teacherID).get();
  final teacherData = teacher.data() as Map<dynamic, dynamic>;
  return '${teacherData['firstName']} ${teacherData['lastName']}';
}

Future<List<String>> getSectionNames(List<dynamic> associatedSections) async {
  final sections = await FirebaseFirestore.instance
      .collection('sections')
      .where(FieldPath.documentId, whereIn: associatedSections)
      .get();
  final sectionDocs = sections.docs;
  return sectionDocs.map((section) {
    final sectionData = section.data();
    return sectionData['name'] as String;
  }).toList();
}
