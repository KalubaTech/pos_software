import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CalculatorController extends GetxController {
  // Visibility state
  var isVisible = false.obs;

  // Display values
  var displayValue = '0'.obs;
  var equation = ''.obs; // Full equation display
  var operation = ''.obs;

  // Internal state
  double _firstOperand = 0;
  double _secondOperand = 0;
  String _currentOperation = '';
  bool _shouldResetDisplay = false;

  // Memory
  double _memory = 0;

  // Position for draggable
  var position = const Offset(100, 100).obs;

  void show() {
    isVisible.value = true;
  }

  void hide() {
    isVisible.value = false;
  }

  void toggle() {
    isVisible.value = !isVisible.value;
  }

  void updatePosition(Offset newPosition) {
    position.value = newPosition;
  }

  void inputNumber(String number) {
    if (_shouldResetDisplay) {
      displayValue.value = number;
      _shouldResetDisplay = false;
      // Update equation display
      if (_currentOperation.isNotEmpty) {
        equation.value = '$_firstOperand $_currentOperation $number';
      }
    } else {
      if (displayValue.value == '0') {
        displayValue.value = number;
      } else {
        displayValue.value += number;
      }
      // Update equation display
      if (_currentOperation.isNotEmpty) {
        equation.value =
            '$_firstOperand $_currentOperation ${displayValue.value}';
      }
    }
  }

  void inputDecimal() {
    if (_shouldResetDisplay) {
      displayValue.value = '0.';
      _shouldResetDisplay = false;
    } else if (!displayValue.value.contains('.')) {
      displayValue.value += '.';
    }
  }

  void setOperation(String op) {
    if (_currentOperation.isNotEmpty) {
      calculate();
    }

    _firstOperand = double.tryParse(displayValue.value) ?? 0;
    _currentOperation = op;
    operation.value = op;
    equation.value = '$_firstOperand $op';
    _shouldResetDisplay = true;
  }

  void calculate() {
    if (_currentOperation.isEmpty) return;

    _secondOperand = double.tryParse(displayValue.value) ?? 0;
    double result = 0;

    // Build complete equation
    equation.value = '$_firstOperand $_currentOperation $_secondOperand =';

    switch (_currentOperation) {
      case '+':
        result = _firstOperand + _secondOperand;
        break;
      case '-':
        result = _firstOperand - _secondOperand;
        break;
      case '×':
        result = _firstOperand * _secondOperand;
        break;
      case '÷':
        if (_secondOperand != 0) {
          result = _firstOperand / _secondOperand;
        } else {
          displayValue.value = 'Error';
          equation.value = '';
          clear();
          return;
        }
        break;
      case '%':
        result = _firstOperand % _secondOperand;
        break;
    }

    // Format result to remove unnecessary decimals
    if (result == result.toInt()) {
      displayValue.value = result.toInt().toString();
    } else {
      displayValue.value = result
          .toStringAsFixed(8)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }

    _currentOperation = '';
    operation.value = '';
    _shouldResetDisplay = true;
  }

  void clear() {
    displayValue.value = '0';
    equation.value = '';
    operation.value = '';
    _firstOperand = 0;
    _secondOperand = 0;
    _currentOperation = '';
    _shouldResetDisplay = false;
  }

  void clearEntry() {
    displayValue.value = '0';
    _shouldResetDisplay = false;
  }

  void backspace() {
    if (displayValue.value.length > 1) {
      displayValue.value = displayValue.value.substring(
        0,
        displayValue.value.length - 1,
      );
    } else {
      displayValue.value = '0';
    }
  }

  void toggleSign() {
    double value = double.tryParse(displayValue.value) ?? 0;
    value = -value;

    if (value == value.toInt()) {
      displayValue.value = value.toInt().toString();
    } else {
      displayValue.value = value.toString();
    }
  }

  void percent() {
    double value = double.tryParse(displayValue.value) ?? 0;
    value = value / 100;

    if (value == value.toInt()) {
      displayValue.value = value.toInt().toString();
    } else {
      displayValue.value = value.toString();
    }
  }

  void squareRoot() {
    double value = double.tryParse(displayValue.value) ?? 0;
    if (value >= 0) {
      double result = math.sqrt(value);
      if (result == result.toInt()) {
        displayValue.value = result.toInt().toString();
      } else {
        displayValue.value = result
            .toStringAsFixed(8)
            .replaceAll(RegExp(r'0*$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      }
      _shouldResetDisplay = true;
    } else {
      displayValue.value = 'Error';
      clear();
    }
  }

  void square() {
    double value = double.tryParse(displayValue.value) ?? 0;
    double result = value * value;

    if (result == result.toInt()) {
      displayValue.value = result.toInt().toString();
    } else {
      displayValue.value = result
          .toStringAsFixed(8)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    _shouldResetDisplay = true;
  }

  // Memory functions
  void memoryClear() {
    _memory = 0;
  }

  void memoryRecall() {
    if (_memory == _memory.toInt()) {
      displayValue.value = _memory.toInt().toString();
    } else {
      displayValue.value = _memory.toString();
    }
    _shouldResetDisplay = true;
  }

  void memoryAdd() {
    double value = double.tryParse(displayValue.value) ?? 0;
    _memory += value;
  }

  void memorySubtract() {
    double value = double.tryParse(displayValue.value) ?? 0;
    _memory -= value;
  }
}
