import 'dart:core';
import 'dart:core';

import 'package:intl/intl.dart';
//get current month name
String getCurrentMonthName(){
  DateTime now=DateTime.now();
  List<String> months=[
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
  ];
  return months[now.month-1];
}

//convert string to double
double convertStringToDouble(String s){
  double? amount=double.tryParse(s);
  return amount ?? 0;
}

String formatAmount(double amount){
  final format=NumberFormat.currency(locale: "in_INR", customPattern: "₹", decimalDigits: 0,);
  return format.format(amount);
}

//calculate the number of months since the first month
int calculateMonthCount(int startYear,int startMonth,int currentYear, int currentMonth){
  int monthCount=(currentYear-startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}

