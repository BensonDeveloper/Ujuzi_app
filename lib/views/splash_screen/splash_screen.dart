import 'package:flutter/material.dart';
import 'package:ujuzi_app/utils/dimensions.dart';
import 'package:ujuzi_app/utils/images.dart';
import 'package:ujuzi_app/views/splash_screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    goup();
  }

  goup() async {
    var navigator = Navigator.of(context);
    await Future.delayed(const Duration(seconds: 6));
    navigator.pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const LoginScreen();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(tag: 'logo', child: Image.asset(Images.logo)),
                const SizedBox(
                  height: Dimensions.PADDING_SIZE_EXTRA_LARGE,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
