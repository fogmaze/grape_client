import 'dart:convert';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';



class InputPage extends StatefulWidget {
  const InputPage({super.key, });

  @override
  InputPageState createState() => InputPageState();

}

class InputPageState extends State<InputPage> {

  final _controller = TextEditingController();
  final _tagController = TextEditingController(text: "mag");
  int maxLines = 2;
  String instruction = "input que";
  bool isUsingDefFromAI = true;
  String tags = "";
  List<Matched> matched = [];
  var matchedSelectedIdx = -1;
  String state = "que";

  @override
  void dispose() {
    _controller.dispose();
    http.get(
        Uri.http(baseHost, "", {
          "type": "finishWriting"
        }
        )
    );
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(controllerCallback);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> matchedView = [];
    for (var i = 0; i < 5; i++) {
      var text = "$i. no match";
      if (matched.length > i) {
        text = "[${matched[i].level}] ${matched[i].que} -> ${matched[i].ans}";
      }
      matchedView.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 1),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: i == matchedSelectedIdx ? Theme.of(context).colorScheme.onPrimary: Theme.of(context).colorScheme.onSecondary,
              ),
              child: Text(text, style: const TextStyle(fontSize: 20)),
            ),
          ),
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    onChanged: (text) {
                      tags = text;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(isUsingDefFromAI?Icons.lightbulb:Icons.lightbulb_outline),
                  onPressed: () {
                    setState(() {
                      isUsingDefFromAI = !isUsingDefFromAI;
                    });
                  },
                )
              ],
            )
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(instruction, style: const TextStyle(fontSize: 20)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              maxLines: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your text here',
              ),
            ),
          ),
        ] + matchedView,
      )
    );
  }

  var nowAddingQue = "";
  void controllerCallback() {
    setState(() {
      if (state == "que") {
        matchedSelectedIdx = -1;
        for (var i = 0; i < _controller.text.length; i++) {
          if (_controller.text[i] == "*" || _controller.text[i] == "Q") {
            matchedSelectedIdx += 1;
          }
        }
        if (matchedSelectedIdx > 4) {
          matchedSelectedIdx = -1;
        }
        else if (_controller.text.isNotEmpty && matchedSelectedIdx == -1) {
          http.get(
              Uri.http(baseHost, "", {
                "type": "search",
                "que": _controller.text
              }
              )
          ).then(
                  (response) {
                if (response.statusCode == 200) {
                  setState(() {
                    var jsonData = jsonDecode(response.body);
                    if (jsonData["status"] == "success") {
                      matched = [];
                      for (var i = 0; i < jsonData["data"].length; i++) {
                        var matchedElement = Matched();
                        matchedElement.que = jsonData["data"][i][0];
                        matchedElement.ans = jsonData["data"][i][1];
                        matchedElement.level = jsonData["data"][i][2];
                        matched.add(matchedElement);
                      }
                    }
                    if (jsonData["status"] == "fail") {
                      matched = [];
                    }
                  });
                }
              }
          );
        }

        if (_controller.text.contains("\n")) {
          state = "ans";
          if (matchedSelectedIdx != -1 ) {
            nowAddingQue = matched[matchedSelectedIdx].que!;
            _controller.text = matched[matchedSelectedIdx].ans!;
            // request ai for def
            if (isUsingDefFromAI) {
              http.get(Uri.http(
                  baseHost, "", {
                "type": "getDefinition",
                "word": nowAddingQue
              }
              )).then((response) {
                setState(() {
                  var jsonCode = jsonDecode(response.body);
                  if (jsonCode["status"] == "success") {
                    instruction += "(Ai says that : ${jsonCode["definition"]})";
                  }
                });
              });
            }
          }
          else if (matched.isNotEmpty?_controller.text.substring(0, _controller.text.length - 1) == matched[0].que:false) {
            nowAddingQue = matched[0].que!;
            _controller.text = matched[0].ans!;
            // request ai for def
            if (isUsingDefFromAI) {
              http.get(Uri.http(
                  baseHost, "", {
                "type": "getDefinition",
                "word": nowAddingQue
              }
              )).then((response) {
                setState(() {
                  var jsonCode = jsonDecode(response.body);
                  if (jsonCode["status"] == "success") {
                    instruction += "(Ai says that : ${jsonCode["definition"]})";
                  }
                });
              });
            }
          }
          else {
            nowAddingQue =
                _controller.text.substring(0, _controller.text.length - 1);
            _controller.text = "";
            // request ai for def
            if (isUsingDefFromAI) {
              http.get(Uri.http(
                  baseHost, "", {
                "type": "getDefinition",
                "word": nowAddingQue
              }
              )).then((response) {
                setState(() {
                  var jsonCode = jsonDecode(response.body);
                  if (jsonCode["status"] == "success") {
                    _controller.text = jsonCode["definition"];
                  }
                });
              });
            }
          }
          instruction = "input ans for [$nowAddingQue]";
        }
      }
      else if (state == "ans") {
        if (_controller.text.contains("\n") && _controller.text.length > 1) {
          var resultStr = _controller.text.replaceAll("\n", "");
          state = "que";
          instruction = "input question";
          _controller.text = "";
          http.get(
              Uri.http(baseHost, "", {
                "type": "add",
                "tags": tags,
                "que": nowAddingQue,
                "ans": resultStr
              }
              )
          ).then(
                  (response) {
                    setState(() {
                      if (response.statusCode == 200) {
                        var jsonData = jsonDecode(response.body);
                        if (jsonData["status"] == "success") {
                          Fluttertoast.showToast(
                              msg: "Added successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP_RIGHT,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }
                        else {
                          Fluttertoast.showToast(
                              msg: "Failed to add $nowAddingQue",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP_RIGHT,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }
                      }
                    });
              }
          );
        }
        else if (_controller.text.contains("\n")) {
          state = "que";
          instruction = "input question";
          _controller.text = "";
          Fluttertoast.showToast(
              msg: "Answer is empty",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM_LEFT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      }

    });
  }
}


class Matched {
  String? que;
  String? ans;
  String? level;
}