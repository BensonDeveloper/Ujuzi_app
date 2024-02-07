import 'package:flutter/material.dart';

class PerformSoilTest extends StatefulWidget {
  const PerformSoilTest({Key? key}) : super(key: key);

  @override
  _PerformSoilTestState createState() => _PerformSoilTestState();
}

class _PerformSoilTestState extends State<PerformSoilTest> {
  int _currentStep = 0;

  List<Step> _steps = [
    Step(
      title: Text('Step 1'),
      content: Container(
        child: Text('Step 1 content'),
      ),
    ),
    Step(
      title: Text('Step 2'),
      content: Container(
        child: Text('Step 2 content'),
      ),
    ),
    Step(
      title: Text('Step 3'),
      content: Container(
        child: Text('Step 3 content'),
      ),
    ),
    Step(
      title: Text('Step 4'),
      content: Container(
        child: Text('Step 4 content'),
      ),
      isActive: true,
      state: _currentStep == 3 ? StepState.complete : StepState.indexed,
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            if (_currentStep == _steps.length - 1) {
              // Handle Finish action
            } else {
              setState(() {
                _currentStep++;
              });
            }
          },
          child: Text(_currentStep == _steps.length - 1 ? 'Finish' : 'Next'),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perform Soil Test'),
      ),
      body: Theme(
        data: ThemeData(
          primarySwatch: Colors.green,
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < _steps.length - 1) {
              setState(() {
                _currentStep++;
              });
            } else {
              // Handle Finish action
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            }
          },
          steps: _steps,
        ),
      ),
    );
  }
}
