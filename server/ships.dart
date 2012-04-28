#import("dart:io");
#import("dart:json");

final HOST = "127.0.0.1";
final PORT = 8090;

void main() {
  HttpServer server = new HttpServer();
  
  server.addRequestHandler((HttpRequest request) => true, requestReceivedHandler);
  
  server.listen(HOST, PORT);
  
  print("Serving the current time on http://${HOST}:${PORT}."); 
}

void requestReceivedHandler(HttpRequest request, HttpResponse response) {
  if (true) {
    print("Request: ${request.method} ${request.uri}");
  }

  var data = request.queryParameters["data"];
  
  print("data:" + data);
  data = JSON.parse(data);
  
  String htmlResponse = createJSONResponse(data);
  
  response.headers.set(HttpHeaders.CONTENT_TYPE, "text/html; charset=UTF-8");
  response.outputStream.writeString(htmlResponse);
  response.outputStream.close();
}

String createJSONResponse(data) {
  var arr = [1, 3, 4, 5, 7];
  arr.add(9);
  
  var ret = JSON.stringify({"foo": arr, "submitedData": data});
  
  ret = "callbackForJsonpApi(" + ret + ");";
      
  return ret;
}
