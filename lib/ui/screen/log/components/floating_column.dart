
import 'package:flutter/material.dart';
import 'package:skype_c/ui/themes/universal_variables.dart';

class FloatingColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: UniversalVariables.fabGradient,
          ),
          child: const Icon(Icons.dialpad, color: Colors.white, size: 25),
          padding: const EdgeInsets.all(15),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: UniversalVariables.blackColor,
            border: Border.all(
              width: 2,
              color: UniversalVariables.gradientColorEnd,
            ),
          ),
          child: Icon(
            Icons.add_call,
            color: UniversalVariables.gradientColorEnd,
            size: 25,
          ),
          padding: const EdgeInsets.all(15),
        )
      ],
    );
  }
}