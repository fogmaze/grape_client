import 'main.dart';
import 'package:flutter/material.dart';


class HelpPage extends StatefulWidget {
  var instructionIdx = 0;
  HelpPage({super.key});

  @override
  HelpPageState createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.network("http://$baseHost/help/${widget.instructionIdx}.png",
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return const Text('Reached the end of the instructions.');
              },
            ),
          ),
          Text(widget.instructionIdx.toString()),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.instructionIdx--;
                        if (widget.instructionIdx < 0) {
                          widget.instructionIdx = 0;
                        }
                      });
                    },
                    child: const Text('Previous'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.instructionIdx++;
                      });
                    },
                    child: const Text('Next'),
                  ),
                ),
              ),
            ],
          )
        ],
      )
    );
  }
}

