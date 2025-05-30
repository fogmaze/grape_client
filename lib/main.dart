import 'dart:math';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import "package:http/http.dart" as http;
import 'package:expandable_widgets/expandable_widgets.dart';
import 'selectTag.dart';
import 'Methods.dart';
import 'help.dart';
import 'newAccount.dart';
import 'keyboardWriter.dart';
import 'package:flutter_tts/flutter_tts.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  defaultAccount = Uri.base.path.substring(1);
  if (defaultAccount.isEmpty) {
    defaultAccount = "default";
  }
  collectParameters.account = defaultAccount;
  collectParameters.initFromServer().then((value) {
    if (value) {
      reGet(toast: false).then((value) {mainAreaKey.currentState?.setState(() {});});
      runApp(const MyApp());
    }
    else {
      runApp(const MyApp(initialRoute: "/confirm"));
    }
  });

}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, this.initialRoute = "/"});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'learninglish | GSAT 15!!!',
      initialRoute: initialRoute,
      routes: {
        "/" : (context) => const MyHomePage(title: "Yeah", ),
        "/help" : (context) => HelpPage(),
        "/KBwrite" : (context) => const InputPage(),
        "/confirm": (context) => const ConfirmPage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: nowThemeMode,
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  void handleChangeLimitInput(String value) {
    setState(() {
      // TODO implement this
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            switchMainAndSub();
          });
        },
        child: isTestingSubNote ? const Icon(Icons.book_sharp):const Icon(Icons.book_outlined),
      ),
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
              child: FatherTestingAreaWidget(key: mainAreaKey,)
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child:  Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: ExpandableMenuWidget(key: expandableMenuKey),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class ExpandableMenuWidget extends StatefulWidget {
  const ExpandableMenuWidget({super.key});
  @override
  State<StatefulWidget> createState() => _ExpandableMenuWidgetState();
}

class _ExpandableMenuWidgetState extends State<ExpandableMenuWidget> {
  var accountController = TextEditingController();
  var scopeController = TextEditingController();
  var minLevelController = TextEditingController(text: "${collectParameters.levelRange[0]}");
  var maxLevelController = TextEditingController(text: "${collectParameters.levelRange[1]}");
  @override
  Widget build(BuildContext context) {
    accountController.text = collectParameters.account;
    scopeController.text = collectParameters.limit;
    return Expandable(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        firstChild: Text("Scope: ${collectParameters.getLimit()}"),
        subChild: const Text("change parameters"),
        secondChild: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text("Testing Level Range: "),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 40,
                          child: TextField(
                            controller: minLevelController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "min"
                            ),
                            onChanged: (v) {
                              collectParameters.levelRange[0] = v;
                            }
                          ),
                        )
                    ),
                    const Text("~"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 40,
                        child: TextField(
                          controller: maxLevelController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "max"
                          ),
                          onChanged: (v) {
                            collectParameters.levelRange[1] = v;
                          }
                        ),
                      )
                    ),

                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 60, child: Text("Scope: ")),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: scopeController,
                          onChanged: (String value) {
                            collectParameters.handleLimitInput(value);
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter scope or click the button to select',
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          http.get(Uri.http(baseHost, "", {
                            "type": "getTags",
                          })).then((value) {
                            var jsonData = jsonDecode(value.body);
                            List<String> tagsResult = [];
                            for (var e in jsonData["tags"]) {
                              tagsResult.add(e);
                            }
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TagSelectPage(tags: tagsResult)));
                          });
                        });
                      },
                      icon: const Icon(Icons.find_in_page),
                      iconSize: 30,
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        activateTTS = !activateTTS;
                        if (activateTTS&&flutterTts==null) {
                          initTTS();
                        }
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text("TTS "),
                          const Expanded( child: SizedBox()) ,
                          Switch(
                            value: activateTTS, onChanged: (bool value) {
                              setState(() {
                                activateTTS = value;
                                if (activateTTS&&flutterTts==null) {
                                  initTTS();
                                }
                              });
                            },
                          ),
                        ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        collectParameters.loadPrevious = !collectParameters.loadPrevious;
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text("Load previous "),
                          const Expanded( child: SizedBox()) ,
                          Switch(
                            value: collectParameters.loadPrevious,
                            onChanged: (bool value) {
                              setState(() {
                                collectParameters.loadPrevious = value;
                              });
                            },
                          ),
                        ]),
                  ),
                ),
                const Text("Testing Method:", style: TextStyle(fontWeight: FontWeight.bold),),
                CheckboxListTile(
                  title: const Text("Definition"),
                  value: collectParameters.methods.contains("en_voc_def"),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        collectParameters.methods.add("en_voc_def");
                      } else {
                        collectParameters.methods.remove("en_voc_def");
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text("Spelling"),
                  value: collectParameters.methods.contains("en_voc_spe"),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        collectParameters.methods.add("en_voc_spe");
                      } else {
                        collectParameters.methods.remove("en_voc_spe");
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text("Noted Ones"),
                  value: collectParameters.methods.contains("notes"),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        collectParameters.methods.add("notes");
                      } else {
                        collectParameters.methods.remove("notes");
                      }
                    });
                  },
                ),
                const Text("Related Method: ", style: TextStyle(fontWeight: FontWeight.bold),),
                CheckboxListTile(
                  title: const Text("Definition"),
                  value: relatedMethods.contains("en_voc_def"),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        relatedMethods.add("en_voc_def");
                      } else {
                        relatedMethods.remove("en_voc_def");
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text("Spelling"),
                  value: relatedMethods.contains("en_voc_spe"),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        relatedMethods.add("en_voc_spe");
                      } else {
                        relatedMethods.remove("en_voc_spe");
                      }
                    });
                  },
                ),
                Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (isTestingSubNote) {
                                  switchMainAndSub();
                                }
                                reGet().then((value) {
                                  mainAreaKey.currentState?.setState(() {});
                                });
                              });
                            },
                            child: const Text("Reget"),
                          ),
                        ),
                      ),
                      if (collectParameters.account == defaultAccount)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const InputPage()));
                              });
                            },
                            child: const Text("KBWrite"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                getFromHost({
                                  "type": "resetSubNote",
                                  "account": collectParameters.account
                                });
                                if (isTestingSubNote) {
                                  switchMainAndSub();
                                }
                                subNotedTestingElements.clear();
                                nowSubNoteIdx = 0;
                                mainTestArea.updateTestingElement();
                                mainAreaKey.currentState?.setState(() {});
                              });
                            },
                            child: const Text("Clear SubNote"),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ]
          ),
        )
    );
  }
}

