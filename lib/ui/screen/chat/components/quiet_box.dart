// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:skype_c/ui/themes/universal_variables.dart';

class QuietBox extends StatelessWidget {
  final String heading;
  final String subtitle;

  // ignore: use_key_in_widget_constructors
  QuietBox({
    required this.heading,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          color: UniversalVariables.separatorColor,
          padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                heading,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 25),
              TextButton(
                style: TextButton.styleFrom(
                  primary: UniversalVariables.lightBlueColor,
                ),
                child: const Text('START SEARCHING'),
                onPressed: () => Navigator.pushNamed(context, '/search_screen'),
              )
            ],
          ),
        ),
      ),
    );
  }
}