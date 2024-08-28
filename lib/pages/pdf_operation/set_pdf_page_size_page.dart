import 'package:flutter/material.dart';

class SetPDFPageSizePage extends StatelessWidget {
  const SetPDFPageSizePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split PDF by Range'),
      ),
      body: Center(
        child: Text('This is the Split PDF by Range page'),
      ),
    );
  }
}
