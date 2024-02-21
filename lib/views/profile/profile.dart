import 'package:flutter/material.dart';
import 'package:ujuzi_app/utils/app_constants.dart';
import 'package:ujuzi_app/utils/style.dart';
import 'package:ujuzi_app/utils/shared_preference.dart';
import 'package:ujuzi_app/views/splash_screen/login_screen.dart'; // Correct import path for LoginScreen

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Initialize user data with default values
  String userName = '';
  String userEmail = '';
  String userPhoneNumber = '';
  String userBio = 'Ujuzikilimo Agent.';

  // Method to show a confirmation dialog for logout
  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Clear shared preferences
                await UserPreferences.clearUser();

                // Navigate to the login screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch user data from shared preferences when the widget is initialized
    fetchUserData();
  }

  // Method to fetch user data from shared preferences
  void fetchUserData() async {
    // Fetch user data from shared preferences
    final userData = await UserPreferences.getUser();

    // Set user data if available
    setState(() {
      userName = userData['userName'] ?? '';
      userEmail = userData['userEmail'] ?? '';
      userPhoneNumber = userData['userPhone'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/profile_pic.jpg'),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              color: AppConstants.appcolor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Information',
                      style: hsRegular.copyWith(
                          fontSize: 25, color: AppConstants.white),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        'Name',
                        style: hsRegular.copyWith(
                            fontSize: 18, color: AppConstants.white),
                      ),
                      subtitle: Text(userName,
                          style: hsRegular.copyWith(
                              fontSize: 14, color: AppConstants.black)),
                    ),
                    ListTile(
                      title: Text('Email',
                          style: hsRegular.copyWith(
                              fontSize: 18, color: AppConstants.white)),
                      subtitle: Text(userEmail,
                          style: hsRegular.copyWith(
                              fontSize: 14, color: AppConstants.black)),
                    ),
                    ListTile(
                      title: Text('Phone Number',
                          style: hsRegular.copyWith(
                              fontSize: 18, color: AppConstants.white)),
                      subtitle: Text(userPhoneNumber,
                          style: hsRegular.copyWith(
                              fontSize: 14, color: AppConstants.black)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              color: AppConstants.appcolor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User Bio',
                        style: hsRegular.copyWith(
                            fontSize: 20, color: AppConstants.white)),
                    Divider(),
                    Text(userBio,
                        style: hsRegular.copyWith(
                            fontSize: 14, color: AppConstants.black)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _showLogoutConfirmationDialog,
                child: Text('Logout',
                    style: hsRegular.copyWith(
                        fontSize: 14, color: AppConstants.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
