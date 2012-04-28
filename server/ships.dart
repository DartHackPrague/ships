#import("dart:io");
#import("dart:json");

final HOST = "127.0.0.1";
final PORT = 8090;

void main() {
  HttpServer server = new HttpServer();
  var games = [
                 {
                   "secretId" : "alfa",
                   "publicId" : "beta",
                   "ships" : ["1,0", "1,1", "1,2", "2,1"],
                   "shots" : []
                 }
               ];
  
  server.addRequestHandler((HttpRequest request) => true,
      (HttpRequest request, HttpResponse response) {
        if (true) {
          print("Request: ${request.method} ${request.uri}");
        }
    
        var data = request.queryParameters["data"];
        
        print("data:" + data);
        data = JSON.parse(data);
        
        String htmlResponse = createJSONResponse(data, games);
        
        response.headers.set(HttpHeaders.CONTENT_TYPE, "text/html; charset=UTF-8");
        response.outputStream.writeString(htmlResponse);
        response.outputStream.close();
      }
  );
  
  server.listen(HOST, PORT);
  
  print("Serving the current time on http://${HOST}:${PORT}."); 
}

String createJSONResponse(data, games) {
  //var arr = [1, 3, 4, 5, 7];
  //arr.add(9);
  var i = data["i"];
  var j = data["j"];
  
  // determine if the ship was hit
  var shot = "" + i + "," + j;
  List ships = games[0]["ships"];
  //print(ships);
  data["hit"] = ships.indexOf(shot) >= 0;
  
  var ret = JSON.stringify({"shot": data});
  
  ret = "callbackForJsonpApi(" + ret + ");";
      
  return ret;
}

