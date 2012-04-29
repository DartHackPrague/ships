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
        String operation = request.queryParameters["operation"];
        
        print("operation:" + operation);
        print("data:" + data);
        data = JSON.parse(data);
        
        String htmlResponse = shoot(operation, data, games);
        
        response.headers.set(HttpHeaders.CONTENT_TYPE, "text/html; charset=UTF-8");
        response.outputStream.writeString(htmlResponse);
        response.outputStream.close();
      }
  );
  
  server.listen(HOST, PORT);
  
  print("Serving the current time on http://${HOST}:${PORT}."); 
}

String shoot(operation, data, games) {
  
  // encode coordinates to representation used by our data structure
  var shot = "" + data["i"] + "," + data["j"];
  
  // lookup game according to publicId
  var game = games[0]; // TODO
  
  // get list of ships
  List ships = game["ships"]; 
  //print(ships);
  
  // record shot // TODO
  
  // determine if the ship was hit
  data["hit"] = ships.indexOf(shot) >= 0;
  data["sea"] = "oponent";
  data["operation"] = operation;
  
  var ret = JSON.stringify(data);
  
  ret = "callbackForJsonpApi(" + ret + ");";
      
  return ret;
}

