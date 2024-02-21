// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:ujuzi_app/utils/app_constants.dart';
import 'package:ujuzi_app/utils/images.dart';
import 'package:ujuzi_app/utils/shared_preference.dart';
import 'package:ujuzi_app/utils/style.dart';
import 'package:ujuzi_app/views/dashboard/dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// text Controllers
TextEditingController emailController = TextEditingController();
TextEditingController passController = TextEditingController();

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  bool _isLoading = false;
  bool _loggedIn = false; // New variable to track login status

  @override
  void initState() {
    super.initState();
    checkLoggedIn(); // Check if user is already logged in
  }

  void checkLoggedIn() async {
    _loggedIn = await UserPreferences.isLoggedIn();
    if (_loggedIn) {
      // If user is already logged in, navigate to dashboard
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return const Dashboard();
        },
      ));
    }
  }

  void login(String email, String pass) async {
    setState(() {
      _isLoading = true;
    });

    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.BASE_URL + AppConstants.login_url),
        body: {
          'email': email,
          'password': pass,
        },
      );

      if (response.statusCode == 200) {
        // Save Info
        saveUserData(response.body);
        // Clear form fields
        emailController.clear();
        passController.clear();
        // Push to dashboard
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return const Dashboard();
          },
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Invalid Credentials Email or Password. Try Again'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void saveUserData(String jsonResponse) async {
    // Parse the JSON string
    Map<String, dynamic> userData = jsonDecode(jsonResponse);

    // Extract user information
    String userId = userData['user']['id'].toString();
    String userName = userData['user']['name'];
    String userEmail = userData['user']['email'];
    String userPhone = userData['user']['phone'];

    // Save user data
    await UserPreferences.saveUser(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
    );
  }

  bool _obscureText = true;

  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: width / 36, vertical: height / 36),
        child: Form(
          key: _formKey, // Assign the key to the form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height / 12),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      child: Image.asset(
                        Images.uk_logo,
                        height: height / 3,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Enter your email address and password to login",
                      style: hsSemiBold.copyWith(
                          fontSize: 12, color: AppConstants.appcolor),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height / 16),
              TextFormField(
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // You can add more complex validation here
                  return null;
                },
                style: hsMedium.copyWith(
                    fontSize: 16, color: AppConstants.textgray),
                decoration: InputDecoration(
                  hintStyle: hsMedium.copyWith(
                      fontSize: 16, color: AppConstants.textgray),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      UjuziSvgimage.lock,
                      height: height / 36,
                      colorFilter: const ColorFilter.mode(
                          AppConstants.textgray, BlendMode.srcIn),
                    ),
                  ),
                  hintText: "Email ID or Username",
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppConstants.greyy),
                  ),
                ),
              ),
              SizedBox(height: height / 36),
              TextFormField(
                controller: passController,
                obscureText: _obscureText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  // You can add more complex validation here
                  return null;
                },
                style: hsMedium.copyWith(
                    fontSize: 16, color: AppConstants.textgray),
                decoration: InputDecoration(
                  hintStyle: hsMedium.copyWith(
                      fontSize: 16, color: AppConstants.textgray),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      UjuziSvgimage.message,
                      height: height / 36,
                      colorFilter: const ColorFilter.mode(
                          AppConstants.textgray, BlendMode.srcIn),
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: _togglePasswordStatus,
                    color: AppConstants.textgray,
                  ),
                  hintText: "Password",
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppConstants.greyy),
                  ),
                ),
              ),
              SizedBox(height: height / 56),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    splashColor: AppConstants.transparent,
                    highlightColor: AppConstants.transparent,
                    onTap: () {},
                    child: Text(
                      "Forgot_Password",
                      style: hsRegular.copyWith(
                          fontSize: 12, color: AppConstants.appcolor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height / 20),
              InkWell(
                splashColor: AppConstants.transparent,
                highlightColor: AppConstants.transparent,
                onTap: () {
                  // Validate the form before login
                  if (_formKey.currentState!.validate()) {
                    login(emailController.text.toString(),
                        passController.text.toString());
                  }
                },
                child: Container(
                  width: width / 1,
                  height: height / 15,
                  decoration: BoxDecoration(
                    color: AppConstants.appcolor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppConstants.white)
                        : Text(
                            "Login",
                            style: hsSemiBold.copyWith(
                                fontSize: 16, color: AppConstants.white),
                          ),
                  ),
                ),
              ),
              SizedBox(height: height / 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: height / 500,
                    width: width / 3.5,
                    color: AppConstants.bggray,
                  ),
                  SizedBox(width: width / 56),
                  Text(
                    "or_with",
                    style: hsRegular.copyWith(
                        fontSize: 12, color: AppConstants.textgray),
                  ),
                  SizedBox(width: width / 56),
                  Container(
                    height: height / 500,
                    width: width / 3.5,
                    color: AppConstants.bggray,
                  ),
                ],
              ),
              SizedBox(height: height / 26),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
