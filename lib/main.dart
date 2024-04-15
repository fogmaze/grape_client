import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import "package:http/http.dart" as http;
import 'package:expandable_widgets/expandable_widgets.dart';
import 'fileSync.dart';
import 'Methods.dart';
import 'package:network_info_plus/network_info_plus.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "Yeah",),
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
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Text("$nowTestingElementIdx / ${testingElements.length}"),
          Positioned(
            key: mainAreaKey,
            left: mainTestArea.posLeft * MediaQuery.of(context).size.width,
            top: mainTestArea.posTop * MediaQuery.of(context).size.height,
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
                color: mainTestArea.isMovingDown() || mainTestArea.isMovingLeft() || mainTestArea.isMovingRight() || mainTestArea.isMovingUp()? Theme.of(context).colorScheme.outline: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.87,
                  child: Column(
                    children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.018),
                      child: mainTestArea.mainSingleTestingArea.getWidget(),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:mainTestArea.relatedSingleTestingArea.getWidget(),
                    ),
                    ],
                  )
                )
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: ExpandableMenuWidget(),
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
  @override
  Widget build(BuildContext context) {
    return Expandable(
        firstChild: Text("Limit: ${collectParameters.getLimit()}"),
        subChild: const Text("change parameters"),
        secondChild: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0,),
          child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 60, child: Text("Account: ")),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          onSubmitted: (String value) {
                            collectParameters.account = value;
                            collectParameters.initFromServer().then( (v) {
                              setState(() {

                              });
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter your account',
                          ),
                        ),
                      ),
                    ),
                    isCreateAccount?IconButton(onPressed: () {
                      isCreateAccount = false;
                      http.get(Uri.http(baseHost, "", {"type": "createAccount", "account": collectParameters.account})).then((value) {
                        var jsonData = jsonDecode(value.body);
                        if (jsonData["status"] == "success") {
                          Fluttertoast.showToast(
                              msg: "Account created",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }
                        else {
                          Fluttertoast.showToast(
                              msg: "Already been created, pls change",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }

                      });
                    }, icon: const Icon(Icons.add_reaction)):const SizedBox()
                  ],
                ),Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 60, child: Text("Limit: ")),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          onChanged: (String value) {
                            setState(() {
                              collectParameters.handleLimitInput(value);
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter new limit',
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Load previous "),
                      Switch(
                        value: collectParameters.loadPrevious,
                        onChanged: (bool value) {
                          setState(() {
                            collectParameters.loadPrevious = value;
                          });
                        },
                      ),
                    ]),
                const Text("Method: "),
                CheckboxListTile(
                  title: const Text("en_voc_def"),
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
                  title: const Text("en_voc_spe"),
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
                  title: const Text("notes"),
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
                const Text("Related Method: "),
                CheckboxListTile(
                  title: const Text("en_voc_def"),
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
                  title: const Text("en_voc_spe"),
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

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      reGet();
                    });
                  },
                  child: const Text("Reget"),
                ),
              ]
          ),
        )
    );
  }
}

