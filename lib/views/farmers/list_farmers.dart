import 'package:flutter/material.dart';

class ListFarmers extends StatefulWidget {
  const ListFarmers({Key? key}) : super(key: key);

  @override
  _ListFarmersState createState() => _ListFarmersState();
}

class _ListFarmersState extends State<ListFarmers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'FArmers Center of Page',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
