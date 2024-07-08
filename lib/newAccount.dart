import 'main.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class ConfirmPage extends StatefulWidget {
  const ConfirmPage({super.key});

  @override
  ConfirmPageState createState() => ConfirmPageState();
}

class ConfirmPageState extends State<ConfirmPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Confirm to create account'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Are you sure you want to create an account?'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Username'),
            subtitle: Text(collectParameters.account),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () {
              http.get(Uri.http(baseHost, "", {"type": "createAccount", "account": collectParameters.account})).then((value) {
                Navigator.pushNamed(context, "/");
              });
            },
            child: const Text('Confirm'),
          ),
        ]
      )
    );
  }
}