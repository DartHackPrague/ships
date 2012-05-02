#import("dart:io");
#import("dart:json");

final HOST = "127.0.0.1";
final PORT = 8090;
final SHIP_COUNT = 3;
final SHOT_WINDOW = 1; // how many shots we can fire without waiting for retaliation

// state of one sea (ships, hits, tokens)
class Game {
  String playerToken; // player access its own sea by this token
  String oponentToken; // oponent acess this sea by this token
  List<String> ships; // coordinates of ships in the sea
  List<String> shots; // coordinates of targets of shots
  
  // constructor
  Game(String playerToken, String oponentToken) {
    this.playerToken = playerToken;
    this.oponentToken = oponentToken;
    ships = new List<String>();
    shots = new List<String>();
  }
  
  // find hits
  Set<String> getHits() {
    Set<String> ret = new Set<String>();
    
    ret.addAll(ships);
    ret.intersection(shots);
    
    return ret;
  }
  
  String toString() {
    return "{(game) player: " + playerToken + ", oponent: " + oponentToken + ", ships: " + ships + ", shots: " + shots + "}"; 
  }
}

// repository for games being played
class Games {
  List<Game> games;
  
  // constructor
  Games() {
    games = new List<Game>();
  }

  // find game by 'playerToken'
  Game findGame4player(String playerToken) {
    Game ret;

    for (Game game in games) {
      if (game.playerToken == playerToken) {
        ret = game;
        break;
      }
    }
    
    return ret;
  }
  
  // find game by 'oponentToken'
  Game findGame4oponent(String oponentToken) {
    Game ret;

    for (Game game in games) {
      if (game.oponentToken == oponentToken) {
        ret = game;
        break;
      }
    }
    
    return ret;
  }
  
  String toString() {
    return "(games) " + games;
  }
}

void main() {
  HttpServer server = new HttpServer();
  Games games = new Games();
  games.games = [
       new Game("alfa", "beta"), // katarina
       new Game("gama", "delta") // viktor
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
  
  var game = games.findGame4player(playerToken);
  var oponentGame = games.findGame4oponent(oponentToken);
  
  print("player: " + game);
  print("oponent: " + oponentGame);
  
  if ("shoot" == operation)
  { // execute shooting
 
    var coordinates = data["coordinates"];
    
    // how many 'bulets' are in magazine
    int magazine = game.shots.length - oponentGame.shots.length + SHOT_WINDOW;
    print("magazine: " + magazine);
    ret.add({"magazine": magazine});
    
    // do not allow shooting with empty magazine
    if (magazine > 0) {
      
      // record shot
      oponentGame.shots.add(coordinates);
  
      // report shooting back to player
      ret.add({
        "coordinates": coordinates,
        "hit": oponentGame.ships.indexOf(coordinates) >= 0, // determine if the ship was hit
        "sea": "oponent",
        "operation": "shoot"
      });
    }
  }
  else if ("placeShip" == operation)
  { // place ship on sea

    var coordinates = data["coordinates"];

    if (game.ships.length >= SHIP_COUNT) {
      print("too many ships: " + game.ships);
      return "";  // ensure not too many ships are on the map
    }
    else if (game.ships.indexOf(coordinates) >= 0) {
      print("duplicit ship: " + game.ships + " - " + coordinates);
      return "";  // avoid duplicity in ships placement
    }
    
    game.ships.add(coordinates);

    data["sea"] = "player";
    data["operation"] = operation;
    
    ret.add(data);
    
    // change state if enough ships was placed on board
    if (game.ships.length == SHIP_COUNT) {
      ret.add({
        "state" : "shoot"
      });
    }
  }
  else if ("findShotsOnPlayer" == operation)
  { // find shots fired on player, with coordinates and hit/miss result
    
    for (String shot in game.shots) {
      var reportedShot = {
        "coordinates": shot,
        "operation": "shoot",
        "sea": "player",
        "hit": game.ships.indexOf(shot) >= 0
      };
      
      ret.add(reportedShot);
    }
    
    // how many 'bulets' are in magazine
    int magazine = game.shots.length - oponentGame.shots.length + SHOT_WINDOW;
    print("magazine: " + magazine);
    ret.add({"magazine": magazine});
  }
  else if ("initialize" == operation)
  { // recover after page reload - send all status notifications to client
    
    // player's ships first
    for (String coordinates in game.ships) {
      ret.add({
        "coordinates": coordinates,
        "operation": "placeShip",
        "sea": "player"
      });
    }
    
    // shots in player's sea
    for (String shot in game.shots) {
      ret.add({
        "coordinates": shot,
        "operation": "shoot",
        "sea": "player",
        "hit": game.ships.indexOf(shot) >= 0
      });
    }

    // shots in oponent's sea
    for (String shot in oponentGame.shots) {
      ret.add({
        "coordinates": shot,
        "operation": "shoot",
        "sea": "oponent",
        "hit": oponentGame.ships.indexOf(shot) >= 0
      });
    }
    
    // update state
    if (game.ships.length == SHIP_COUNT) {
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

