import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock to portrait like phone calculator
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  List<String> inputList = [];
  String result = "";
  List history = [];
  Color bgColor = Colors.white;
  Color fontColor = Colors.black;

  void insert(String value) {
    setState(() {

      if (isOperator(value)) {
        if (inputList.isEmpty) return;
        if (isOperator(inputList.last) && inputList[inputList.length - 1]  !='!') {
          inputList[inputList.length - 1] = value; // Replace last operator
        }
        else if(inputList[inputList.length - 1] == '.' && isOperator(value)){
          inputList[inputList.length - 1] = value;
        }
        else {
          inputList.add(value);
        }
      } else {
        inputList.add(value);
      }

      _evaluate();

    });
  }

  void delete() {
    setState(() {
      if (inputList.isNotEmpty) {
        inputList.removeLast();
        _evaluate();
      }
    });
  }

  void clear() {
    setState(() {
      inputList.clear();
      result = "";
    });
  }

  void _evaluate() {
    try {
      String expr = inputList.join().replaceAll("×", "*").replaceAll("÷", "/");
      final value = _ExpressionParser().evaluate(expr);

      int temp = value.toInt();

      if(value != temp) {
        result = value.toStringAsFixed(5);
      }
      else {
        result = value.toStringAsFixed(0);
      }

    }
    catch (e) {
      result = "";
    }
  }

  bool isOperator(String value) => ['+', '-', '×', '÷','^','!'].contains(value);

  final List<String> buttons = [
    '=', 'C', '⌫', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', '.', '!', '^'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator',style: TextStyle(color: fontColor),),
        backgroundColor: bgColor,
        actions: [
          IconButton(
            onPressed: (){
              bgColor = (bgColor == Colors.white) ? Colors.black: Colors.white;
              fontColor = (fontColor == Colors.white) ? Colors.black: Colors.white;
              setState(() {});
            },
            icon: Icon(Icons.dark_mode),color: fontColor,)
        ],
      ),
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      inputList.join(),
                      style: TextStyle(fontSize: 30, color: fontColor),
                    ),
                  ),
                ),
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: (){
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 1,
                          decoration: BoxDecoration(
                            color: bgColor,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          padding: EdgeInsets.all( 20),
                          child: ListView.builder(

                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  title: Text(history[index][0],style: TextStyle(fontSize: 20),),
                                  trailing: Text('= ${history[index][1]}',style: TextStyle(fontSize: 20),),

                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }, icon: Icon(Icons.receipt)
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width *0.88,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Text( result,
                          style: TextStyle(fontSize: 36, color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(12),
              itemCount: buttons.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final label = buttons[index];

                if (label == '') return SizedBox();

                return ElevatedButton(
                  onPressed: () {
                    if(label == '='){
                      if(inputList.isEmpty || result == '') return;

                      history.insert(0, [inputList.join(),result]);

                      inputList = [result];
                      result = '';

                      setState(() {});
                    }
                    else if (label == 'C') {
                      clear();
                    } else if (label == '⌫') {
                      delete();
                    } else {
                      insert(label);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor(label),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: EdgeInsets.all(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 24,
                      color: _textColor(label),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _buttonColor(String value) {
    if (value == 'C' || value == '⌫') return Colors.red.shade100;
    if (isOperator(value)) return Colors.blue.shade100;
    return Colors.white10;
  }

  Color _textColor(String value) {
    if (value == 'C' || value == '⌫') return Colors.red.shade800;
    if (isOperator(value)) return Colors.blue.shade800;
    return fontColor;
  }
}

class _ExpressionParser {
  double evaluate(String expr) {
    List<String> tokens = _tokenize(expr);
    List<double> values = [];
    List<String> ops = [];

    for (int i = 0; i < tokens.length; i++) {
      String token = tokens[i];

      if (_isNumber(token)) {
        double value = double.parse(token);

        // Check if next token is factorial
        if (i + 1 < tokens.length && tokens[i + 1] == '!') {
          value = _factorial(value);
          i++; // skip next token
        }

        values.add(value);
      } else if (_isOperator(token) && token != '!') {
        while (ops.isNotEmpty && _precedence(ops.last) >= _precedence(token)) {
          double b = values.removeLast();
          double a = values.removeLast();
          String op = ops.removeLast();
          values.add(_applyOp(a, b, op));
        }
        ops.add(token);
      }
    }

    while (ops.isNotEmpty) {
      double b = values.removeLast();
      double a = values.removeLast();
      String op = ops.removeLast();
      values.add(_applyOp(a, b, op));
    }

    return values.first;
  }

  double _factorial(double n) {
    if (n < 0) throw Exception("Factorial of negative number");
    if (n == 0 || n == 1) return 1;
    double res = 1;
    for (int i = 2; i <= n; i++) {
      res *= i;
    }
    return res;
  }


  List<String> _tokenize(String expr) {
    List<String> tokens = [];
    String current = "";
    for (int i = 0; i < expr.length; i++) {
      final ch = expr[i];
      if ('0123456789.'.contains(ch)) {
        current += ch;
      } else if (_isOperator(ch)) {
        if (current.isNotEmpty) {
          tokens.add(current);
          current = '';
        }
        tokens.add(ch);
      }
    }
    if (current.isNotEmpty) tokens.add(current);
    return tokens;
  }

  bool _isOperator(String s) => ['+', '-', '*', '/','^','!'].contains(s);
  bool _isNumber(String s) => double.tryParse(s) != null;
  int _precedence(String op) => (op == '+' || op == '-') ? 1 : 2;

  double _applyOp(double a, double b, String op) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '*': return a * b;
      case '/': return b != 0 ? a / b : throw Exception("Divide by zero");
      case '^': return math.pow(a, b).toDouble(); // support -ve and decimal exponents
      default: throw Exception("Invalid operator");
    }
  }
}
