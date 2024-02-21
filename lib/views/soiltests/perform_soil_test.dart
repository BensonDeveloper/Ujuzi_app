import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:im_stepper/stepper.dart';
import 'package:ujuzi_app/utils/app_constants.dart';
import 'package:ujuzi_app/utils/shared_preference.dart';

class PerformSoilTest extends StatefulWidget {
  const PerformSoilTest({Key? key}) : super(key: key);

  @override
  _PerformSoilTestState createState() => _PerformSoilTestState();
}

class _PerformSoilTestState extends State<PerformSoilTest> {
  String userID = '';
  int activeStep = 0;
  int upperBound = 2;
  bool isLoading = false;
  String? selectedFarmer;

  List<String> farmers = []; // List to store farmer names
  late Future<void> _fetchDataFuture;
  TextEditingController firstNameController = TextEditingController();

  List<Widget> _stepPages = [];

  @override
  void initState() {
    super.initState();
    selectedFarmer = farmers.isNotEmpty ? farmers.first : null;
    // Initialize the future in initState
    _fetchDataFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchUserData();
    setState(() {
      _stepPages = [
        _createFarmerPage(),
        _createFarmPage(),
        _soilTestBookPage(),
      ];
    });
  }

  // Method to fetch user data from shared preferences
  Future<void> fetchUserData() async {
    // Fetch user data from shared preferences
    final userData = await UserPreferences.getUser();

    // Set user data if available
    setState(() {
      userID = userData['userId'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Farmers App: $farmers');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Perform Soil Test'),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: _fetchDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        IconStepper(
                          icons: [
                            Icon(Icons.supervised_user_circle),
                            Icon(Icons.flag),
                            Icon(Icons.access_alarm),
                          ],
                          activeStep: activeStep,
                          onStepReached: (index) {
                            setState(() {
                              activeStep = index;
                            });
                          },
                        ),
                        header(),
                        Container(
                          height: MediaQuery.of(context).size.height *
                              0.65, // Adjust the height as needed
                          child: _stepPages[activeStep],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            previousButton(),
                            nextButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text(
                              'Sending data, please wait...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // Next button
  Widget nextButton() {
    return ElevatedButton(
      onPressed: () {
        if (activeStep < upperBound && !isLoading) {
          if (activeStep == 0) {
            _createFarmer();
          } else {
            setState(() {
              activeStep++;
            });
          }
        }
      },
      child: Text('Next'),
    );
  }

  Widget previousButton() {
    return ElevatedButton(
      onPressed: () {
        if (activeStep > 0 && !isLoading) {
          setState(() {
            activeStep--;
          });
        }
      },
      child: Text('Prev'),
    );
  }

  // Header
  Widget header() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              headerText(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String headerText() {
    switch (activeStep) {
      case 1:
        return 'CREATE FARM';

      case 2:
        return 'SOIL TESTS - BOOK';

      default:
        return 'CREATE FARMER';
    }
  }

  // Widget for creating farmer page
  Widget _createFarmerPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
              ),
            ),
            // Other input fields...
          ],
        ),
      ),
    );
  }

  // Widget for creating farm page
  Widget _createFarmPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Create Farm Page'),
          SizedBox(height: 20), // Add some space between the text and dropdown
          DropdownButton<String>(
            value: selectedFarmer,
            onChanged: (String? newValue) {
              setState(() {
                selectedFarmer = newValue;
              });
            },
            items: farmers.map<DropdownMenuItem<String>>((String farmer) {
              return DropdownMenuItem<String>(
                value: farmer,
                child: Text(farmer),
              );
            }).toList(),
          ),
          SizedBox(
              height: 20), // Add space between dropdown and list of farmers
          Text(
            'Farmers: ${farmers.join(", ")}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Widget for soil test book page
  Widget _soilTestBookPage() {
    return Center(
      child: Text('Soil Test Book Page Content'),
    );
  }

  // Function to send data to create farmer endpoint
  Future<void> _createFarmer() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Prepare the data to be sent
      Map<String, dynamic> data = {
        'firstName': firstNameController.text,
        // Add other fields here as needed
      };

      // Make the HTTP POST request
      var response = await http.post(
        Uri.parse('https://example.com/create-farmer'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('Response status code: ${response.statusCode}');

      if (response.statusCode != 200) {
        // Fetch farmers if the farmer is not created successfully
        await _fetchFarmers(); // Await the completion of _fetchFarmers()
        // Update UI after fetching farmers' data
        setState(() {
          isLoading = false;
          activeStep++;
        });
      } else {
        // If farmer is successfully created, do not fetch updated farmers' data here
        setState(() {
          isLoading = false;
          // Show an error message or handle it as per your requirement
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        // Handle errors
      });
    }
  }

  // Function to fetch farmers data
  Future<void> _fetchFarmers() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Make the HTTP GET request to fetch farmers data
      String url = AppConstants.BASE_URL + AppConstants.farmer_url + userID;

      print('Fetching farmers data from: $url');
      http.Response response = await http.get(Uri.parse(url));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the response JSON
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> farmersData = jsonResponse['data'];
        List<String> farmerNames = [];

        for (var farmer in farmersData) {
          String fullName = '${farmer['firstname']} ${farmer['lastname']}';
          farmerNames.add(fullName);
          print(fullName); // Print each farmer's full name
        }

        setState(() {
          farmers = farmerNames; // Update the farmers list with fetched data
          isLoading = false;
          print('Farmers fetched successfully an stet updated: $farmers');
        });
      } else {
        setState(() {
          isLoading = false;
          farmers = []; // Ensure farmers list is empty if there's an error
          print('we had problems featich');
          // Show an error message or handle it as per your requirement

          print('farmers is empty');
        });
      }
    } catch (e) {
      print('Error fetching farmers: $e');
      setState(() {
        isLoading = false;
        farmers = []; // Ensure farmers list is empty if there's an error
        // Handle errors
      });
    }
  }
}