class CollectParameters {
  Future<void> initFromServer() async {
    var response = await http.get(Uri.http(baseHost, "", {"type": "getParam", "account": account}));
    if (response.statusCode == 200) {
      var data = response.body;
      // convert string to json
      var jsonData = jsonDecode(data);
      if (jsonData["hasAccount"] == "false") {
        isCreateAccount = true;
        Fluttertoast.showToast(
            msg: "Account not found, click the button to create or input another account",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      else {
        minLevel = int.parse(jsonData["level"]);
        limit = jsonData["tags"];
        loadPrevious = int.parse(jsonData["lp"]) != 0;
        methods = jsonData["methods"].split("|");
      }
    }
  }
  Future<void> save2DB() async{
  }
  int minLevel = -1;
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
  String que = "";
  String ans = "";
  String testingBlacklist = "";
  String tags = "";
  bool isNoted = false;
  int noteTime = 0;
  TestingElement({required this.dataObject}){
    init();
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
  }
  abstract String methodName;
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
    this.element = element;
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
          height: MediaQuery.of(context).size.height * 0.39,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row( // TODO implement tool
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("from: ${widget.element.tags}", style: const TextStyle(fontSize: 16)),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        if (widget.element.isNoted) {
                          removeFromNote(widget.element);
                        }
                        else {
                          takeNote(widget.element);
                        }
                        setState(() {
                          widget.element.isNoted = !widget.element.isNoted;
                        });
                      },
                      icon: Icon(widget.element.isNoted?Icons.star:Icons.star_border, color: widget.element.isNoted?Colors.orange:Colors.grey),
                    )
                  ],
                ),
                const Divider(),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.28,
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: widget.element.getWidget()
                ),
              ],
            )
          )
        ),
      ),
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

  void updateTestingElement() {
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
    if (posTop > 0.12) {
      testingElements[nowTestingElementIdx].expandAll();
      if (testingElements[nowTestingElementIdx].relatedElements.isNotEmpty) {
        testingElements[nowTestingElementIdx].relatedElements[testingElements[nowTestingElementIdx].nowRelatedElementIdx].expandAll();
      }
    }
  }
  void handleDragEndGesture(DragEndDetails details) {
    if (isMovingLeft()) {
      takeNote(testingElements[nowTestingElementIdx]);
      change2NextTestingElement();
    }
    else if (testingElements[nowTestingElementIdx].methodName == "notes" && isMovingRight()) {
      var e = testingElements[nowTestingElementIdx];
      change2NextTestingElement();
      removeFromNote(e);
      if (nowTestingElementIdx == 0) {
        testingElements.removeAt(testingElements.length-1);
      }
      else {
        testingElements.removeAt(nowTestingElementIdx-1);
        nowTestingElementIdx--;
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

Future<void> takeNote(TestingElement e) async {
  if (e.methodName == "notes") {
    return ;
  }
  var response = await http.get(
    Uri.http(baseHost, "", {
      "type" : "note",
      "method_name" : e.methodName,
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
      Fluttertoast.showToast(
          msg: "Note taken",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else {
      Fluttertoast.showToast(
          msg: "Note already taken",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }
}

Future<void> removeFromNote(TestingElement element) async {
  if (element.methodName == "notes") {
    Notes_TestingElement e = element as Notes_TestingElement;
    var response = await http.get(
        Uri.http(baseHost, "", {
          "type" : "unote",
          "time" : e.time.toString(),
        }
        )
    );
    Fluttertoast.showToast(
        msg: "Note removed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_LEFT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  else {
    var response = await http.get(
        Uri.http(baseHost, "", {
          "type": "unote",
          "time": element.noteTime.toString(),
        }
        )
    );
    Fluttertoast.showToast(
        msg: "Note removed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_LEFT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}

void change2PreviousTestingElement() {
  if (nowTestingElementIdx > 0) {
    nowTestingElementIdx--;
    testingElements[nowTestingElementIdx].resetWidget();
    testingElements[nowTestingElementIdx].relatedElements[testingElements[nowTestingElementIdx].nowRelatedElementIdx].resetWidget();
    mainTestArea.updateTestingElement();
  }
}

void change2NextTestingElement() {
  if (nowTestingElementIdx < testingElements.length - 1) {
    http.get(Uri.http(
      baseHost, "",
      {
        "type": "update_rec",
        "operation": "del",
        "targetId": nowId.toString(),
        "time": testingElements[nowTestingElementIdx].time.toString(),
        "method_name": testingElements[nowTestingElementIdx].methodName,
      }
    ));
    testingElements[nowTestingElementIdx].nowRelatedElementIdx++;
    if (testingElements[nowTestingElementIdx].nowRelatedElementIdx >= testingElements[nowTestingElementIdx].relatedElements.length) {
      testingElements[nowTestingElementIdx].nowRelatedElementIdx = 0;
    }
    nowTestingElementIdx++;
  } else {
    // shuffle the testing List
    testingElements.shuffle(Random());
    nowTestingElementIdx = 0;
    for (var e in testingElements) {
      e.resetWidget();
    }
    var methodNames = [];
    var times = [];
    for (var e in testingElements) {
      methodNames.add(e.methodName);
      times.add(e.time);
    }
    http.post(
      Uri.http(
        baseHost, "",
        {
          "type": "update_rec",
          "operation": "reset",
          "targetId": nowId.toString(),
        }
      ),
      body: jsonEncode({
        "method_names": methodNames,
        "times": times,
      })
    );
  }
  mainTestArea.updateTestingElement();
}

Future<List<TestingElement>> getRelatedTestingElements(TestingElement element) async {
  List<TestingElement>? ret;
  List<Map<String, dynamic>> result;
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
  for (var e in ret) {
  }
  return ret;
}

Future<int> initLoading() async {
  List<Map<String, dynamic>> matchedId = [{'id': 0}];
  if (matchedId.isEmpty) {
    Fluttertoast.showToast(
        msg: "No previous record found",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
    await reGet();
    int? id = 0;
    return id!;
  }
  else {
    int id = matchedId[0]['id'];
    Fluttertoast.showToast(
        msg: "Previous record found with id: $id",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
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

Future<void> reGet() async{
  if (collectParameters.account == "") {
    Fluttertoast.showToast(
        msg: "Account not set",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
    return;
  }
  var tags = collectParameters.limit.replaceAll("&", "^");
  Map<String, dynamic> queryParameters = {
    "type": "reget",
    "method_name": collectParameters.methods.join("|"),
    "tags": tags,
    "isLoad": "${collectParameters.loadPrevious}",
    "account": collectParameters.account,
    "level": "${collectParameters.minLevel}",
  };
  Fluttertoast.showToast(
      msg: "Fetching data from server, please wait patiently.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
  );
  var response = await http.get(Uri.http(baseHost, "", queryParameters));
  if (response.statusCode == 200) {
    var data = response.body;
    // convert string to json
    var jsonData = jsonDecode(data);

    testingElements = [];
    if (jsonData["data"].isEmpty) {
      Fluttertoast.showToast(
          msg: "No data found. please change the parameters",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
    for (var element in jsonData["data"]) {
      testingElements.add(getTestingElementFromObject(element));
    }

    nowTestingElementIdx = jsonData["nowTestingIdx"];
    nowId = jsonData["id"];
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

var baseHost = "150.116.202.108:49";
final GlobalKey mainAreaKey = GlobalKey();
MainTestArea mainTestArea = MainTestArea();
CollectParameters collectParameters = CollectParameters();
List<String> relatedMethods = ["en_voc_def"];
var nowTestingElementIdx = 0;
var nowId = 0;
List<TestingElement> testingElements = [DefaultTestingElement(idx: 8, dataObject: 0), DefaultTestingElement(dataObject: 0), DefaultTestingElement(idx: 22, dataObject: 0)];
bool isCreateAccount = false;
HttpServer? server;
Map<String, String> methodName2Table = {
  "en_voc_def": "en_voc",
  "en_voc_spe": "en_voc",
  "en_prep_def": "en_prep",
  "en_prep_spe": "en_prep",
  "notes": "notes"
};