class CollectParameters {
  Future<bool> initFromServer() async {
    var response = await http.get(Uri.http(baseHost, "", {"type": "getParam", "account": account}));
    if (response.statusCode == 200) {
      var data = response.body;
      // convert string to json
      var jsonData = jsonDecode(data);
      if (jsonData["hasAccount"] == "false") {
        return false;
      }
      else {
        levelRange[0] = int.parse(jsonData["level"]);
        levelRange[1] = int.parse(jsonData["level_max"]);
        limit = jsonData["tags"];
        loadPrevious = int.parse(jsonData["lp"]) != 0;
        var methodsTmp = jsonData["methods"].split("|");
        for (var e in methodsTmp) {
          if (e != "") {
            methods.add(e);
          }
        }

      }
      return true;
    }
    return false;
  }
  Future<void> save2DB() async{
  }
  List levelRange = [0, 6];
  String limit = "";
  String account = "";
  bool loadPrevious = false;
  List<String> methods = [];
  String getLimit() {
    return limit;
  }

  List<dynamic> sorted(List list) {
    list.sort();
    return list;
  }
  void handleLimitInput(String value) {
    limit = value;
  }
}

abstract class TestingElement {
  dynamic dataObject;
  int time = 0;
  int level = 0;
  String que = "";
  String ans = "";
  String testingBlacklist = "";
  String tags = "";
  bool isNoted = false;
  int noteTime = 0;
  FlutterTts? ttsInstance;
  bool enableTTS = true;
  TestingElement({required this.dataObject}){
    init();
    ttsInstance = flutterTts;
    enableTTS = activateTTS;
  }
  void regetRelatedTestingElements() async {
    relatedElements = await getRelatedTestingElements(this, );
  }

