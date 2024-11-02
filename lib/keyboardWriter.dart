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
  int nowInputLevel = 0;
  String instruction = "input que";
  bool isUsingDefFromAI = true;
  String tags = "";
  List<Matched> matched = [];
  List<String> aiDef = [];
  int aiDefIdx = 0;
  var matchedSelectedIdx = -1;
  String state = "que";
  var lastPhr = [];
  var lastPhrIdx = 0;

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
    for (var i = 0; i < MAX_SEARCH; i++) {
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
                color: i == matchedSelectedIdx ? Theme.of(context).colorScheme.onPrimaryFixedVariant: Theme.of(context).colorScheme.onSecondary,
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
              ],
            )
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(instruction, style: const TextStyle(fontSize: 20)),
              ),
              if (matchedSelectedIdx != -1)
                IconButton(
                  icon: const Icon(Icons.star),
                  onPressed: () {
                    setState(() {
                      takeNoteFromTime(matched[matchedSelectedIdx].time!);
                    });
                  },
                ),
              if (matchedSelectedIdx != -1)
                IconButton(
                  icon: const Icon(Icons.book),
                  onPressed: () {
                    setState(() {
                      addToSubNoteFromTime(matched[matchedSelectedIdx].time!);
                    });
                  },
                ),
            ],
          ),
          if (state == "ans")
            Wrap(
              direction: Axis.horizontal,
              spacing: 8.0,
              children: [
                for (var i = 0;i < aiDef.length;i++)
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (_controller.text.isNotEmpty) {
                          _controller.text += "|";
                        }
                        _controller.text += aiDef[i];
                      });
                    },
                    child: Text("[${aiDef[i]}]", style: i == aiDefIdx? const TextStyle(fontSize: 20, color: Colors.red) :const TextStyle(fontSize: 20))),
              ],
            ),
          if (state == "que")
            Wrap(
              direction: Axis.horizontal,
              spacing: 8.0,
              children: [
                for (int i = 0; i < lastPhr.length; i++)
                  InkWell(
                    onTap: () {
                      setState(() {
                        nowAddingQue = lastPhr[i][0];
                        _controller.text = lastPhr[i][1];
                        state = "ans";
                        instruction = "input ans for [$nowAddingQue]";
                        aiDef = [];
                        aiDefIdx = 0;
                        lastPhrIdx = i;
                      });
                    },
                    child: Text("[${lastPhr[i][0]} : ${lastPhr[i][1]}]", style: i == lastPhrIdx? const TextStyle(fontSize: 20, color: Colors.red) :const TextStyle(fontSize: 20))),
              ]
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your text here',
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.deepOrange
                    ),
                    child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Center(child: Text("$nowInputLevel", style: const TextStyle(color: Colors.white)))),
                  ),
                ),
              ],
            ),
          ),
        ] + matchedView,
      )
    );
  }

  void finishPhraseSearching() async{
    for (var k in lastPhr) {
      var response = await http.get(Uri.http(
          baseHost, "", {
        "type": "getDefinition",
        "word": k[1]
      }));
      setState(() {
        var jsonCode = jsonDecode(response.body);
        if (jsonCode["status"] == "success") {
          var defStr = jsonCode["definition"];
          k[1] = defStr;
        }
      });
    }
  }

  void handlePhrKBSelect() {
    if (_controller.text.contains("{")) {
      var t = _controller.text.replaceAll("{", "");
      _controller.text = t;
      if (lastPhrIdx < lastPhr.length) {
        nowAddingQue = lastPhr[lastPhrIdx][0];
        _controller.text = lastPhr[lastPhrIdx][1];
        state = "ans";
        instruction = "input ans for [$nowAddingQue]";
        aiDef = [];
        aiDefIdx = 0;
        lastPhrIdx += 1;
      }
    }
    else if (_controller.text.contains("}")) {
      var t = _controller.text.replaceAll("}", "");
      _controller.text = t;
      lastPhrIdx += 1;
    }
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
        if (matchedSelectedIdx > MAX_SEARCH-1) {
          matchedSelectedIdx = -1;
        }
        else if (_controller.text.isNotEmpty && matchedSelectedIdx == -1) {
          http.get(
              Uri.http(baseHost, "", {
                "type": "search",
                "que": _controller.text
              })
          ).then(
                  (response) {
                if (response.statusCode == 200) {
                  setState(() {
                    var jsonData = jsonDecode(response.body);
                    if (jsonData["status"] == "success") {
                      nowInputLevel = jsonData["level"];
                      matched = [];
                      for (var i = 0; i < jsonData["data"].length; i++) {
                        var matchedElement = Matched();
                        matchedElement.que = jsonData["data"][i][0];
                        matchedElement.ans = jsonData["data"][i][1];
                        matchedElement.level = jsonData["data"][i][2];
                        matchedElement.time = jsonData["data"][i][3];
                        matched.add(matchedElement);
                      }
                    }
                    else if (jsonData["status"] == "same") {
                      nowInputLevel = jsonData["level"];
                    }
                    else if (jsonData["status"] == "fail") {
                      matched = [];
                    }
                  });
                }
              }
          );
        }
        handlePhrKBSelect();

        //switch to ans
        if (_controller.text.contains("\n")) {
          state = "ans";
          if (matchedSelectedIdx != -1 ) {
            nowAddingQue = matched[matchedSelectedIdx].que!;
            _controller.text = matched[matchedSelectedIdx].ans!;
          }
          else if (matched.isNotEmpty?_controller.text.substring(0, _controller.text.length - 1) == matched[0].que:false) {
            nowAddingQue = matched[0].que!;
            _controller.text = matched[0].ans!;
          }
          else {
            nowAddingQue =
                _controller.text.substring(0, _controller.text.length - 1);
            _controller.text = "";
          }
          instruction = "input ans for [$nowAddingQue]";
          // get definition from AI
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
                  var defStr = jsonCode["definition"];
                  aiDef = defStr.split("|");
                  aiDefIdx = 0;

                  lastPhrIdx = 0;
                  lastPhr = [];
                  for (dynamic d in jsonCode["phrases"]) {
                    lastPhr.add([d[0], d[1]]);
                  }
                  finishPhraseSearching();
                }
              });
            });
          }

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
        else if (_controller.text.contains("{")) {
          var t = _controller.text.replaceAll("{", "");
          _controller.text = t;
          if (aiDefIdx < aiDef.length) {
            if (_controller.text.isNotEmpty) {
              _controller.text += "|";
            }
            _controller.text += aiDef[aiDefIdx];
            aiDefIdx += 1;
          }
        }
        else if (_controller.text.contains("}")) {
          var t = _controller.text.replaceAll("}", "");
          _controller.text = t;
          aiDefIdx += 1;
        }
      }
      for (int i = 0; i < matched.length; i++) {
        if (_controller.text == matched[i].que) {
          setState(() {
            matchedSelectedIdx = i;
          });
          break;
        }
      }
    });
  }
}


class Matched {
  String? que;
  String? ans;
  int? level;
  int? time;
}

int MAX_SEARCH = 10;