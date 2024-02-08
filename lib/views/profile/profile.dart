import 'package:flutter/material.dart';
import 'package:ujuzi_app/utils/app_constants.dart';
import 'package:ujuzi_app/utils/style.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Dummy user data
  String userName = 'John Doe';
  String userEmail = 'johndoe@example.com';
  String userPhoneNumber = '+2544567890';
  String userBio = 'Ujuzikilimo Agent.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/profile_pic.jpg'),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              color: AppConstants.appcolor, // Set card color to green
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
              color: AppConstants.appcolor, // Set card color to green
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
                onPressed: () {
                  // TODO: Implement logout functionality
                },
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