  void initialUpdate() {
    ans = dataObject["ans"];
    que = dataObject["que"];
    tags = dataObject["tags"];
    noteTime = dataObject["note_time"];
    if (noteTime != 0) {
      isNoted = true;
    }
    if (dataObject["tb"] != null) {
      testingBlacklist = dataObject["tb"];
    }
    else {
      testingBlacklist = "";
    }
    time = dataObject["time"];
    if (relatedMethods.isNotEmpty) {
      for (var e in dataObject["related"]) {
        // shuffle the relatedMethods
        relatedMethods.shuffle(Random());
        e["name"] = relatedMethods[0];
        relatedElements.add(getTestingElementFromObject(e));
      }
    }
    level = dataObject["level"];
  }
  abstract String methodName;
  Future<void> onShow() async { }
  Future<void> onHide() async { }
  GestureDetector? detector;
  List<TestingElement>relatedElements = [];
  var nowRelatedElementIdx = 0;

  void init();

  void resetWidget();
  void expandAll();
  Widget getWidget();
}


class SingleTestingArea {
  SingleTestingArea();
  TestingElement element = DefaultTestingElement(dataObject: null);
  void updateElement(TestingElement element) {
    this.element.onHide().then((value) {
      this.element = element;
      element.onShow();
    });
  }
  Widget getWidget() => SingleTestingAreaWidget(element: element);
}

class SingleTestingAreaWidget extends StatefulWidget {
  const SingleTestingAreaWidget({super.key, required this.element});
  final TestingElement element;
  @override
  State<StatefulWidget> createState() => _SingleTestingAreaWidgetState();
}

class _SingleTestingAreaWidgetState extends State<SingleTestingAreaWidget> {
  void addCurrentToSubNote({bool reverse=false}) {
    setState(() {
      addToSubNote(widget.element, reverse: reverse);
    });
    mainAreaKey.currentState?.setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.72,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.deepOrange
                        ),
                        child: SizedBox(
                            width: 24,
                            height: 24,
                            child: Center(child: Text("${widget.element.level}", style: const TextStyle(color: Colors.white)))),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text("from: ${widget.element.tags}", style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        addCurrentToSubNote();
                      },
                      onDoubleTap: () {
                        addCurrentToSubNote(reverse: true);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(Icons.book_outlined),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (widget.element.methodName == "notes") {
                            removeFromNote(testingElements[nowTestingElementIdx]);
                            removeNowTesting();
                            mainTestArea.updateTestingElement();
                          }
                          else {
                            if (widget.element.isNoted) {
                              removeFromNote(widget.element);
                            }
                            else {
                              takeNote(widget.element).then(
                                  (value) => setState(() { })
                              );
                            }
                          }
                        });
                      },
                      onDoubleTap: () {
                        takeNote(widget.element, reverse: true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(widget.element.isNoted?Icons.star:Icons.star_border, color: widget.element.isNoted?Colors.orange:Colors.grey),
                      ),
                    )
                  ],
                ),
                const Divider(thickness: 2,),
                Expanded(
                  child: widget.element.getWidget(),
                ),
              ],
            )
          )
        ),
      ),
    );
  }
}

class FatherTestingAreaWidget extends StatefulWidget {
  const FatherTestingAreaWidget({super.key, });
  @override
  State<StatefulWidget> createState() => _FatherTestingAreaWidgetState();
}

class _FatherTestingAreaWidgetState extends State<FatherTestingAreaWidget> {

  Color getTestAreaColor() {
    if (mainTestArea.isMovingDown() || mainTestArea.isMovingLeft() ||
        mainTestArea.isMovingRight() || mainTestArea.isMovingUp()) {
      return Theme
          .of(context)
          .colorScheme
          .surfaceVariant;
    }
    else {
      if (isTestingSubNote) {
        return Theme
            .of(context)
            .colorScheme
            .outline;
      }
      else {
        return Theme
            .of(context)
            .colorScheme
            .outlineVariant;
      }
    }
  }

    @override
  Widget build(BuildContext context) {
      return SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height,
        child: Stack(
          alignment: Alignment.bottomCenter,
            children: [
              Text("$nowTestingElementIdx / ${testingElements
                  .length} / ${subNotedTestingElements.length}"),
              Positioned(
                left: mainTestArea.posLeft * MediaQuery
                    .of(context)
                    .size
                    .width,
                top: mainTestArea.posTop * MediaQuery
                    .of(context)
                    .size
                    .height,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      mainTestArea.handleDragUpdateGesture(details, context);
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      mainTestArea.handleDragEndGesture(details);
                    });
                  },
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: getTestAreaColor(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.8,
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.87,
                          child: Column(
                            children: [
                              Expanded(
                                child:Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery
                                          .of(context)
                                          .size
                                          .height * 0.01,
                                      bottom: MediaQuery
                                          .of(context)
                                          .size
                                          .height * 0.01
                                  ),
                                  child: mainTestArea.mainSingleTestingArea
                                      .getWidget(),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery
                                          .of(context)
                                          .size
                                          .height * 0.01
                                  ),
                                  child: mainTestArea.relatedSingleTestingArea
                                      .getWidget(),
                                ),
                              ),
                            ],
                          )
                      )
                  ),
                ),
              ),
            ]),
      );
    }
}

