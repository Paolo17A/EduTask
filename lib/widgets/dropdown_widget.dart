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
