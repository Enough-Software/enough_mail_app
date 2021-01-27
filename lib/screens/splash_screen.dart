import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(0xff99cc00),
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     begin: Alignment.topLeft,
              //     end: Alignment.bottomRight,
              //     colors: [Colors.green[300], Colors.green[900]],
              //   ),
              // ),
              child: Center(
                child: Text(
                  'loading...',
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
