import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_software/controllers/calculator_controller.dart';

class FloatingCalculator extends StatelessWidget {
  const FloatingCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    final CalculatorController controller = Get.find();

    return Obx(() {
      if (!controller.isVisible.value) return const SizedBox.shrink();

      return Positioned(
        left: controller.position.value.dx,
        top: controller.position.value.dy,
        child: Draggable(
          feedback: _buildCalculatorCard(context, controller, isDragging: true),
          childWhenDragging: const SizedBox.shrink(),
          onDragEnd: (details) {
            // Update position after drag
            controller.updatePosition(details.offset);
          },
          child: _buildCalculatorCard(context, controller),
        ),
      );
    });
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    CalculatorController controller, {
    bool isDragging = false,
  }) {
    return Material(
      elevation: isDragging ? 16 : 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            _buildHeader(context, controller),

            // Display
            _buildDisplay(context, controller),

            // Calculator buttons
            _buildButtonGrid(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CalculatorController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calculate_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Calculator',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onPressed: () => controller.hide(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay(BuildContext context, CalculatorController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Equation display (top)
          Obx(
            () => Text(
              controller.equation.value.isEmpty
                  ? ' '
                  : controller.equation.value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          // Answer display (bottom)
          Obx(
            () => Text(
              controller.displayValue.value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonGrid(
    BuildContext context,
    CalculatorController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Memory and function row
          Row(
            children: [
              _buildButton(
                context,
                'MC',
                () => controller.memoryClear(),
                isFunction: true,
              ),
              _buildButton(
                context,
                'MR',
                () => controller.memoryRecall(),
                isFunction: true,
              ),
              _buildButton(
                context,
                'M+',
                () => controller.memoryAdd(),
                isFunction: true,
              ),
              _buildButton(
                context,
                'M-',
                () => controller.memorySubtract(),
                isFunction: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 1: Clear, CE, Backspace, Divide
          Row(
            children: [
              _buildButton(
                context,
                'C',
                () => controller.clear(),
                isFunction: true,
              ),
              _buildButton(
                context,
                'CE',
                () => controller.clearEntry(),
                isFunction: true,
              ),
              _buildButton(
                context,
                '⌫',
                () => controller.backspace(),
                isFunction: true,
              ),
              _buildButton(
                context,
                '÷',
                () => controller.setOperation('÷'),
                isOperator: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: 7, 8, 9, Multiply
          Row(
            children: [
              _buildButton(context, '7', () => controller.inputNumber('7')),
              _buildButton(context, '8', () => controller.inputNumber('8')),
              _buildButton(context, '9', () => controller.inputNumber('9')),
              _buildButton(
                context,
                '×',
                () => controller.setOperation('×'),
                isOperator: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 3: 4, 5, 6, Subtract
          Row(
            children: [
              _buildButton(context, '4', () => controller.inputNumber('4')),
              _buildButton(context, '5', () => controller.inputNumber('5')),
              _buildButton(context, '6', () => controller.inputNumber('6')),
              _buildButton(
                context,
                '-',
                () => controller.setOperation('-'),
                isOperator: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 4: 1, 2, 3, Add
          Row(
            children: [
              _buildButton(context, '1', () => controller.inputNumber('1')),
              _buildButton(context, '2', () => controller.inputNumber('2')),
              _buildButton(context, '3', () => controller.inputNumber('3')),
              _buildButton(
                context,
                '+',
                () => controller.setOperation('+'),
                isOperator: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 5: +/-, 0, ., Equals
          Row(
            children: [
              _buildButton(
                context,
                '±',
                () => controller.toggleSign(),
                isFunction: true,
              ),
              _buildButton(context, '0', () => controller.inputNumber('0')),
              _buildButton(context, '.', () => controller.inputDecimal()),
              _buildButton(
                context,
                '=',
                () => controller.calculate(),
                isOperator: true,
                isEquals: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 6: Additional functions
          Row(
            children: [
              _buildButton(
                context,
                '%',
                () => controller.percent(),
                isFunction: true,
              ),
              _buildButton(
                context,
                'x²',
                () => controller.square(),
                isFunction: true,
              ),
              _buildButton(
                context,
                '√',
                () => controller.squareRoot(),
                isFunction: true,
              ),
              _buildButton(context, '1/x', () {
                double value =
                    double.tryParse(controller.displayValue.value) ?? 0;
                if (value != 0) {
                  double result = 1 / value;
                  if (result == result.toInt()) {
                    controller.displayValue.value = result.toInt().toString();
                  } else {
                    controller.displayValue.value = result
                        .toStringAsFixed(8)
                        .replaceAll(RegExp(r'0*$'), '')
                        .replaceAll(RegExp(r'\.$'), '');
                  }
                } else {
                  controller.displayValue.value = 'Error';
                  controller.clear();
                }
              }, isFunction: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    VoidCallback onTap, {
    bool isOperator = false,
    bool isFunction = false,
    bool isEquals = false,
  }) {
    Color? backgroundColor;
    Color? textColor;

    if (isEquals) {
      backgroundColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.onPrimary;
    } else if (isOperator) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      textColor = Theme.of(context).colorScheme.onPrimaryContainer;
    } else if (isFunction) {
      backgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest;
      textColor = Theme.of(context).colorScheme.onSurface;
    } else {
      backgroundColor = Theme.of(context).colorScheme.surfaceContainer;
      textColor = Theme.of(context).colorScheme.onSurface;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: isEquals || isOperator
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