class MainTestArea {
  SingleTestingArea relatedSingleTestingArea = SingleTestingArea();
  SingleTestingArea mainSingleTestingArea = SingleTestingArea();
  var posLeft = 0.1;
  var posTop = 0.08;
  bool isMovingLeft() {
    return posLeft < 0;
  }
  bool isMovingRight() {
    return posLeft > 0.2;
  }
  bool isMovingUp() {
    return posTop < 0;
  }
  bool isMovingDown() {
    return posTop > 0.12;
  }

  void updateTestingElement() async{

    mainSingleTestingArea.updateElement(testingElements[nowTestingElementIdx]);
    if (testingElements[nowTestingElementIdx].relatedElements.isNotEmpty) {
      relatedSingleTestingArea.updateElement(testingElements[nowTestingElementIdx].relatedElements[testingElements[nowTestingElementIdx].nowRelatedElementIdx]);
    }
    else {
      relatedSingleTestingArea.updateElement(DefaultTestingElement(dataObject: null));
    }
  }
  void handleDragUpdateGesture(DragUpdateDetails details, BuildContext context) {
    posLeft += details.delta.dx / MediaQuery.of(context).size.width;
    posTop += details.delta.dy / MediaQuery.of(context).size.height;
    if (isMovingLeft() || isMovingRight() || isMovingUp() || isMovingDown()) {
      testingElements[nowTestingElementIdx].expandAll();
      if (testingElements[nowTestingElementIdx].relatedElements.isNotEmpty) {
        testingElements[nowTestingElementIdx].relatedElements[testingElements[nowTestingElementIdx].nowRelatedElementIdx].expandAll();
      }
    }
  }
  void handleDragEndGesture(DragEndDetails details) {
    if (isMovingLeft() && !isTestingSubNote) {
      addToSubNote(testingElements[nowTestingElementIdx]);
      if (isMovingDown()) {
        takeNote(testingElements[nowTestingElementIdx]);
      }
      change2NextTestingElement();
    }
    else if (isMovingRight() ) {
      if (isTestingSubNote) {
        removeNowTesting();
      }
      else {
        if (testingElements[nowTestingElementIdx].methodName == "notes") {
          removeFromNote(testingElements[nowTestingElementIdx]);
          removeNowTesting();
        }
        else if(testingElements[nowTestingElementIdx].isNoted) {
          removeFromNote(testingElements[nowTestingElementIdx]);
          change2NextTestingElement();
        }
      }
    }
    else if (isMovingDown()) {
      change2NextTestingElement();
    }
    else if (isMovingUp()) {
      change2PreviousTestingElement();
    }
    posLeft = 0.1;
    posTop = 0.08;
  }
}

void showShortToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM_LEFT,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

Future<http.Response> getFromHost(Map<String, dynamic> queryParameters) async {
  return http.get(Uri.http(baseHost, "", queryParameters));
}

Future<http.Response> postToHost(Map<String, dynamic> queryParameters, Object body) async {
  return http.post(Uri.http(baseHost, "", queryParameters), body: jsonEncode(body));
}

void switchMainAndSub() {
  var temp = testingElements;
  testingElements = subNotedTestingElements;
  subNotedTestingElements = temp;
  var tempId = nowTestingElementIdx;
  nowTestingElementIdx = nowSubNoteIdx;
  nowSubNoteIdx = tempId;
  isTestingSubNote = !isTestingSubNote;
  mainTestArea.updateTestingElement();
}

