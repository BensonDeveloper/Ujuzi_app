import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:ujuzi_app/utils/app_constants.dart';
import 'package:ujuzi_app/utils/custom_painter.dart';

import 'package:ujuzi_app/utils/shared_preference.dart';
import 'package:ujuzi_app/utils/style.dart';
import 'package:ujuzi_app/views/dashboard/dashboard.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ujuzi_app/views/soiltests/step_form.dart';

class IncompleteTests extends StatefulWidget {
  final int id;
  final String farmerName;

  const IncompleteTests({Key? key, required this.id, required this.farmerName})
      : super(key: key);

  @override
  _IncompleteTestsState createState() => _IncompleteTestsState();
}

class _IncompleteTestsState extends State<IncompleteTests> {
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late Future<void> _fetchDataFuture;
  String userID = '';
  int _currentStep = 1;
  String _textInput1 = '';
  String _textInput2 = '';
  late String _selectedFarmer; // Define _selectedFarmer as a String
  String? _selectedCrop;
  late int _farmerID;
  String? _selectedFarm;
  List<String> _selectedCrops = [];
  bool areFieldsFilled() {
    // Check if any text field is empty
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        identifierController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        selectedGender == null) {
      return false; // Return false if any text field is empty
    }
    return true; // All text fields are filled
  }

  String? selectedGender;
  bool __isLoading = false;
  bool _step1Submitted = false; // Flag to track if Step 1 has been submitted
  bool _step2Submitted = false; // Flag to track if Step 1 has been submitted
  List<String> farmers = []; // List to store farmer names
  List<Map<String, dynamic>> crops = [];
  List<Map<String, dynamic>> farms = [];
  List<Map<String, dynamic>> farmerslist = [];
  List<Map<String, dynamic>> wards = []; // List to hold ward data
  String? selectedWard; // Currently selected ward
  List<Map<String, dynamic>> cigGroups = []; // List to hold cig group data
  String? selectedCigGroup; // Currently selected cig group

  //SOil samples
  List<List<TextEditingController>> controllersList = [[]];
  int fieldGroupCount = 0;
  List<String> labels = ['N', 'P', 'K', 'EC', 'TEMP', 'MOI', 'PH'];

//Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthYearController = TextEditingController();
  final TextEditingController yearsFarmedController1 = TextEditingController();
  final TextEditingController totallandsize = TextEditingController();
  final TextEditingController totallandfarmed = TextEditingController();
  final TextEditingController farmname = TextEditingController();
  TextEditingController locationController = TextEditingController();
  DateTime? _selectedDate; // Variable to store the selected date
