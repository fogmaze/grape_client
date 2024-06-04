import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';
import 'package:flutter/material.dart';


class InputPage extends StatefulWidget {
  var instructionIdx = 0;
  CollectParameters information;
  InputPage({super.key, required this.information});

  @override
  InputPageState createState() => InputPageState();
}

class InputPageState extends State<InputPage> {

  final TextEditingController _controller = TextEditingController();
  int maxLines = 2;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        if (_controller.text.contains('*\n')) {
          _controller.text = "example\ndef:";
          maxLines += 1;
        }
        if (_controller.text.contains('|\n')) {
          _controller.text = "";
          maxLines = 2;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input'),
      ),
      body: Center(
        child: TextField(
          controller: _controller,
          maxLines: maxLines,
        )
      )
    );
  }
}
