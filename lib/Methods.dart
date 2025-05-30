import 'dart:async';
import 'dart:convert';
import "package:http/http.dart" as http;
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';
import 'package:flutter/material.dart';

class EnVocDef_TestingElement extends TestingElement {
  List<String>? defList;

  EnVocDef_TestingElement({required super.dataObject});
  @override
  void init() {
    initialUpdate();
    defList = ans.split("|");
  }
  @override
  String methodName = "en_voc_def";
  int showNum = 0;
  int exampleSentenceIdx = -1;
  String exampleSentence = "click the definition to show";
  bool sentenceRequestSent = false;
  @override
  Widget getWidget() {
    return EnVocDef_TestingElementWidget(element: this);
  }

  @override
  void resetWidget() {
    showNum = 0;
    exampleSentence = "click the definition to show";
    exampleSentenceIdx = -1;
  }

  @override
  void expandAll() {
    showNum = defList!.length;
    /*if (exampleSentenceIdx == -1 && !sentenceRequestSent) {
      http.get(Uri.http(
          baseHost, "",
          {
            "type": "getSentence",
            "word": que,
            "meaning": defList![0],
          }
      )).then(
          (response) {
            sentenceRequestSent = false;
            exampleSentenceIdx = 0;
            var jsonData = jsonDecode(response.body);
            if (jsonData["status"] == "success") {
              exampleSentence = jsonData["sentence"];
            }
          }
      );
      sentenceRequestSent = true;
    }*/
  }

  @override
  Future<void> onShow() async {
    if (activateTTS) {
      await flutterTts?.speak(que);
    }
  }

}

class EnVocDef_TestingElementWidget extends StatefulWidget {
  EnVocDef_TestingElement element;
  EnVocDef_TestingElementWidget({super.key, required this.element});
  @override
  EnVocDef_TestingElementWidgetState createState() => EnVocDef_TestingElementWidgetState();
}

class EnVocDef_TestingElementWidgetState extends State<EnVocDef_TestingElementWidget> {

  void regenerateSentence({smart = false}) {
    if (widget.element.exampleSentenceIdx == -1) {
      return;
    }
    http.get(Uri.http(
        baseHost, "",
        {
          "type": "RegenerateSentence",
          "word": widget.element.que,
          "meaning": widget.element.defList![widget.element.exampleSentenceIdx],
          "smart": smart.toString()
        }
    )).then(
            (response) {
          setState(() {
            var jsonData = jsonDecode(response.body);
            if (jsonData["status"] == "success") {
              widget.element.exampleSentence = jsonData["sentence"];
            }
          });
        }
    );
  }
  void getSentence() {
    http.get(Uri.http(
        baseHost, "",
        {
          "type": "getSentence",
          "word": widget.element.que,
          "meaning": widget.element.defList![widget.element.exampleSentenceIdx],
        }
    )).then(
            (response) {
          setState(() {
            var jsonData = jsonDecode(response.body);
            if (jsonData["status"] == "success") {
              widget.element.exampleSentence = jsonData["sentence"];
            }
          });
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.element.showNum++;
          if (widget.element.showNum > widget.element.defList!.length) {
            widget.element.showNum = 0;
          }
        });
      },
      child: Container(
        decoration: const BoxDecoration(),
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            activateTTS?Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                Text(widget.element.que, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded( // speaker
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () async {
                          await widget.element.ttsInstance?.speak(widget.element.que);
                      },
                    ),
                  ),
                ),
              ],
            ):Text(widget.element.que, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    for (int i = 0; i < widget.element.showNum; i++)
                      InkWell(
                        onTap: () {
                          widget.element.exampleSentenceIdx = i;
                          getSentence();
                        },
                        child: Text(widget.element.defList![i], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    for (int i = widget.element.showNum; i < widget.element.defList!.length; i++)
                      InkWell(
                        onTap: () {
                          widget.element.exampleSentenceIdx = i;
                          getSentence();
                        },
                        child: const Text("...", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                  ],
                )
              ),
            ),
            InkWell(
              onTap: () {
                regenerateSentence(smart: false);
              },
              onDoubleTap: () {
                regenerateSentence(smart: true);
              },
              child: Text("EX: ${widget.element.exampleSentence}", style: const TextStyle(fontSize: 16,)),
            ),
          ],
        ),
      ),
    );
  }
}

