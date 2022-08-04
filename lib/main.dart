import 'dart:core';

import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:calculator/constants.dart';
import 'package:calculator/custom_extensions.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "EuCalculator",
      theme: ThemeData(primarySwatch: Colors.red),
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  late EdgeInsets paddingForButtons;
  late EdgeInsets paddingForTextFields;
  late int maxLines;
  late OutlinedBorder border;

  String equation = defaultValueText;
  String result = defaultValueText;
  final Parser _parser = Parser();

  TextEditingController equationController =
      TextEditingController(text: defaultValueText);
  TextEditingController resultController =
      TextEditingController(text: defaultValueText);

  Widget buildTextContainer(TextEditingController controller, bool showCursor,
      int maxLines, double fontSize) {
    return Container(
        padding: paddingForTextFields,
        child: AutoSizeTextField(
          textAlign: TextAlign.end,
          controller: controller,
          readOnly: true,
          showCursor: showCursor,
          style: TextStyle(fontSize: fontSize),
          decoration: const InputDecoration(border: InputBorder.none),
          minLines: 1,
          maxLines: maxLines,
          autofocus: true,
        ));
  }

  buttonLongPressed(String buttonText) {
    setState(() {
      if (buttonText == ACText) {
        equation = defaultValueText;
        result = defaultValueText;
      }
      updateControllers();
    });
  }

  void updateControllers({int offset = 0}) {
    int start = equationController.selection.baseOffset + offset;
    if (equation.isEmpty) start = 0;
    equationController.text = equation;
    equationController.selection =
        TextSelection(baseOffset: start, extentOffset: start);
    resultController.text = result;
  }

  buttonPressed(String buttonText) {
    setState(() {
      calculate(buttonText);
    });
  }

  Widget buildButton(String buttonText, double buttonWidth, Color buttonColor) {
    double width = MediaQuery.of(context).size.width * 0.25 * buttonWidth;
    double height = MediaQuery.of(context).size.height * 0.1;

    if (MediaQuery.of(context).size.width < 600) {
      if (buttonWidth == 1) {
        border = const CircleBorder();
      } else {
        border = const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50)));
      }
    }

    return TextButton(
      onLongPress: () => buttonLongPressed(buttonText),
      onPressed: () => buttonPressed(buttonText),
      style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(width, height)),
          backgroundColor: MaterialStateProperty.all(buttonColor),
          shape: MaterialStateProperty.all(border),
          padding: MaterialStateProperty.all(paddingForButtons)),
      child: Text(
        buttonText,
        style: const TextStyle(
            color: Colors.white, fontSize: 40, fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget buildTableForLandscapeMode() {
    return buildTableForPortraitMode();
  }

  Widget buildTableForPortraitMode() {
    return Column(
      children: [
        Row(
          children: [
            buildButton(ACText, 1, functionColor),
            buildButton(changeSignText, 1, functionColor),
            buildButton(percentageText, 1, functionColor),
            buildButton(divisionText, 1, operationColor),
          ],
        ),
        const SizedBox(height: paddingBetweenRows),
        Row(children: [
          buildButton("7", 1, numberColor),
          buildButton("8", 1, numberColor),
          buildButton("9", 1, numberColor),
          buildButton(multiplyText, 1, operationColor),
        ]),
        const SizedBox(height: paddingBetweenRows),
        Row(children: [
          buildButton("4", 1, numberColor),
          buildButton("5", 1, numberColor),
          buildButton("6", 1, numberColor),
          buildButton(minusText, 1, operationColor),
        ]),
        const SizedBox(height: paddingBetweenRows),
        Row(children: [
          buildButton("1", 1, numberColor),
          buildButton("2", 1, numberColor),
          buildButton("3", 1, numberColor),
          buildButton(plusText, 1, operationColor),
        ]),
        const SizedBox(height: paddingBetweenRows),
        Row(
          children: [
            buildButton(".", 1, numberColor),
            buildButton("0", isLandscapeMode() ? 1 : 2, numberColor),
            buildButton(equalText, 1, operationColor),
          ],
        ),
        const SizedBox(height: paddingBetweenRows),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 600) {
      setUpForLandscape();
      paddingForButtons = EdgeInsets.zero;
      maxLines = 1;
    } else {
      setUpForPortrait();
      maxLines = 3;
    }

    return Scaffold(
        body: Column(
      children: <Widget>[
        buildTextContainer(equationController, true, maxLines, 38),
        buildTextContainer(resultController, false, maxLines, 48),
        const Expanded(child: Divider(color: Colors.transparent)),
        isLandscapeMode()
            ? buildTableForLandscapeMode()
            : buildTableForPortraitMode(),
      ],
    ));
  }

  void setUpForPortrait() {
    paddingForButtons = paddingWithinButtonInPortrait;
    paddingForTextFields = paddingWithinButtonInPortrait;
    maxLines = maxLinesInPortrait;
  }

  void setUpForLandscape() {
    paddingForButtons = paddingWithinButtonInLandscape;
    paddingForTextFields = paddingForTextFieldInLandscape;
    maxLines = maxLinesInLandscape;
    border = borderInLandscape;
  }

  bool isLandscapeMode() {
    return MediaQuery.of(context).size.width > 600;
  }

  void calculate(String buttonString) {
    if (buttonString.isOperator()) {
      addToCursor(buttonString);
    } else if (buttonString.isDigit()) {
      addToCursor(buttonString);
    } else if (buttonString == ACText) {
      deleteSymbol();

      if (equation.isNotEmpty) {
        updateControllers(offset: -1);
      } else {
        updateControllers();
      }
      return;
    } else if (buttonString == changeSignText) {
      changeSign();
      return;
    } else if (buttonString == equalText) {
      try {
        String expression = equation
            .replaceAll(multiplyText, "*")
            .replaceAll(divisionText, "/");

        result = _parser
            .parse(expression)
            .evaluate(EvaluationType.REAL, ContextModel())
            .toString();
      } catch (e) {
        result = "Error";
      } finally {
        updateControllers();
      }
      return;
    } else if (buttonString == percentageText) {
      getPercentageOf();
    }
    updateControllers(offset: 1);
  }

  void addToCursor(String buttonValue) {
    equation = StringUtils.addCharAtPosition(
        equation, buttonValue, equationController.selection.baseOffset);
  }

  void changeSign() {
    var range = getSelectedNumberPosition(
        equation, equationController.selection.baseOffset);
    if (range.end == 0) {
      if (equation[0] != "-") {
        equation = StringUtils.addCharAtPosition(equation, '-', 0);
      }
    } else {
      var selectedNumber =
          equation.substring(range.start.toInt(), range.end.toInt());
      if (selectedNumber[0] != '-') {
        equation =
            StringUtils.addCharAtPosition(equation, '-', range.start.toInt());
        updateControllers(offset: 1);
      } else {
        equation = equation.replaceFirst('-', '', range.start.toInt());
        updateControllers(offset: -1);
      }
    }
  }

  void deleteSymbol() {
    int start = equationController.selection.start;
    int end = equationController.selection.end;
    if (start == end) {
      start -= 1;
    }
    equation = equation.replaceRange(start, end, "");
  }

  void getPercentageOf() {
    var range = getSelectedNumberPosition(
        equation, equationController.selection.baseOffset);
    try {
      var selectedNumber =
          equation.substring(range.start.toInt(), range.end.toInt());

      var percentage = double.parse(selectedNumber) / 100;
      var equationWithoutSelectedNumber =
          equation.replaceRange(range.start.toInt(), range.end.toInt(), "");

      equation = StringUtils.addCharAtPosition(equationWithoutSelectedNumber,
          percentage.toString(), range.start.toInt());
    } catch (e) {}
  }
}

RangeValues getSelectedNumberPosition(String s, int cursorPosition) {
  double start = 0;
  double end = s.length.toDouble();

  for (int i = cursorPosition - 1; i < s.length; i++) {
    if (s[i].isDigit()) {
      end = i + 1;
    } else {
      break;
    }
  }
  for (int i = cursorPosition - 1; i >= 0; i--) {
    if (s[i].isDigit() || s[i] == "-") {
      start = i.toDouble();
    } else {
      break;
    }
  }
  return RangeValues(start, end);
}
