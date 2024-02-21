import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ujuzi_app/utils/app_constants.dart';
import 'package:ujuzi_app/utils/shared_preference.dart';
import 'package:ujuzi_app/utils/style.dart';

class SoilTest extends StatefulWidget {
  const SoilTest({Key? key}) : super(key: key);

  @override
  _SoilTestState createState() => _SoilTestState();
}

class _SoilTestState extends State<SoilTest> {
  String userID = '';
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> soilTestsData = [];

  @override
  void initState() {
    super.initState();
    // Initialize the future in initState
    _fetchDataFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchUserData();
    await fetchSoilTestsData();
  }

  // Method to fetch user data from shared preferences
  // Method to fetch user data from shared preferences
  // Method to fetch user data from shared preferences
  Future<void> fetchUserData() async {
    // Fetch user data from shared preferences
    final userData = await UserPreferences.getUser();

    // Set user data if available
    setState(() {
      userID = userData['userId'] ?? '';
    });
  }

  Future<void> fetchSoilTestsData() async {
    String url = AppConstants.BASE_URL + AppConstants.soil_test_url + userID;
    try {
      // Make a request to the API endpoint

      http.Response response = await http.get(Uri.parse(url));

      print(url);

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);

        // Extract soil tests data
        final List<dynamic> soilTests = data['soil_tests'];

        setState(() {
          soilTestsData = soilTests.cast<Map<String, dynamic>>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While fetching data, show a circular loading indicator
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // If there's an error, display an error message
            return Center(
              child: Text('An error occurred: ${snapshot.error}'),
            );
          } else {
            // Once data is fetched, display the list
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              'Total Soil Tests Done',
                              style: hsSemiBold.copyWith(
                                fontSize: 16,
                                color: AppConstants.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            const Divider(
                              color: AppConstants.white,
                              height: 20,
                              thickness: 1,
                            ),
                            Center(
                              child: Text(
                                soilTestsData.length.toString(),
                                style: hsSemiBold.copyWith(
                                  fontSize: 30,
                                  color: AppConstants.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Farmers List:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedList(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    initialItemCount: soilTestsData.length,
                    itemBuilder: (context, index, animation) {
                      // Access the farmer names from the soil test object at the current index
                      final farmerNames = soilTestsData[index]['farmer_names'];
                      String unixTimestampString =
                          soilTestsData[index]['created_at'];
                      int unixTimestamp = int.parse(unixTimestampString);
                      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                          unixTimestamp * 1000);

                      return FadeTransition(
                        opacity: animation.drive(
                          CurveTween(curve: Curves.easeInOut),
                        ),
                        child: ListTile(
                          title: Text('${index + 1}. $farmerNames - $dateTime'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