void removeNowTesting() {
  Future<http.Response>? response;
  bool isShuffled = false;
  if (isTestingSubNote) {
    // send remove request
    response = getFromHost({
      "type": "removeSubNoteIdx",
      "idx": nowTestingElementIdx.toString(),
      "account": collectParameters.account,
    });
  }
  testingElements.removeAt(nowTestingElementIdx);
  // handle if reach the end of the testingElements
  if (nowTestingElementIdx == testingElements.length) {
    // shuffle the testing List
    testingElements.shuffle(Random());
    nowTestingElementIdx = 0;
    for (var e in testingElements) {
      e.resetWidget();
    }
    isShuffled = true;
  }

  // update layout
  testingElements[nowTestingElementIdx].resetWidget();
  if (testingElements[nowTestingElementIdx].relatedElements.isNotEmpty) {
    testingElements[nowTestingElementIdx].relatedElements[testingElements[nowTestingElementIdx].nowRelatedElementIdx].resetWidget();
  }
  mainTestArea.updateTestingElement();

  // sync to server
  if (isShuffled) {
    if (isTestingSubNote) {
      response!.then((value) {
        updateTestingElementRecordToServer();
      });
    }
    else {
      updateTestingElementRecordToServer();
    }
  }
}


void addToSubNote(TestingElement element, {bool reverse = false}) async{
  var e = element;
  if (reverse) {
    var targetMethodName = e.methodName;
    if (e.methodName == "en_voc_def") {
      targetMethodName = "en_voc_spe";
    }
    else if (e.methodName == "en_voc_spe") {
      targetMethodName = "en_voc_def";
    }
    e = await requestTestingElementFromTime(e.time, methodName: targetMethodName);
  }
  List<TestingElement> targetList = isTestingSubNote ? testingElements : subNotedTestingElements;
  bool isExist = false;
  for (var ele in targetList) {
    if (e.time == ele.time && e.methodName == ele.methodName) {
      isExist = true;
      showShortToast("Already added");
      break;
    }
  }
  if (!isExist) {
    getFromHost({
      "type": "subNoteAdd",
      "method_name": e.methodName,
      "method_time": e.time.toString(),
      "account": collectParameters.account,
    });
    targetList.add(e);
    mainTestArea.updateTestingElement();
    showShortToast("Added to subnote");
  }
}

Future<TestingElement> requestTestingElementFromTime(int time, {methodName="en_voc_def"}) async {
  var response = await getFromHost({
    "type": "getDetailFromTime",
    "time": time.toString(),
    "method_name": methodName,
    "account": collectParameters.account,
  });
  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);
    if (jsonData["status"] == "success") {
      var data = jsonData["data"];
      return getTestingElementFromObject(data);
    }
  }
  return DefaultTestingElement(dataObject: null);
}

void addToSubNoteFromTime(int time) async{
  var response = await getFromHost({
    "type": "getDetailFromTime",
    "time": time.toString(),
    "method_name": "en_voc_def",
    "account": collectParameters.account,
  });
  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);
    if (jsonData["status"] == "success") {
      var data = jsonData["data"];
      var e = getTestingElementFromObject(data);
      addToSubNote(e);
    }
  }
}

Future<void> takeNoteFromTime(int time, {methodName="en_voc_def"}) async {
  var r = await getFromHost({
    "type": "note",
    "method_name": methodName,
    "method_time": time.toString(),
    "account": collectParameters.account,
  });
  if (r.statusCode == 200) {
    var jsonData = jsonDecode(r.body);
    if (jsonData["status"] == "success") {
      showShortToast("Note taken");
    }
    else {
      showShortToast("Note already taken");
    }
  }
}

Future<void> takeNote(TestingElement e, {bool reverse = false}) async {
  if (e.methodName == "notes") {
    e as Notes_TestingElement;
    takeNote(e.actualElement!, reverse: true);
    return ;
  }
  var targetMethodName = e.methodName;
  if (reverse) {
    if (e.methodName == "en_voc_def") {
      targetMethodName = "en_voc_spe";
    }
    else if (e.methodName == "en_voc_spe") {
      targetMethodName = "en_voc_def";
    }
  }
  var response = await http.get(
    Uri.http(baseHost, "", {
      "type" : "note",
      "method_name" : targetMethodName,
      "method_time" : e.time.toString(),
      "account" : collectParameters.account,
    }
    )
  );
  if (response.statusCode == 200) {
    var data = response.body;
    // convert string to json
    var jsonData = jsonDecode(data);
    if (jsonData["status"] == "success") {
      showShortToast("Note taken");
      if (!reverse) {
        e.isNoted = true;
        e.noteTime = jsonData["time"];
      }
    }
    else {
      showShortToast("Note already taken");
    }
  }
}

