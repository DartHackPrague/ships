#import("dart:io");
#import("dart:json");

final HOST = "127.0.0.1";
final PORT = 8090;
final SHIP_COUNT = 3;

void main() {
  HttpServer server = new HttpServer();
  var games = [
                 {
                   "secretId" : "alfa",
                   "publicId" : "beta",
                   "ships" : [],
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

String shoot(String operation, data, games) {
  
  // lookup game according to publicId
  var game = games[0]; // TODO
  List ret = []; 
  
  if ("shoot" == operation)
  { // execute shooting
 
    var coordinates = data["coordinates"];
    
    // get list of ships
    List ships = game["ships"]; 
    //print(ships);
    print(game);
    
    // record shot
    game["shots"].add(coordinates);
    
    // determine if the ship was hit
    data["hit"] = ships.indexOf(coordinates) >= 0;
    data["sea"] = "oponent";
    data["operation"] = operation;
    
    ret.add(data);
  }
  else if ("placeShip" == operation)
  { // place ship to board

    var coordinates = data["coordinates"];

    if (game["ships"].length >= SHIP_COUNT) {
      print("too many ships: " + game["ships"]);
      return "";  // ensure not too many ships are on the map
    }
    else if (game["ships"].indexOf(coordinates) >= 0) {
      print("duplicit ship: " + game["ships"] + " - " + coordinates);
      return "";  // avoid duplicity in ships placement
    }
    
    game["ships"].add(coordinates);

    data["sea"] = "player";
    data["operation"] = operation;
    
    ret.add(data);
    
    // change state if enough ships was placed on board
    if (game["ships"].length == SHIP_COUNT) {
      ret.add({
        "state" : "shoot"
      });
    }
  }
  else if ("findShotsOnPlayer" == operation)
  { // find shots fired on player, with coordinates and hit/miss result
    List ships = game["ships"];
    List shots = game["shots"];
     
    for (String shot in shots) {
      var reportedShot = {};
      reportedShot["coordinates"] = shot;
      reportedShot["operation"] = "shoot";
      reportedShot["sea"] = "player";
      reportedShot["hit"] = ships.indexOf(shot) >= 0;
      
      ret.add(reportedShot);
    }
  }
  
  // create response
  ret = JSON.stringify(ret);
  ret = "callbackForJsonpApi(" + ret + ");";
      
  print("returning JSON: " + ret);
  
  return ret;
}

