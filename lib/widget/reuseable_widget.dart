import 'package:flutter/material.dart';
import 'package:workplan_beta_test/base/system_param.dart';

class Reuseable {
  static mainTitle(String title) {
    return Center(
      child: Text(title,
          style: TextStyle(
              fontFamily: 'Calibre',
              color: SystemParam.colorCustom,
              fontWeight: FontWeight.bold,
              fontSize: 18)),
    );
  }

  static leadingIcon(String image) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[100],
      ),
      child: Image.asset(
        image,
      ),
    );
  }

  static double jarak1 = 5;
  static double jarak2 = 10;
  static double jarak3 = 20;

  static TextStyle titleStyle = TextStyle(
      fontFamily: 'Poppins',
      color: SystemParam.colorPersonalTitle,
      fontWeight: FontWeight.w400,
      fontSize: 12);
  
  static TextStyle titleStyle2 = TextStyle(
      fontFamily: 'Poppins',
      color: SystemParam.colorCustom,
      fontWeight: FontWeight.bold,
      fontSize: 12);
  
  static TextStyle titleStyle3 = TextStyle(
      fontFamily: 'Poppins',
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 10);

  static TextStyle judulStyle = TextStyle(
      fontFamily: 'Calibre',
      color: SystemParam.colorCustom,
      fontWeight: FontWeight.bold,
      fontSize: 18);

  static TextStyle subJudulStyle = TextStyle(
      fontFamily: 'Calibre',
      color: SystemParam.colorDivider,
      fontWeight: FontWeight.bold,
      fontSize: 14);

  static inputDecorationSearch(String hintText) {
    InputDecoration inputDecoration = InputDecoration(
      suffixIcon: Icon(Icons.search),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey),
      filled: true,
      fillColor: SystemParam.colorbackgroud,
      labelStyle: TextStyle(
          color: SystemParam.colorCustom, fontStyle: FontStyle.italic),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: SystemParam.colorbackgroud),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: SystemParam.colorbackgroud),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      contentPadding: EdgeInsets.all(10),
    );
    return inputDecoration;
  }

  static inputDecorationDateDynamic(String hintText) {
    InputDecoration inputDecorationDate = InputDecoration(
      hintText: hintText,
      suffixIcon: new Icon(Icons.date_range, color: Colors.grey),
      filled: true,
      fillColor: SystemParam.colorbackgroud,
      labelStyle: TextStyle(
          color: SystemParam.colorCustom, fontStyle: FontStyle.italic),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: SystemParam.colorbackgroud),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: SystemParam.colorbackgroud),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      contentPadding: EdgeInsets.all(10),
    );
    return inputDecorationDate;
  }

  static InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: SystemParam.colorbackgroud,
    labelStyle:
        TextStyle(color: SystemParam.colorCustom, fontStyle: FontStyle.italic),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: SystemParam.colorbackgroud),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: SystemParam.colorbackgroud),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    contentPadding: EdgeInsets.all(10),
  );

  static InputDecoration inputDecorationNumber = InputDecoration(
    filled: true,
    fillColor: SystemParam.colorbackgroud,
    labelStyle:
        TextStyle(color: SystemParam.colorCustom, fontStyle: FontStyle.italic),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: SystemParam.colorbackgroud),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: SystemParam.colorbackgroud),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    contentPadding: EdgeInsets.all(10),
  );

  static InputDecoration inputDecorationDate = InputDecoration(
    suffixIcon: new Icon(Icons.date_range),
    filled: true,
    fillColor: SystemParam.colorbackgroud,
    labelStyle:
        TextStyle(color: SystemParam.colorCustom, fontStyle: FontStyle.italic),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: SystemParam.colorbackgroud),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: SystemParam.colorbackgroud),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    contentPadding: EdgeInsets.all(10),
  );

  static trailingIcon() {
    return Image.asset("images/Menu_Task/Data Task/arrow-down-circle.png");
  }
}