class EnVocSpe_TestingElement extends TestingElement {
  @override
  String methodName = "en_voc_spe";
  List<String>? defList;
  EnVocSpe_TestingElement({required super.dataObject});
  @override
  void init() {
    initialUpdate();
    defList = ans.split("|");
    hint = getHint(que);
  }
  int showNum = 1;
  double left = 0;
  bool isShowHint = false;
  String hint = "";
  bool isSpoken = false;
  bool isAllExpanded = false;
  int exampleSentenceIdx = -1;
  String exampleSentence = "click the definition to show";

  @override
  Widget getWidget() {
    return EnVocSpe_TestingElementWidget(element: this);
  }

  @override
  void resetWidget() {
    showNum = 1;
    left = 0;
    isShowHint = false;
    isSpoken = false;
    isAllExpanded = false;
  }

  @override
  void expandAll() {
    showNum = defList!.length;
    left = double.infinity;
    if (activateTTS && !isSpoken) {
      flutterTts?.speak(que);
      isSpoken = true;
    }
    isAllExpanded = true;
  }
}

class EnVocSpe_TestingElementWidget extends StatefulWidget {
  EnVocSpe_TestingElement element;
  EnVocSpe_TestingElementWidget({super.key, required this.element});
  @override
  EnVocSpe_TestingElementWidgetState createState() => EnVocSpe_TestingElementWidgetState();
}


class EnVocSpe_TestingElementWidgetState extends State<EnVocSpe_TestingElementWidget> {
  void regenerateSentence({smart = false}) {
    http.get(Uri.http(
        baseHost, "",
        {
          "type": "RegenerateSentence",
          "word": widget.element.que,
          "meaning": widget.element.defList![widget.element.exampleSentenceIdx],
          "smart": smart.toString()
        }
    )).then(
            (response) {
          setState(() {
            var jsonData = jsonDecode(response.body);
            if (jsonData["status"] == "success") {
              widget.element.exampleSentence = jsonData["sentence"];
            }
          });
        }
    );
;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              widget.element.showNum++;
              if (widget.element.showNum > widget.element.defList!.length) {
                widget.element.showNum = 1;
              }
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: const BoxDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.18,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Wrap(
                      direction: Axis.horizontal,
                      children:[
                        for (int i = 0; i < widget.element.showNum; i++)
                          InkWell(
                            onTap: () {
                              if (!widget.element.isAllExpanded) {
                                setState(() {
                                  widget.element.showNum++;
                                  if (widget.element.showNum > widget.element.defList!.length) {
                                    widget.element.showNum = 1;
                                  }
                                });
                                return;
                              }
                              http.get(Uri.http(
                                  baseHost, "",
                                  {
                                    "type": "getSentence",
                                    "word": widget.element.que,
                                    "meaning": widget.element.defList![i]
                                  }
                              )).then(
                                      (response) {
                                    setState(() {
                                      widget.element.exampleSentenceIdx = i;
                                      var jsonData = jsonDecode(response.body);
                                      if (jsonData["status"] == "success") {
                                        widget.element.exampleSentence = jsonData["sentence"];
                                      }
                                    });
                                  }
                              );
                            },
                            child: Text(i == 0?widget.element.defList![i]:"/${widget.element.defList![i]}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                          ),
                        Text("/..."*(widget.element.defList!.length - widget.element.showNum), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        if (widget.element.isShowHint)
          Text(widget.element.hint, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                widget.element.left += details.delta.dx;
              });
            },
            onTap: () {
              setState(() {
                if (!widget.element.isShowHint) {
                  widget.element.isShowHint = true;
                }
                else {
                  widget.element.expandAll();
                }
              });
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(widget.element.que, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Positioned(
                      left: widget.element.left,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.55,
                        decoration: const BoxDecoration(color: Colors.black),
                      ),
                    ),
                  ]
                ),
            ),
          ),
        ),
        if (widget.element.isAllExpanded)
          InkWell(
            onTap: () {
              regenerateSentence(smart: false);
            },
            onDoubleTap: () {
              regenerateSentence(smart: true);
            },
            child: Text("EX: ${widget.element.exampleSentence}", style: const TextStyle(fontSize: 16,)),
          ),
      ],
    );
  }
}

