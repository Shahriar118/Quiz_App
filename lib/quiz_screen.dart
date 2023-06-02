import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'question.dart';
import 'result_page.dart';



class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _wrongAnswers = 0;
  int _lives = 3;
  int _secondsRemaining = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
    _startTimer();
  }

  void _generateQuestions() {
    for (int i = 0; i < 5; i++) {
      int operand1 = Random().nextInt(10) + 1;
      int operand2 = Random().nextInt(10) + 1;
      int operand3 = Random().nextInt(10) + 1;
      int operand4 = Random().nextInt(10) + 1;
      String operator1 = Random().nextInt(2) == 0 ? '+' : '-';
      String operator2 = Random().nextInt(2) == 0 ? '+' : '-';
      String operator3 = Random().nextInt(2) == 0 ? '+' : '-';
      String questionText = '$operand1 $operator1 $operand2 $operator2 $operand3 $operator3 $operand4';
      int correctAnswer = _evaluateExpression(operand1, operand2, operand3, operand4, operator1, operator2, operator3);

      List<String> options = [];
      options.add(correctAnswer.toString());

      for (int j = 0; j < 3; j++) {
        int incorrectAnswer;
        do {
          incorrectAnswer = Random().nextInt(40) + 1;
        } while (incorrectAnswer == correctAnswer || options.contains(incorrectAnswer.toString()));
        options.add(incorrectAnswer.toString());
      }

      options.shuffle();

      _questions.add(Question(questionText: questionText, options: options, correctAnswer: correctAnswer.toString()));
    }
  }

  int _evaluateExpression(int operand1, int operand2, int operand3, int operand4, String operator1, String operator2, String operator3) {
    int result = operand1;
    if (operator1 == '+') {
      result += operand2;
    } else {
      result -= operand2;
    }

    if (operator2 == '+') {
      result += operand3;
    } else {
      result -= operand3;
    }

    if (operator3 == '+') {
      result += operand4;
    } else {
      result -= operand4;
    }

    return result;
  }


  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _handleAnswer(false);
        }
      });
    });
  }

  void _checkAnswer(String selectedAnswer) {
    bool isCorrect = selectedAnswer == _questions[_currentQuestionIndex].correctAnswer;
    _handleAnswer(isCorrect);
  }

  void _handleAnswer(bool isCorrect) {
    if (isCorrect) {
      setState(() {
        _score += 10;
      });
    } else {
      setState(() {
        _wrongAnswers++;
        _lives--;
        if (_lives == 0) {
          _endQuiz();
        }
      });
    }

    _timer?.cancel();

    if (_wrongAnswers < 3) {
      _nextQuestion();
    } else {
      _endQuiz();
    }
  }



  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _currentQuestionIndex = 0;
        _score = 0;
        _wrongAnswers = 0;
        _lives = 3;
        _generateQuestions();
      }
      _secondsRemaining = 10;
      _startTimer();
    });
  }

  void _endQuiz() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(score: _score),
      ),
    );
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lives: $_lives',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 16.0),
            Text(
              _questions[_currentQuestionIndex].questionText,
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Time Remaining: $_secondsRemaining seconds',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            ..._questions[_currentQuestionIndex].options.map(
                  (option) => ElevatedButton(
                onPressed: () => _checkAnswer(option),
                child: Text(option),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
