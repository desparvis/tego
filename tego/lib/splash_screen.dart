import 'package:flutter/material.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                'Tego',
                style: TextStyle(
                  fontFamily: 'Allura',
                  fontSize: 60,
                  color: Color(0xFF7430EB),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Image.asset(
                  'assets/images/home.jpg',  
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,  
                ),
              ),
            ],
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7430EB),  
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}