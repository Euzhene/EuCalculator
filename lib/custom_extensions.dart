import 'constants.dart';

extension PressedButton on String {
  bool isOperator() =>
      this == divisionText ||
          this == minusText ||
          this == plusText ||
          this == multiplyText;

  bool isDigit() =>
      this == '0' ||
          this == '1' ||
          this == '2' ||
          this == '3' ||
          this == '4' ||
          this == '5' ||
          this == '6' ||
          this == '7' ||
          this == '8' ||
          this == '9' ||
          this == '.';
}