import 'package:flutter/material.dart';

class SoilTest extends StatefulWidget {
  const SoilTest({Key? key}) : super(key: key);

  @override
  _SoilTestState createState() => _SoilTestState();
}

class _SoilTestState extends State<SoilTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Soil Test Center of Page',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
