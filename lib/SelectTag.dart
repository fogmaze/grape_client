import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class TagSelectPage extends StatefulWidget {
  TagSelectPage({super.key, required this.tags});

  List<String> tags;

  @override
  TagSelectPageState createState() => TagSelectPageState();
}

class TagSelectPageState extends State<TagSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Tag"),
      ),
      body: Center(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return ListTile(
                    title: Text(widget.tags[index]),
                    onTap: () {
                      Navigator.pop(context);
                      collectParameters.limit = widget.tags[index];
                      expandableMenuKey.currentState!.setState(() { });
                    },
                  );
                },
                childCount: widget.tags.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

}