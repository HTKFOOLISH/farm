import 'package:farm/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const Spacer(),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Image.asset('assets/onboarding.png'),
              ),
              const Spacer(),
              Text(
                textAlign: TextAlign.center,
                'Welcome to Farming Diary App\nCreated by\nHuỳnh Thiện Khải & Võ Văn Hiếu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30, bottom: 30),
                child: Text(
                  "\nClick \"Continue with Google\" to use this app.\nEnjoy it 😊",
                  textAlign: TextAlign.center,
                ),
              ),
              /**/
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) => const HomeScreen()));
                },
                icon: const Icon(IconlyLight.login),
                label: const Text("Continue with Google"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
