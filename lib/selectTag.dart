import 'main.dart';
import 'package:flutter/material.dart';

class TagSelectPage extends StatefulWidget {
  const TagSelectPage({super.key, required this.tags});

  final List<String> tags;

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