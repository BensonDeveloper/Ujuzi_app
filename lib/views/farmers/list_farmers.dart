import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ujuzi_app/utils/app_constants.dart';
import 'package:ujuzi_app/utils/shared_preference.dart';
import 'package:ujuzi_app/utils/style.dart';
import 'package:ujuzi_app/views/soiltests/step_form.dart';
import 'package:ujuzi_app/views/soiltests/incomplete_tests.dart';

class ListFarmers extends StatefulWidget {
  const ListFarmers({Key? key}) : super(key: key);

  @override
  _ListFarmersState createState() => _ListFarmersState();
}

class _ListFarmersState extends State<ListFarmers> {
  String userID = '';
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> farmersData = [];
  List<Map<String, dynamic>> filteredFarmersData = [];

  @override
  void initState() {
    super.initState();
    // Initialize the future in initState
    _fetchDataFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchUserData();
    await fetchFarmersData();
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

  Future<void> fetchFarmersData() async {
    String url = AppConstants.BASE_URL + AppConstants.farmer_url + userID;
    try {
      // Make a request to the API endpoint
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        // Extract farmers data
        final List<dynamic> farmers = data['data'];

        setState(() {
          farmersData = farmers.cast<Map<String, dynamic>>();
          filteredFarmersData = List.from(farmersData);
        });
      } else {
        // Handle error response
        print(
            "Failed to fetch farmers data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      // Handle network or other errors
      print("An error occurred: $error");
    }
  }

  void _filterFarmers(String query) {
    setState(() {
      filteredFarmersData = farmersData
          .where((farmer) =>
              farmer['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: AppConstants.appcolor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Farmers Registered',
                      style: hsSemiBold.copyWith(
                        fontSize: 16,
                        color: AppConstants.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(
                      color: AppConstants.white,
                      height: 20,
                      thickness: 1,
                    ),
                    Center(
                      child: Text(
                        farmersData.length.toString(),
                        style: hsSemiBold.copyWith(
                          fontSize: 30,
                          color: AppConstants.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterFarmers,
              decoration: InputDecoration(
                labelText: 'Search by name',
                labelStyle:
                    TextStyle(color: Colors.black), // Set label color to black
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppConstants.appsecondary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppConstants.appsecondary),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _fetchDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While fetching data, show a circular loading indicator
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  // If there's an error, display an error message
                  return Center(
                    child: Text('An error occurred: ${snapshot.error}'),
                  );
                } else {
                  // Once data is fetched, display the filtered list
                  return ListView.builder(
                    itemCount: filteredFarmersData.length,
                    itemBuilder: (context, index) {
                      final id = filteredFarmersData[index]['id'];
                      final firstName =
                          filteredFarmersData[index]['name'] ?? '';
                      final farmerNames =
                          (firstName.isEmpty) ? 'No Name' : '$firstName';
                      final location =
                          filteredFarmersData[index]['soil_test_status'];
                      final farmstatus =
                          filteredFarmersData[index]['farm_status'];

                      // Determine text color based on soil test status
                      Color textColor =
                          location == 'Complete' ? Colors.green : Colors.red;

                      return ListTile(
                        title: GestureDetector(
                          onTap: () {
                            // Navigate to the step form page passing the farmer id and name
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IncompleteTests(
                                    id: id, farmerName: farmerNames),
                              ),
                            );
                          },
                          child: Text(
                            '${index + 1}. $farmerNames - $location - $farmstatus.',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18, // Increase font size as desired
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
