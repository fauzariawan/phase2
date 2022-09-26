import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class Shift {
  String name;
  InOut shiftIn;
  InOut shiftOut;

  Shift({required this.name, required this.shiftIn, required this.shiftOut});
}

@JsonSerializable()
class InOut {
  String time;
  String timeZone;

  InOut({required this.time, required this.timeZone});
}

