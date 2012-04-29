#import('dart:html');
//#import('dart:io');
#import('dart:json');


class ShipsClient {
  var _gameState; 

  // state should be: placeShips | shoot
  void setGameState(String gameState) {
    _gameState = gameState;
    
    // make border around the table according to state
    TableElement playerTable = document.query("#player-sea");
    TableElement oponentTable = document.query("#oponent-sea");
    if ("placeShips" == gameState) {
      playerTable.style.setProperty("border", "10px solid pink");
      oponentTable.style.setProperty("border", "");
    }
    else if ("shoot" == gameState) {
      playerTable.style.setProperty("border", "");
      oponentTable.style.setProperty("border", "10px solid pink");
    }
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
      
      if ("shoot" == msg["operation"]) {
        String id = "#" + msg["sea"] + "-sea-" + msg["coordinates"];
        TableCellElement cell = document.query(id);
        
        if (msg["hit"]) {
          cell.bgColor = "red";
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