Future<void> removeFromNote(TestingElement element) async {
  element.isNoted = false;
  var response = await http.get(Uri.http(
      baseHost, "",
      {
        "type": "unote",
        "time": "${element.noteTime}"
      }
  ));
  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);
    if (jsonData["status"] == "success") {
      showShortToast("Note removed");
      element.isNoted = false;
      element.noteTime = 0;
    }
    else {
      showShortToast("Note removing failed");
      element.isNoted = true;
    }
  }
}

void change2PreviousTestingElement() {
  if (nowTestingElementIdx > 0) {
    nowTestingElementIdx--;
    testingElements[nowTestingElementIdx].resetWidget();

    // handle the related elements
    testingElements[nowTestingElementIdx].nowRelatedElementIdx--;
    if (testingElements[nowTestingElementIdx].nowRelatedElementIdx < 0) {
      testingElements[nowTestingElementIdx].nowRelatedElementIdx = testingElements[nowTestingElementIdx].relatedElements.length - 1;
    }
    if (testingElements[nowTestingElementIdx].relatedElements.isNotEmpty) {
      testingElements[nowTestingElementIdx].relatedElements[testingElements[nowTestingElementIdx].nowRelatedElementIdx].resetWidget();
    }
    testingElements[nowTestingElementIdx].resetWidget();
    mainTestArea.updateTestingElement();
  }
}

void change2NextTestingElement() {
  if (nowTestingElementIdx < testingElements.length - 1) {
    if (!isTestingSubNote) {
      getFromHost({
        "type": "update_rec",
        "operation": "del",
        "targetId": nowId.toString(),
        "time": testingElements[nowTestingElementIdx].time.toString(),
        "method_name": testingElements[nowTestingElementIdx].methodName,
      });
    }

    testingElements[nowTestingElementIdx].nowRelatedElementIdx++;
    if (testingElements[nowTestingElementIdx].nowRelatedElementIdx >=
        testingElements[nowTestingElementIdx].relatedElements.length) {
      testingElements[nowTestingElementIdx].nowRelatedElementIdx = 0;
    }
    nowTestingElementIdx++;

    if (isTestingSubNote) {
      getFromHost({
        "type": "subNoteUpdateIdx",
        "idx": nowTestingElementIdx.toString(),
        "account": collectParameters.account,
      });
    }
  }
  else {
    // shuffle the testing List
    testingElements.shuffle(Random());
    nowTestingElementIdx = 0;
    for (var e in testingElements) {
      e.resetWidget();
    }
    updateTestingElementRecordToServer();
  }

  testingElements[nowTestingElementIdx].resetWidget();
  if (testingElements[nowTestingElementIdx].relatedElements.isNotEmpty) {
    testingElements[nowTestingElementIdx].relatedElements[testingElements[nowTestingElementIdx].nowRelatedElementIdx].resetWidget();
  }
  mainTestArea.updateTestingElement();
}

void updateTestingElementRecordToServer() {
  var methodNames = [];
  var times = [];
  for (var e in testingElements) {
    methodNames.add(e.methodName);
    times.add(e.time);
  }
  if (!isTestingSubNote) {
    postToHost({
      "type": "update_rec",
      "operation": "reset",
      "targetId": nowId.toString(),
    }, {
      "method_names": methodNames,
      "times": times,
    });
  }
  else {
    postToHost({
      "type": "subNoteUpdate",
      "account": collectParameters.account,
    }, {
      "method_names": methodNames,
      "times": times,
    });
  }
}

Future<List<TestingElement>> getRelatedTestingElements(TestingElement element) async {
  List<TestingElement>? ret;
  if (element.methodName.contains("voc")) {
    if (element.methodName.contains("def")) {
    }
  }
  else {
    ret = [DefaultTestingElement(dataObject: 0)];
  }
  if (ret == null) {
    return [DefaultTestingElement(dataObject: 0)];
  }
  return ret;
}

Future<int> initLoading() async {
  List<Map<String, dynamic>> matchedId = [{'id': 0}];
  if (matchedId.isEmpty) {
    showShortToast("No previous record found");
    await reGet();
    int? id = 0;
    return id;
  }
  else {
    int id = matchedId[0]['id'];
    showShortToast("Previous record found with id: $id");
  }
  return 0;
}

