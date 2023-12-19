import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

Widget dropdownWidget(
    String selectedOption,
    Function(String?) onDropdownValueChanged,
    List<String> dropdownItems,
    String label,
    bool searchable) {
  return DropdownSearch<String>(
    dropdownButtonProps: const DropdownButtonProps(color: Colors.black),
    dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            labelStyle: TextStyle(color: Colors.black)),
        baseStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
    popupProps: PopupProps.menu(
      fit: FlexFit.loose,
      showSelectedItems: false,
      showSearchBox: searchable,
      menuProps: MenuProps(
          backgroundColor: Colors.white,
          borderRadius: BorderRadius.circular(10)),
    ),
    items: dropdownItems,
    onChanged: onDropdownValueChanged,
    selectedItem: label,
  );
}

Widget userDocumentSnapshotDropdownWidget(
  String selectedOption,
  Function(String?) onDropdownValueChanged,
  List<DocumentSnapshot> dropdownDocuments,
) {
  return DropdownButton<String>(
    value: selectedOption,
    items: dropdownDocuments.map((doc) {
      print(doc.id);
      final docData = doc.data() as Map<dynamic, dynamic>;
      String formattedName = '${docData['firstName']} ${docData['lastName']}';
      return DropdownMenuItem<String>(
          value: doc.id, child: Text(formattedName));
    }).toList(),
    onChanged: onDropdownValueChanged,
  );
}
