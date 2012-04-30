#import("dart:io");
#import("dart:json");

final HOST = "127.0.0.1";
final PORT = 8090;
final SHIP_COUNT = 3;

void main() {
  HttpServer server = new HttpServer();
  var games = [
                 { // katarina
                   "playerToken" : "alfa",
                   "player4oponentToken" : "beta",
                   "ships" : [],
                   "shots" : []
                 },
                 { // viktor
                   "playerToken" : "gama",
                   "player4oponentToken" : "delta",
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
        try {
          data = JSON.parse(data);
        } catch(var e) {
          print("error while parsing " + data + ": " + e);
        }
        print("parsed data: " + data);
        
        String htmlResponse;
        try {
           htmlResponse = shoot(operation, data, games);
        } catch (var e) {
          print("error while constructing response: " + e);
        }
        
        print(games);
        
        response.headers.set(HttpHeaders.CONTENT_TYPE, "text/html; charset=UTF-8");
        response.outputStream.writeString(htmlResponse);
        response.outputStream.close();
      }
  );
  
  server.listen(HOST, PORT);
  
  print("Serving the current time on http://${HOST}:${PORT}."); 
}

String shoot(String operation, data, games) {
  print(data);
  String playerToken = data["playerToken"];
  String oponentToken = data["oponentToken"];
  List ret = []; 
  
  print("playerToken: " + playerToken);
  print("oponentToken: " + oponentToken);
  
  if ("shoot" == operation)
  { // execute shooting
 
    // lookup game according to id
    var game = games.filter((element) { return element["player4oponentToken"] == oponentToken; })[0];
    print(game);
    
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
    var game = games.filter((element) { return element["playerToken"] == playerToken; })[0];
    print(game);

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
    var game = games.filter((element) { return element["playerToken"] == playerToken; })[0];
    
    List ships = game["ships"];
    List shots = game["shots"];
     
    for (String shot in shots) {
      var reportedShot = {
        "coordinates": shot,
        "operation": "shoot",
        "sea": "player",
        "hit": ships.indexOf(shot) >= 0
      };
      
      ret.add(reportedShot);
    }
  } else if ("initialize" == operation)
  { // recover after page reload - sent all status notifications to client
    var game = games.filter((element) { return element["playerToken"] == playerToken; })[0];
    var oponentsGame = games.filter((element) { return element["player4oponentToken"] == oponentToken; })[0];
    List<String> ships = game["ships"];
    List<String> shots = game["shots"];
    List<String> oponentsShips = oponentsGame["ships"];
    List<String> oponentsShots = oponentsGame["shots"];
    
    // player's ships first
    for (String coordinates in ships) {
      ret.add({
        "coordinates": coordinates,
        "operation": "placeShip",
        "sea": "player"
      });
    }
    
    // shots in player's sea
    for (String shot in shots) {
      ret.add({
        "coordinates": shot,
        "operation": "shoot",
        "sea": "player",
        "hit": ships.indexOf(shot) >= 0
      });
    }

    // shots in oponent's sea
    for (String shot in oponentsShots) {
      ret.add({
        "coordinates": shot,
        "operation": "shoot",
        "sea": "oponent",
        "hit": oponentsShips.indexOf(shot) >= 0
      });
    }
    
    // update state
    if (ships.length == SHIP_COUNT) {
      ret.add({
        "state" : "shoot"
      });
    }
  }
  
  // create response
  ret = JSON.stringify(ret);
  ret = "callbackForJsonpApi(" + ret + ");";
      
  print("returning JSON: " + ret);
  
  return ret;
}