TestingElement getTestingElementFromObject(dynamic object) {
  late TestingElement ret;
  if (object["name"] == "en_voc_def") {
    ret = EnVocDef_TestingElement(dataObject: object);
  }
  else if (object["name"] == "en_voc_spe") {
    ret = EnVocSpe_TestingElement(dataObject: object);
  }
  else if (object["name"] == "en_prep_def") {
    ret = EnPrepDef_TestingElement(dataObject: object);
  }
  else if (object["name"] == "en_prep_spe") {
    ret = EnPrepSpe_TestingElement(dataObject: object);
  }
  else if (object["name"] == "notes") {
    ret = Notes_TestingElement(dataObject: object);
  }
  else {
    ret = DefaultTestingElement(dataObject: object);
  }
  return ret;
}

Future<void> reGet({bool toast=true}) async{
  if (collectParameters.account == "") {
    if (toast) {
      showShortToast("Account not set");
    }
    return;
  }
  var tags = collectParameters.limit.replaceAll("&", "^");
  Map<String, dynamic> queryParameters = {
    "type": "reget",
    "method_name": collectParameters.methods.join("|"),
    "tags": tags,
    "isLoad": "${collectParameters.loadPrevious}",
    "account": collectParameters.account,
    "minLevel": "${collectParameters.levelRange[0]}",
    "maxLevel": "${collectParameters.levelRange[1]}",
  };
  if (toast) {
    Fluttertoast.showToast(
        msg: "Fetching data from server, please wait patiently.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  var response = await http.get(Uri.http(baseHost, "", queryParameters));
  if (response.statusCode == 200) {
    var data = response.body;
    // convert string to json
    var jsonData = jsonDecode(data);

    testingElements = [];
    if (jsonData["data"].isEmpty) {
      if (toast) {
        Fluttertoast.showToast(
            msg: "No data found. please change the parameters",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      return;
    }
    for (var element in jsonData["data"]) {
      testingElements.add(getTestingElementFromObject(element));
    }
    if (!jsonData["subData"].isEmpty) {
      subNotedTestingElements = [];
      for (var element in jsonData["subData"]) {
        subNotedTestingElements.add(getTestingElementFromObject(element));
      }
      nowSubNoteIdx = jsonData["nowSubIdx"];
    }

    nowTestingElementIdx = jsonData["nowTestingIdx"];
    nowId = jsonData["id"];
    if (toast) {
      Fluttertoast.showToast(
          msg: "Start in Id: $nowId",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    mainTestArea.updateTestingElement();
  }
  else {
    Fluttertoast.showToast(
        msg: "Bad response when reget",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}

void initTTS() {
  flutterTts = FlutterTts();
  flutterTts!.setStartHandler(() {
    ttsState = TtsState.playing;
  });
  flutterTts!.setCompletionHandler(() {
    ttsState = TtsState.stopped;
  });
  flutterTts!.setCancelHandler(() {
    ttsState = TtsState.stopped;
  });
}

String defaultAccount = "ali";
var baseHost = "150.116.202.108:49";
//var baseHost = "localhost:8000";
final GlobalKey mainAreaKey = GlobalKey<_FatherTestingAreaWidgetState>();
final GlobalKey expandableMenuKey = GlobalKey<_ExpandableMenuWidgetState>();
MainTestArea mainTestArea = MainTestArea();
CollectParameters collectParameters = CollectParameters();
List<String> relatedMethods = ["en_voc_def"];
var nowTestingElementIdx = 0;
var nowId = 0;
bool isTestingSubNote = false;
List<TestingElement> testingElements = [DefaultTestingElement(idx: 8, dataObject: 0), DefaultTestingElement(dataObject: 0), DefaultTestingElement(idx: 22, dataObject: 0)];
List<TestingElement> subNotedTestingElements = [];
var nowSubNoteIdx = 0;
bool isCreateAccount = false;
HttpServer? server;
FlutterTts? flutterTts;
bool activateTTS = false;
ThemeMode nowThemeMode = ThemeMode.dark;
// tts state
enum TtsState { playing, stopped, paused, continued }
TtsState ttsState = TtsState.stopped;
Map<String, String> methodName2Table = {
  "en_voc_def": "en_voc",
  "en_voc_spe": "en_voc",
  "en_prep_def": "en_prep",
  "en_prep_spe": "en_prep",
  "notes": "notes"
};