class EnPrepDef_TestingElement extends TestingElement {
  @override
  String methodName = "en_prep_def";
  EnPrepDef_TestingElement({required super.dataObject});

  @override
  void init() {

  }

  @override
  Widget getWidget() {
    return EnPrepDef_TestingElementWidget(element: this);
  }

  @override
  void resetWidget() {
    // TODO: implement resetWidget
  }

  @override
  void expandAll() {
    // TODO: implement expandAll
  }
}

class EnPrepDef_TestingElementWidget extends StatefulWidget {
  EnPrepDef_TestingElement element;
  EnPrepDef_TestingElementWidget({super.key, required this.element});
  @override
  EnPrepDef_TestingElementWidgetState createState() => EnPrepDef_TestingElementWidgetState();
}

class EnPrepDef_TestingElementWidgetState extends State<EnPrepDef_TestingElementWidget> {
  @override
  Widget build(BuildContext context) {
    return Text("EnPrepDef_TestingElementWidgetState");
  }
}

class EnPrepSpe_TestingElement extends TestingElement {
  EnPrepSpe_TestingElement({required super.dataObject});
  @override
  String methodName = "en_prep_spe";

  @override
  void init() {

  }

  @override
  Widget getWidget() {
    return EnPrepSpe_TestingElementWidget(element: this);
  }

  @override
  void resetWidget() {
    // TODO: implement resetWidget
  }

  @override
  void expandAll() {
    // TODO: implement expandAll
  }
}

class EnPrepSpe_TestingElementWidget extends StatefulWidget {
  EnPrepSpe_TestingElement element;
  EnPrepSpe_TestingElementWidget({super.key, required this.element});
  @override
  EnPrepSpe_TestingElementWidgetState createState() => EnPrepSpe_TestingElementWidgetState();
}

class EnPrepSpe_TestingElementWidgetState extends State<EnPrepSpe_TestingElementWidget> {
  @override
  Widget build(BuildContext context) {
    return Text("EnPrepSpe_TestingElementWidgetState");
  }
}

class Notes_TestingElement extends TestingElement {
  TestingElement? actualElement;
  Notes_TestingElement({required super.dataObject});
  @override
  void init() {
    actualElement = getTestingElementFromObject(dataObject["actual"]);
    time = dataObject["time"];
    tags = actualElement!.tags;
    level = dataObject["level"];
    relatedElements = actualElement!.relatedElements;
    noteTime = time;
    isNoted = true;
  }

  @override
  String methodName = "notes";

  @override
  Widget getWidget() {
    return actualElement!.getWidget();
  }

  @override
  void resetWidget() {
    actualElement!.resetWidget();
  }

  @override
  void expandAll() {
    actualElement!.expandAll();
  }
}
class DefaultTestingElement extends TestingElement {
  @override
  String methodName = "Default";
  var idx = 0;
  DefaultTestingElement({this.idx = 0, bool isMain=true, required super.dataObject}){
    if (isMain) {
      relatedElements = [
        DefaultTestingElement(idx: 1, isMain: false, dataObject: null,),
        DefaultTestingElement(idx: 2, isMain: false, dataObject: null)
      ];
    }
  }
  @override
  Widget getWidget() {
    return DefaultTestingElementWidget(idx: idx);
  }

  @override
  void resetWidget() {
  }

  @override
  void expandAll() {
  }

  @override
  void init() {
  }
}

class DefaultTestingElementWidget extends StatefulWidget {
  const DefaultTestingElementWidget({super.key, this.idx = 0});
  final int idx;
  @override
  State<StatefulWidget> createState() => _DefaultTestingElementWidgetState();
}

class _DefaultTestingElementWidgetState extends State<DefaultTestingElementWidget> {
  @override
  Widget build(BuildContext context) {
    return Text("DefaultTestingElement${widget.idx}");
  }
}

String getHint(String ans) {
  var words = ans.split(" ");
  var processedWords = [];
  for (var word in words) {
    if (word.length > 3) {
      processedWords.add(word[0] + "*" * (word.length - 2) + word[word.length - 1]);
    } else {
      processedWords.add("*" * word.length);
    }
  }
  return processedWords.join(" ");
}
