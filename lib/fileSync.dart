import 'dart:io';
import "package:path_provider/path_provider.dart";

Future<void> handleRequest(HttpRequest request) async {
  var applicationDirectory = await getApplicationDocumentsDirectory();
  if (request.method == 'GET') {
    var filename = request.uri.pathSegments.last;
    var file = File('${applicationDirectory.path}/$filename');
    if (await file.exists()) {
      request.response.headers.contentType = ContentType.binary;
      await request.response.addStream(file.openRead());
    } else {
      request.response.statusCode = HttpStatus.notFound;
    }
    request.response.close();
  }

  if (request.method == 'POST') {
    print('POST for ${request.uri.pathSegments.last}');
    var filename = request.uri.pathSegments.last;
    var file = File('${applicationDirectory.path}/$filename');
    await file.writeAsBytes(await request.fold<List<int>>([], (p, d) => p..addAll(d)));
    request.response.statusCode = HttpStatus.ok;
    request.response.close();
  }
}

Future<HttpServer> startServer() async{
  print("Starting server");
  var server = await HttpServer.bind(
    InternetAddress.anyIPv4,
    8765,
  );
  server.listen((HttpRequest request) {
    handleRequest(request).then((value) {});
  });
  return server;
}

Future<void> stopServer(HttpServer server) async {
  print("Stopping server");
  server.close();
}
