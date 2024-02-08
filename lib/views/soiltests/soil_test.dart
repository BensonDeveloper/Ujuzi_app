import 'package:flutter/material.dart';
import 'package:ujuzi_app/utils/app_constants.dart';
import 'package:ujuzi_app/utils/style.dart';

class SoilTest extends StatefulWidget {
  const SoilTest({Key? key}) : super(key: key);

  @override
  _SoilTestState createState() => _SoilTestState();
}

class _SoilTestState extends State<SoilTest> {
  // Dummy data for soil tests
  List<String> soilTests = List.generate(10, (index) => 'Test ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                      Text(
                        '10',
                        style: hsSemiBold.copyWith(
                          fontSize: 16,
                          color: AppConstants.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Farmers List:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            AnimatedList(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              initialItemCount: soilTests.length,
              itemBuilder: (context, index, animation) {
                return FadeTransition(
                  opacity: animation.drive(
                    CurveTween(curve: Curves.easeInOut),
                  ),
                  child: ListTile(
                    title: Text(soilTests[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
