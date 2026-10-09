import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _currentInput = '';
  double? _firstNumber;
  String? _operator;
  bool _showingResult = false;
  bool _hasError = false;

  void _clear() {
    setState(() {
      _display = '0';
      _currentInput = '';
      _firstNumber = null;
      _operator = null;
      _showingResult = false;
      _hasError = false;
    });
  }

  void _enterNumber(String number) {
    setState(() {
      if (_hasError || _showingResult) {
        _currentInput = '';
        _firstNumber = null;
        _operator = null;
        _hasError = false;
        _showingResult = false;
      }

      if (_currentInput == '0') {
        _currentInput = number;
      } else {
        _currentInput += number;
      }

      _display = _currentInput;
    });
  }

  void _chooseOperator(String selectedOperator) {
    setState(() {
      if (_hasError) {
        return;
      }

      if (_currentInput.isEmpty) {
        if (_firstNumber == null) {
          _showError('Enter a number first');
          return;
        }

        // Allow the user to replace the pending operator.
        _operator = selectedOperator;
        return;
      }

      _firstNumber = double.parse(_currentInput);
      _operator = selectedOperator;
      _currentInput = '';
      _showingResult = false;
    });
  }

  void _calculate() {
    setState(() {
      if (_hasError) {
        return;
      }

      if (_firstNumber == null || _operator == null || _currentInput.isEmpty) {
        _showError('Incomplete calculation');
        return;
      }

      final double secondNumber = double.parse(_currentInput);
      final double firstNumber = _firstNumber!;
      double result;

      switch (_operator!) {
        case '+':
          result = firstNumber + secondNumber;
          break;
        case '−':
          result = firstNumber - secondNumber;
          break;
        case '×':
          result = firstNumber * secondNumber;
          break;
        case '÷':
          if (secondNumber == 0) {
            _showError('Cannot divide by zero');
            return;
          }
          result = firstNumber / secondNumber;
          break;
        default:
          _showError('Invalid operation');
          return;
      }

      if (!result.isFinite) {
        _showError('Result is too large');
        return;
      }

      _display = _formatResult(result);
      _currentInput = _display;
      _firstNumber = null;
      _operator = null;
      _showingResult = true;
    });
  }

  String _formatResult(double value) {
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toString();
  }

  void _showError(String message) {
    _display = message;
    _currentInput = '';
    _firstNumber = null;
    _operator = null;
    _hasError = true;
    _showingResult = false;
  }

  void _onButtonPressed(String value) {
    if (value == 'AC') {
      _clear();
    } else if (value == '=') {
      _calculate();
    } else if (['+', '−', '×', '÷'].contains(value)) {
      _chooseOperator(value);
    } else {
      _enterNumber(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<List<String>> buttons = [
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '−'],
      ['AC', '0', '=', '+'],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator App'),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.bottomRight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _operator == null ? 'Ready' : 'Operation: $_operator',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _display,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: _hasError ? 28 : 48,
                            fontWeight: FontWeight.bold,
                            color: _hasError
                                ? Colors.orangeAccent
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 5,
                child: Column(
                  children: buttons.map((buttonRow) {
                    return Expanded(
                      child: Row(
                        children: buttonRow.map((label) {
                          Color buttonColor;

                          if (label == 'AC') {
                            buttonColor = Colors.red.shade700;
                          } else if (label == '=') {
                            buttonColor = Colors.green.shade700;
                          } else if (['+', '−', '×', '÷'].contains(label)) {
                            buttonColor = Colors.blue.shade700;
                          } else {
                            buttonColor = const Color(0xFF363636);
                          }

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: CalculatorButton(
                                label: label,
                                color: buttonColor,
                                onPressed: () => _onButtonPressed(label),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalculatorButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.93 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: Material(
        color: widget.color,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTapDown: (_) {
            setState(() {
              _isPressed = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              _isPressed = false;
            });
          },
          onTapCancel: () {
            setState(() {
              _isPressed = false;
            });
          },
          onTap: widget.onPressed,
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
