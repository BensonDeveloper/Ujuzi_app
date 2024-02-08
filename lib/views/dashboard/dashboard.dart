import 'package:flutter/material.dart';
import 'package:ujuzi_app/utils/app_constants.dart';
import 'package:ujuzi_app/utils/custom_painter.dart';
import 'package:ujuzi_app/utils/style.dart';
import 'package:ujuzi_app/views/farmers/list_farmers.dart';
import 'package:ujuzi_app/views/profile/profile.dart';
import 'package:ujuzi_app/views/soiltests/perform_soil_test.dart';
import 'package:ujuzi_app/views/soiltests/soil_test.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  // Titles for the app bar based on the page index
  final List<String> _appBarTitles = [
    'Dashboard',
    'Soil Test',
    'Farmers',
    'Profile'
  ];

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
          HomeContent(),
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
  final int totalEarnings = 5000;
  final int soilTestsDone = 20;
  final int farmersRegistered = 100;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Good Afternoon,John Doe',
            style: hsRegular.copyWith(fontSize: 25, color: AppConstants.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildTotalEarningsCard(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDashboardItem(
                icon: Icons.science,
                label: 'Soil Tests Done',
                value: '$soilTestsDone',
                color: AppConstants.appcolor,
              ),
              _buildDashboardItem(
                icon: Icons.people,
                label: 'Farmers Registered',
                value: '$farmersRegistered',
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
                MaterialPageRoute(builder: (context) => PerformSoilTest()),
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

  Widget _buildTotalEarningsCard() {
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
              '\Ksh $totalEarnings',
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
