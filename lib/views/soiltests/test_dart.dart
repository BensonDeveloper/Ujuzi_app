import 'package:flutter/material.dart';

class YourWidget extends StatefulWidget {
  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  List<List<TextEditingController>> controllersList = [[]];
  int fieldGroupCount = 0;
  List<String> labels = ['N', 'K']; // Define labels here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: controllersList.length,
              itemBuilder: (context, index) {
                return buildTextFieldRow(index);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              submitSamples();
            },
            child: Text('Submit'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            controllersList.add([]);
            fieldGroupCount++;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildTextFieldRow(int groupIndex) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sample ${groupIndex + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    controllersList.removeAt(groupIndex);
                    fieldGroupCount--;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: getController(groupIndex, 0),
                    onChanged: (value) {
                      // Update your data model or list here
                    },
                    decoration: InputDecoration(
                      labelText: 'N',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: getController(groupIndex, 1),
                    decoration: InputDecoration(
                      labelText: 'K',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              // Add more Expanded widgets for other TextFields
            ],
          ),
          // Add more Rows for additional TextFields
        ],
      ),
    );
  }

  TextEditingController getController(int groupIndex, int textFieldIndex) {
    while (controllersList[groupIndex].length <= textFieldIndex) {
      controllersList[groupIndex].add(TextEditingController());
    }
    return controllersList[groupIndex][textFieldIndex];
  }

  void submitSamples() {
    List<Map<String, dynamic>> soilTest = []; // Array to hold sample data

    for (int i = 0; i < controllersList.length; i++) {
      Map<String, dynamic> sampleData = {
        'sample': i + 1,
        'N': controllersList[i][0].text,
        'K': controllersList[i][1].text,
      };
      soilTest.add(sampleData);
    }

    print("Soil Test:");
    print(soilTest);
  }
}
