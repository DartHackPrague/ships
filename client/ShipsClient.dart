#import('dart:html');
//#import('dart:io');
#import('dart:json');


class ShipsClient {
  String _gameState;  // placeShips, wait, shoot, win, lose
  int _magazine = 0;  // number of bullets in magazine

  void setGameState(String gameState) {
    _gameState = gameState;
    drawStateFeedback();
  }
  
  void setMagazine(int magazine) {
    _magazine = magazine;
    drawStateFeedback();
  }

  // make border around the table according to state
  void drawStateFeedback() {
    TableElement playerTable = document.query("#player-sea");
    TableElement oponentTable = document.query("#oponent-sea");
    
    String playerBorder = "";
    String oponentBorder = "";
    
    int playerBorderWidth = 0;
    int oponentBorderWidth = 0;
    
    if ("placeShips" == _gameState) {
      playerBorder = "px solid pink";
      playerBorderWidth = 10;
    }
    else if ("wait" == _gameState) {  // wait until oponent has the ships placed
      oponentBorder = "px solid lightgray";
      oponentBorderWidth = 10;
    }
    else if ("shoot" == _gameState) {
      if (_magazine > 0) {
        oponentBorder = "px solid pink";
        oponentBorderWidth = (5 * _magazine);
      } else {
        oponentBorder = "px solid lightgray";
        oponentBorderWidth = 5;
      }
    } else if ("win" == _gameState) {
      write("You WON!");
    } else if ("loose" == _gameState) {
      write("You LOST");
    }
    
    playerTable.style.setProperty("border", "" + playerBorderWidth + playerBorder);
    oponentTable.style.setProperty("border", "" + oponentBorderWidth + oponentBorder);

    playerTable.parent.style.setProperty("padding", "" + (20 - playerBorderWidth) + "px");
    oponentTable.parent.style.setProperty("padding", "" + (20 - oponentBorderWidth) + "px");
  }
  
  ShipsClient() {
  }

  void run() {
    write("Ship Battle Game");
    setGameState("placeShips");
    
    // listen for the postMessage from the main page
    window.on.message.add(dataReceived);

    //document.query("#player-label").on.click.add((MouseEvent e) {
    //  request("findShotsOnPlayer", {});
    //});
    
    //new Timer.repeating(1000, (Timer timer) {
    //  request("findShotsOnPlayer", {});
    //});
    
    //request("pal", [2, 2]);
    createPlayground("player-sea", "placeShip", "placeShips");
    createPlayground("oponent-sea", "shoot", "shoot");
    
    request("initialize", {}); // for case the page has been reloaded - get all status information
    
    //sendRequest("http://localhost:8090/entry", {"baf" : 15},
    //            (Map response) => uiProcessResponse(response),
    //            () => uiProcessResponse({"sprava":"nefunguje siet"}));
  }

  // create playboard in
  // table with specified id
  // on click send the operation 
  // and be active in specified state
  createPlayground(String tableId, String operationName, String state) {
    TableElement table = document.query('#' + tableId);
    for  (var i = 0; i < 10; i++) {
      TableRowElement row = table.insertRow(0);
      
      for (var j = 0; j < 10; j++) {
        TableCellElement cell = row.insertCell(0);
        String coordinates = "" + i + "-" + j;
        
        cell.text = "";
        cell.bgColor = "lightgray";
        cell.height = "15";
        cell.width = "15";
        cell.id = tableId + "-" + coordinates;
        
        cell.on.click.add((MouseEvent e) {
          if (state == _gameState) {
            request(operationName, {"coordinates": coordinates});
          }
        });
      }
    }
  }
  
  dataReceived(MessageEvent e) {
    print(e.data);
    
    var data = JSON.parse(e.data);
    
    if (data is Map) {
      data = [data];
    }
    
    for (Map msg in data) {
      if (msg.containsKey("state")) {
        setGameState(msg["state"]);
      }
      
      if (msg.containsKey("magazine")) {
        setMagazine(msg["magazine"]);
      }
      
      if ("shoot" == msg["operation"]) {
        String id = "#" + msg["sea"] + "-sea-" + msg["coordinates"];
        TableCellElement cell = document.query(id);
        
        if (msg["hit"]) {
          cell.bgColor = "green";
          if ("oponent" == msg["sea"]) {
            cell.bgColor = "red";
          } else {
            cell.bgColor = "black";
          }
        } else {
          cell.bgColor = "darkgray";
        }
      }
      else if ("placeShip" == msg["operation"]) {
        String id = "#" + msg["sea"] + "-sea-" + msg["coordinates"];
        TableCellElement cell = document.query(id);
        cell.bgColor = "blue";
      }
    }
  }

  /**
   * deliver json to server, submit operation and data
   */
  request(operation, data) {
    Element script = new Element.tag("script");
    
    // appent tokens identifying game
    String playerToken = document.query("#playerToken").text;
    String oponentToken = document.query("#oponentToken").text;
    
    data["playerToken"] = playerToken;
    data["oponentToken"] = oponentToken;
    
    print("sending: " + data);
    
    // send request
    script.src = "http://localhost:8090/ships"
        + "?operation=" + operation
        + "&data=" + JSON.stringify(data)
        + "&callback=callbackForJsonpApi";
    document.body.elements.add(script);
  }
    
  void write(String message) {
    // the HTML library defines a global "document" variable
    document.query('#status').innerHTML = message;
  }

  uiProcessResponse(Map response) {
    var str = JSON.stringify(response);
    write(str);
  }
}

void main() {
  new ShipsClient().run();
}