// Declare ScrollController
  ScrollController _scrollController = ScrollController();
  List<Widget> textFields = [];
  // int fieldGroupCount = 0;
  // // List<List<TextEditingController>> controllersList = [[]];

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.id.toString());
    _nameController = TextEditingController(text: widget.farmerName);
    _fetchDataFuture = _initializeData();
    _selectedFarmer = widget.id
        .toString(); // Initialize _selectedFarmer with the ID of the selected farmer
    _requestLocationPermission();
    _getCurrentLocation();
  }

  void _searchLocation() async {}

  void _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      // Handle denied or restricted permission
      // You may show a dialog to inform the user
    }
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark placemark = placemarks.first;
      String locationName =
          "${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";

      setState(() {
        locationController.text = locationName;
      });

      print("Location: $locationName");
    } catch (e) {
      print("Location Error: $e");
    }
  }

  Future<void> _initializeData() async {
    await fetchUserData();
    await fetchCropData();

    await fetchFarmData();
  }

  Future<void> fetchCropData() async {
    String url = AppConstants.BASE_URL + AppConstants.crops_url + userID;
    try {
      // Make a request to the API endpoint
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        print('Response body: ${response.body}');

        // Extract soil tests data
        final List<dynamic> cropData = data['crops'];

        setState(() {
          crops = cropData.cast<Map<String, dynamic>>();
        });
      } else {
        // Handle error response
        print(
            "Failed to fetch soil tests data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      // Handle network or other errors
      print("An error occurred: $error");
    }
  }

  Future<void> fetchFarmData() async {
    String url =
        AppConstants.BASE_URL + AppConstants.get_farm_url + _selectedFarmer;

    print(url);
    try {
      // Make a request to the API endpoint
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        print('Response Farms body: ${response.body}');

        // Extract soil tests data
        final List<dynamic> farmData = data['data'];

        setState(() {
          farms = farmData.cast<Map<String, dynamic>>();
        });

        print('Response Farms : ${farms}');
      } else {
        // Handle error response
        print(
            "Failed to fetch soil tests data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      // Handle network or other errors
      print("An error occurred: $error");
    }
  }

  Future<void> _submitStep1() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Submission'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Do you want to submit the data with the following values?'),
                Text('First Name: ${firstNameController.text}'),
                Text('Middle Name: ${middleNameController.text}'),
                Text('Last Name: ${lastNameController.text}'),
                Text('ID No: ${identifierController.text}'),
                Text('Phone No: ${phoneNumberController.text}'),
                Text('Gender: $selectedGender'),
                // Text('First Name: ${firstNameController.text}'),
                // Text('First Name: ${firstNameController.text}'),
                // Text('First Name: ${firstNameController.text}'),
                // Add other fields here as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Dismiss the dialog and return false
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Dismiss the dialog and return true
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      // User confirmed, proceed with submission
      setState(() {
        __isLoading = true;
      });
      print('Submitting data from Step 1 to API:');

      // Format the DateTime object as a string
      String formattedDate = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : '';

      try {
        // Prepare the data to be sent
        Map<String, dynamic> data = {
          'firstName': firstNameController.text,
          'last_name': lastNameController.text,
          'surname': middleNameController.text,
          'id_number': identifierController.text,
          'calling_code': '+254',
          'phone_number': phoneNumberController.text,
          'phone_digits': phoneNumberController.text,
          'email': emailController.text,
          'gender': selectedGender,
          'age': formattedDate,
          'farmer_cig_group': selectedCigGroup,
          'agent_assigned': userID,

          // Add other fields here as needed
        };

        print('Data: $data');

        // Make the HTTP POST request
        var response = await http.post(
          Uri.parse(AppConstants.BASE_URL + AppConstants.create_farmer_url),
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        print('Response status code: ${response.statusCode}');

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          String message = responseData['message'];
          int statusCode = int.parse(responseData['statuscode'].toString());

          if (statusCode == 200) {
            await _fetchFarmers(); // Await the completion of _fetchFarmers()

            setState(() {
              __isLoading = false;
              _step1Submitted = true; // Set the flag to true
              _nextStep(); // Move to the next step after the async operation completes
            });
            //Only go to the next step if this is true
            // If farmer is successfully created, fetch farmers and move to next step
            //await _fetchFarmers(); // Await the completion of _fetchFarmers()

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text('$message'),
              ),
            );
          } else {
            setState(() {
              __isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('$message'),
              ),
            );
          }
        } else {
          // Show an error message or handle it as per your requirement
          setState(() {
            __isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error occured creating farmer. Try Again'),
            ),
          );
        }
      } catch (e) {
        setState(() {
          __isLoading = false;
        });
        print('Error: $e'); // Print the error message to the console
      }
    }
  }

  Future<void> fetchWardsData() async {
    String url = AppConstants.BASE_URL + AppConstants.wards_url + userID;
    try {
      // Make a request to the API endpoint
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse JSON response
        List<dynamic> data = jsonDecode(response.body)['org']['wards'];
        setState(() {
          // Update the list of wards
          wards = data.cast<Map<String, dynamic>>();
        });
      } else {
        // Handle error response
        print(
            "Failed to fetch soil tests data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      // Handle network or other errors
      print("An error occurred: $error");
    }
  }

  // Function to fetch farmers data
  Future<void> _fetchFarmers() async {
    setState(() {
      __isLoading = true;
    });

    try {
      // Make the HTTP GET request to fetch farmers data
      String url = AppConstants.BASE_URL + AppConstants.farmer_url + userID;

      print('Fetching farmers data from: $url');
      http.Response response = await http.get(Uri.parse(url));

      print('Response Fetchning farmers: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic>? data =
            json.decode(response.body) as Map<String, dynamic>?;
        print('Farmers body: ${response.body}');

        if (data != null && data.containsKey('data')) {
          // Extract soil tests data
          final List<dynamic> farmersData = data['data'];

          setState(() {
            farmerslist = farmersData.cast<Map<String, dynamic>>();
            __isLoading =
                false; // Set isLoading to false only after data is fetched successfully
          });
        } else {
          // Handle null data or missing 'data' field in the response
          setState(() {
            __isLoading = false;
            // Show an error message or handle it as per your requirement
          });
        }
      } else {
        setState(() {
          __isLoading = false;
          // Show an error message or handle it as per your requirement
        });
      }
    } catch (e) {
      print('Error fetching farmers: $e');
      setState(() {
        __isLoading = false;
        // Handle errors
      });
    }

    // If no farmer is fetched, add "Benson Mitigoa" and "Mary Jane"
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

  Future<void> _submitStep2() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Submission'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Do you want to submit the data with the following values?'),
                Text('Farmer: $_selectedFarmer'),
                Text('Farm  Name: ${farmname.text}'),
                Text('Totall Farm Size(Acres): ${totallandsize.text}'),
                Text('Total Farmed Area(Acres): ${totallandfarmed.text}'),
                Text('Crops: $_selectedCrops'),
                //Text('Location: $locationController.text'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Dismiss the dialog and return false
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Dismiss the dialog and return true
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      setState(() {
        __isLoading = true;
      });
      print('Submitting data from Step 1 to API:');

      // Convert the List<String> to a List<dynamic>
      List<dynamic> cropsArray =
          _selectedCrops.map((crop) => crop.toString()).toList();

      try {
        //Prepare the data to be sent
        Map<String, dynamic> data = {
          'agent_assigned': userID,
          'farmer_id': _selectedFarmer,
          'mycrops': cropsArray,
          'locality': '',
          'alias': farmname.text,
          'size': totallandsize.text,
          'size_farmed': totallandfarmed.text,
          'manager_phone': '',
          'manager': '',
          'country': 'Kenya',
          'administrative_area_level_1': '',
          'administrative_area_level_2': '',
          'administrative_area_level_3': '',
          'latitude': '',
          'longitude': '',
        };

        print('Data: $data');

        // Make the HTTP POST request
        var response = await http.post(
          Uri.parse(AppConstants.BASE_URL + AppConstants.create_farm_url),
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        print('Response status code: ${response.statusCode}');
        print('Response status code: ${response.body}');

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          String message = responseData['message'];
          int statusCode = int.parse(responseData['statuscode'].toString());

          if (statusCode == 200) {
            setState(() {
              __isLoading = false;
              _step2Submitted = true; // Set the flag to true
              _nextStep(); // Move to the next step after the async operation completes
            });
            //Only go to the next step if this is true
            // If farmer is successfully created, fetch farmers and move to next step

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text('$message'),
              ),
            );
          } else {
            setState(() {
              __isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('$message'),
              ),
            );
          }
        } else {
          // Show an error message or handle it as per your requirement
          setState(() {
            __isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error occured creating farmer. Try Again'),
            ),
          );
        }
      } catch (e) {
        setState(() {
          __isLoading = false;
        });
        print('Error: $e');
      }
    }
  }

  void _nextStep() {
    setState(() {
      // if (_currentStep == 1) {
      //   if (_currentStep == 1 && !_step1Submitted && !__isLoading) {
      //     // Call _submitStep1() only if it hasn't been submitted yet
      //     if (areFieldsFilled()) {
      //       _submitStep1();
      //     } else {
      //       // Show an error message or prevent navigation
      //       print('Please fill in all fields before proceeding.');

      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(
      //           backgroundColor: Colors.red,
      //           content: Text(
      //               'Please fill in all fields required before proceeding.'),
      //         ),
      //       );
      //     }
      //   } else if (_currentStep < 3 && !__isLoading) {
      //     _currentStep++;
      //     // Reset the flag if moving to the next step
      //     _step1Submitted = false;
      //   }
      // } else
      if (_currentStep == 1) {
        if (_currentStep == 1 && !_step2Submitted && !__isLoading) {
          // Call _submitStep1() only if it hasn't been submitted yet
          _submitStep2();
        } else if (_currentStep < 2 && !__isLoading) {
          _currentStep++;
          // Reset the flag if moving to the next step
          _step2Submitted = false;
        }
      }
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 1) {
        _currentStep--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (farms.isNotEmpty) {
      // Scaffold body
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Step 3: Add Samples',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: DropdownButtonFormField<String>(
                          value: widget.id.toString(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedFarmer = newValue ?? '';
                            });
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: widget.id.toString(),
                              child: Text(widget.farmerName),
                            ),
                          ],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          icon:
                              Icon(Icons.arrow_drop_down, color: Colors.black),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: DropdownButtonFormField<String>(
                          value: _selectedFarm,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedFarm = newValue;
                            });
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text('Select a Farm'),
                            ),
                            ...farms.map<DropdownMenuItem<String>>(
                              (farmer) {
                                final firstName = farmer['alias'] ?? '';
                                final name = (firstName.isEmpty)
                                    ? 'No Name'
                                    : '$firstName';
                                return DropdownMenuItem<String>(
                                  value: farmer['soil_test_id'].toString(),
                                  child: Text(name),
                                );
                              },
                            ).toList(),
                          ],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          icon:
                              Icon(Icons.arrow_drop_down, color: Colors.black),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: controllersList.length,
                        itemBuilder: (context, index) {
                          return buildTextFieldRow(index);
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            fieldGroupCount++;
                            controllersList.add([]);
                          });
                        },
                        child: Text('Add Sample'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          for (int i = 1; i <= 1; i++)
                            Icon(
                              _currentStep >= i
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              color: _currentStep >= i
                                  ? AppConstants.appcolor
                                  : AppConstants.appsecondary,
                            ),
                        ],
                      ),
                      Spacer(),
                      if (_currentStep < 1)
                        TextButton(
                          onPressed: _nextStep,
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: AppConstants.appsecondary,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      if (_currentStep == 1)
                        TextButton(
                          onPressed: () {
                            if (controllersList.length >= 1) {
                              print('Data can be sent');
                              submitSamplesWithFarm();
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Insufficient Samples'),
                                    content: const Text(
                                        'Please add at least 6 samples before finishing.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text('Finish'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (__isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppConstants.appsecondary),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Loading... Please wait',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // Step 2
                      if (_currentStep == 1) ...[
                        // Step Two
                        Container(
                          // height: MediaQuery.of(context).size.height -
                          //     180, // Adjust the height as needed
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Add Farm',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        24, // Adjust the font size as needed
                                    fontWeight: FontWeight
                                        .bold, // Adjust the font weight as needed
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Add your other widgets here

                                const SizedBox(height: 20),

                                const Text(
                                  'Select Farmer', // Label text
                                  style: TextStyle(
                                    fontSize:
                                        16, // Adjust the font size as needed
                                    fontWeight: FontWeight
                                        .bold, // Adjust the font weight as needed
                                    color: Colors
                                        .black, // Adjust the color as needed
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: DropdownButtonFormField<String>(
                                    value: widget.id
                                        .toString(), // Set the initial value to the farmer's ID_selectedFarmer, // Set initial value to widget.id
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedFarmer = newValue ??
                                            ''; // Handle null by providing a default value
                                      });
                                    },
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: widget.id
                                            .toString(), // Set the value to the farmer's ID
                                        child: Text(widget
                                            .farmerName), // Set the display text to the farmer's name
                                      ),
                                    ],
                                    // Style for the dropdown button
                                    style: TextStyle(
                                      color: Colors
                                          .black, // Text color of the dropdown button
                                      fontSize: 16, // Font size of the text
                                      // You can add more styles as needed
                                    ),
                                    // Decoration for the dropdown button's dropdown arrow icon
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: Colors.black),
                                    // Decoration for the dropdown button itself
                                    decoration: InputDecoration(
                                      border:
                                          OutlineInputBorder(), // Add border if needed
                                      // You can add more decoration options as needed
                                    ),
                                  ),
                                ),

                                SizedBox(height: 10.0),

                                Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: TextField(
                                    controller: farmname,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Farm Name',
                                    ),
                                  ),
                                ),

                                SizedBox(height: 10),
                                Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: TextField(
                                    controller: locationController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Location',
                                    ),
                                  ),
                                ),

                                // ./
                                //Total land size
                                SizedBox(height: 10.0),
                                // Last name
                                Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: TextField(
                                    controller: totallandsize,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Total Land Size',
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                // Last name
                                Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: TextField(
                                    controller: totallandfarmed,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Land Size Farmed',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Select Crop', // Label text
                                  style: TextStyle(
                                    fontSize:
                                        16, // Adjust the font size as needed
                                    fontWeight: FontWeight
                                        .bold, // Adjust the font weight as needed
                                    color: Colors
                                        .black, // Adjust the color as needed
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      MultiSelectDialogField(
                                        items: crops.map((crop) {
                                          return MultiSelectItem<String>(
                                            crop['id'].toString(),
                                            crop['name'].toString(),
                                          );
                                        }).toList(),
                                        initialValue: _selectedCrops,
                                        title: Text('Select crop'),
                                        buttonText: Text('Select crop'),
                                        onConfirm: (values) {
                                          setState(() {
                                            _selectedCrops =
                                                values.cast<String>();
                                          });
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                          'Selected Crops: ${_selectedCrops.join(", ")}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Step 3
                      if (_currentStep == 2) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Step 3: Add Samples',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: controllersList.length,
                                itemBuilder: (context, index) {
                                  return buildTextFieldRow(index);
                                },
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    fieldGroupCount++;
                                    controllersList.add([]);
                                  });
                                },
                                child: Text('Add Sample'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page Indicators (to the left)
                      Row(
                        children: [
                          for (int i = 1; i <= 2; i++)
                            Icon(
                              _currentStep >= i
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              color: _currentStep >= i
                                  ? AppConstants.appcolor
                                  : AppConstants.appsecondary,
                            ),
                        ],
                      ),
                      // Spacer to push buttons to the right
                      Spacer(),
                      // Buttons (to the right)
                      if (_currentStep < 2)
                        TextButton(
                          onPressed: _nextStep,
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: AppConstants.appsecondary,
                              fontSize: 18, // Adjust the font size as needed
                            ),
                          ),
                        ),
                      if (_currentStep == 2)
                        TextButton(
                          onPressed: () {
                            if (controllersList.length >= 1) {
                              print('Data can be sent');
                              submitSamples();
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Insufficient Samples'),
                                    content: const Text(
                                        'Please add at least 6 samples before finishing.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text('Finish'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (__isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppConstants.appsecondary),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Loading... Please wait',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
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
                color: Colors.red, // Set icon color to red
                onPressed: () {
                  setState(() {
                    controllersList
                        .removeLast(); // Remove the last added sample
                    groupIndex--; // Decrement the sample count
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
                      labelText: 'P',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: getController(groupIndex, 2),
                    decoration: InputDecoration(
                      labelText: 'K',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: getController(groupIndex, 3),
                    decoration: InputDecoration(
                      labelText: 'EC',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: getController(groupIndex, 4),
                    decoration: InputDecoration(
                      labelText: 'TEMP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: getController(groupIndex, 5),
                    decoration: InputDecoration(
                      labelText: 'MOI',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: getController(groupIndex, 6),
                    decoration: InputDecoration(
                      labelText: 'PH',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  Future<void> submitSamples() async {
    setState(() {
      __isLoading = true;
    });
    List<Map<String, dynamic>> soilTest = []; // Array to hold sample data

    for (int i = 0; i < controllersList.length; i++) {
      Map<String, dynamic> sampleData = {
        "sample": i + 1,
        "user_id": userID,
        "N": controllersList[i][0].text,
        "P": controllersList[i][1].text,
        "K": controllersList[i][2].text,
        "EC": controllersList[i][3].text,
        "TEMP": controllersList[i][4].text,
        "MOI": controllersList[i][5].text,
        "PH": controllersList[i][6].text,
      };
      soilTest.add(sampleData);
    }

    print("Soil Test:");
    print(soilTest);

    try {
      // Make the HTTP POST request
      var response = await http.post(
        Uri.parse(
            AppConstants.BASE_URL + AppConstants.create_soil_test_samples_url),
        body: jsonEncode(soilTest),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle success
        print('Samples submitted successfully');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Successfully Performed soil test'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pop(); // Pop the current page
                    // Redirect to the dashboard page
                    // You can use Navigator.pushReplacement to replace the current page with the dashboard page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Dashboard()),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle error
        print('Failed to submit samples');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to submit samples'),
          ),
        );
      }

      setState(() {
        __isLoading = false;
      });
    } catch (e) {
      setState(() {
        __isLoading = false;
        // Handle errors
        print('Error submitting samples: $e');
      });
    }
  }

  Future<void> submitSamplesWithFarm() async {
    setState(() {
      __isLoading = true;
    });
    List<Map<String, dynamic>> soilTest = []; // Array to hold sample data

    for (int i = 0; i < controllersList.length; i++) {
      Map<String, dynamic> sampleData = {
        "sample": i + 1,
        "user_id": userID,
        "soil_test_id": _selectedFarm,
        "N": controllersList[i][0].text,
        "P": controllersList[i][1].text,
        "K": controllersList[i][2].text,
        "EC": controllersList[i][3].text,
        "TEMP": controllersList[i][4].text,
        "MOI": controllersList[i][5].text,
        "PH": controllersList[i][6].text,
      };
      soilTest.add(sampleData);
    }

    print("Soil Test:");
    print(soilTest);

    // setState(() {
    //   __isLoading = false;
    // });

    try {
      // Make the HTTP POST request
      var response = await http.post(
        Uri.parse(AppConstants.BASE_URL + AppConstants.complete_soil_test_url),
        body: jsonEncode(soilTest),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle success
        print('Samples submitted successfully');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Successfully Performed soil test'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pop(); // Pop the current page
                    // Redirect to the dashboard page
                    // You can use Navigator.pushReplacement to replace the current page with the dashboard page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Dashboard()),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle error
        print('Failed to submit samples');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to submit samples'),
          ),
        );
      }

      setState(() {
        __isLoading = false;
      });
    } catch (e) {
      setState(() {
        __isLoading = false;
        // Handle errors
        print('Error submitting samples: $e');
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
