import 'dart:ui';

import 'package:flutter/material.dart';

class Blue extends StatefulWidget {
  const Blue({super.key});

  @override
  State<Blue> createState() => _BlueState();
}

class _BlueState extends State<Blue> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 400,
            color: Colors.amber,
            child: const Center(
              child: Text(
                'Blur Container',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
          SizedBox(
            height: 400,
            width: double.infinity,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
