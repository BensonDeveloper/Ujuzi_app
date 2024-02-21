import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ujuzi_app/utils/app_constants.dart';
import 'package:ujuzi_app/utils/custom_painter.dart';
import 'package:ujuzi_app/utils/shared_preference.dart';
import 'package:ujuzi_app/utils/style.dart';
import 'package:ujuzi_app/views/farmers/list_farmers.dart';
import 'package:ujuzi_app/views/profile/profile.dart';
//import 'package:ujuzi_app/views/soiltests/perform_soil_test.dart';
import 'package:ujuzi_app/views/soiltests/soil_test.dart';
import 'package:http/http.dart' as http;
import 'package:ujuzi_app/views/soiltests/step_form.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String userID = '';
  String userName = '';
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> soilTestsData = [];
  List<Map<String, dynamic>> farmersData = [];
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  // Titles for the app bar based on the page index
  final List<String> _appBarTitles = [
    'Dashboard',
    'Soil Test',
    'Farmers',
    'Profile'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the future in initState
    _fetchDataFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchUserData();
    await fetchSoilTestsData();
    await fetchFarmersData();
  }

  // Method to fetch user data from shared preferences
  Future<void> fetchUserData() async {
    // Fetch user data from shared preferences
    final userData = await UserPreferences.getUser();

    // Set user data if available
    setState(() {
      userID = userData['userId'] ?? '';
      userName = userData['userName'] ?? '';
    });
  }

  Future<void> fetchSoilTestsData() async {
    String url = AppConstants.BASE_URL + AppConstants.soil_test_url + userID;
    try {
      // Make a request to the API endpoint
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button icon
        title: Text(
          _appBarTitles[_selectedIndex],
          style: hsSemiBold.copyWith(fontSize: 25, color: AppConstants.white),
        ), // Dynamic app bar title
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make app bar transparent
        flexibleSpace: CustomPaint(
          size: Size(
              MediaQuery.of(context).size.width, 150), // Increase height here
          painter:
              CustomAppBarPainter(height: 10), // Adjust the height as needed
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          HomeContent(
            userName: userName,
            soilTestsData: soilTestsData,
            farmersData: farmersData,
          ), // Pass soilTestsData and farmersData here
          SoilTest(),
          ListFarmers(),
          Profile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'Soil Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Farmers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: AppConstants.appcolor,
        selectedItemColor: AppConstants.appsecondary,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<Map<String, dynamic>> soilTestsData;
  final List<Map<String, dynamic>> farmersData;
  final String userName;

  const HomeContent({
    Key? key,
    required this.soilTestsData,
    required this.farmersData,
    required this.userName, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String soilTestsDone = soilTestsData.length.toString();
    final String farmersRegistered = farmersData.length.toString();
    final String? totalEarnings = '0'; // Define totalEarnings here

    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Get the current time
    final currentTime = DateTime.now();

    // Define the message based on the time of the day
    String greetingMessage = '';
    if (currentTime.hour < 12) {
      greetingMessage = 'Good Morning,';
    } else if (currentTime.hour < 18) {
      greetingMessage = 'Good Afternoon,';
    } else {
      greetingMessage = 'Good Evening,';
    }

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            greetingMessage + userName,
            style: hsRegular.copyWith(fontSize: 25, color: AppConstants.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildTotalEarningsCard(totalEarnings), // Pass totalEarnings here
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDashboardItem(
                icon: Icons.science,
                label: 'Soil Tests Done',
                value: soilTestsDone,
                color: AppConstants.appcolor,
              ),
              _buildDashboardItem(
                icon: Icons.people,
                label: 'Farmers Registered',
                value: farmersRegistered,
                color: AppConstants.appcolor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            splashColor: AppConstants.transparent,
            highlightColor: AppConstants.transparent,
            onTap: () {
              // Action Here
              // Navigate to the PerformSoilTest page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThreeStepPage()),
                //MaterialPageRoute(builder: (context) => YourWidget()),
              );
            },
            child: Container(
              width: width *
                  0.9, // Fixed a typo here, changed "width 1" to "width * 0.9"
              height: height / 15,
              decoration: BoxDecoration(
                color: AppConstants.appcolor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  "Perform Soil Test",
                  style: hsSemiBold.copyWith(
                    fontSize: 16,
                    color: AppConstants.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalEarningsCard(String? totalEarnings) {
    // Accept totalEarnings as parameter
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.attach_money,
                size: 48, color: AppConstants.appcolor),
            SizedBox(height: 16),
            const Text(
              'Total Earnings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '\Ksh $totalEarnings', // Use totalEarnings here
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.appcolor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
