#import('dart:html');
//#import('dart:io');
#import('dart:json');


class ShipsClient {

  ShipsClient() {
  }

  void run() {
    write("Ship Battle Game");
    
    // listen for the postMessage from the main page
    window.on.message.add(dataReceived);

    document.query("#player-label").on.click.add((MouseEvent e) {
      request("findShotsOnPlayer", {});
    });
    
    //new Timer.repeating(1000, (Timer timer) {
    //  request("findShotsOnPlayer", {});
    //});
    
    //request("pal", [2, 2]);
    createPlayground("player-sea", "placeShip", "alfa");
    createPlayground("oponent-sea", "shoot", "beta");
    
    //sendRequest("http://localhost:8090/entry", {"baf" : 15},
    //            (Map response) => uiProcessResponse(response),
    //            () => uiProcessResponse({"sprava":"nefunguje siet"}));
  }

  // create playboard in
  // table with specified id
  // on click send the operation 
  // and idntify/authorize with token
  createPlayground(String tableId, String operationName, String token) {
    TableElement table = document.query('#' + tableId);
    for  (var i = 0; i < 10; i++) {
      TableRowElement row = table.insertRow(0);
      
      for (var j = 0; j < 10; j++) {
        TableCellElement cell = row.insertCell(0);
        
        cell.text = "";
        cell.bgColor = "lightgray";
        cell.height = "15";
        cell.width = "15";
        cell.id = tableId + "-" + i + "-" + j;
        
        cell.on.click.add((MouseEvent e) {
          request(operationName, {"i":i, "j":j});
        });
      }
    }
  }
  
  dataReceived(MessageEvent e) {
    print(e.data);
    
    var data = JSON.parse(e.data);
    
    if (data is List) {
      for (Map shot in data) {
        String id = "#" + shot["sea"] + "-sea-" + shot["i"] + "-" + shot["j"];
        TableCellElement cell = document.query(id);
        if (shot["hit"]) {
          cell.bgColor = "red";
        } else {
          cell.bgColor = "darkgray";
        }
      }
    }
    else if ("shoot" == data["operation"]) {
      String id = "#" + data["sea"] + "-sea-" + data["i"] + "-" + data["j"];
      TableCellElement cell = document.query(id);
      if (data["hit"]) {
        cell.bgColor = "red";
      } else {
        cell.bgColor = "darkgray";
      }
    }
    else if ("placeShip" == data["operation"]) {
      String id = "#" + data["sea"] + "-sea-" + data["i"] + "-" + data["j"];
      TableCellElement cell = document.query(id);
      cell.bgColor = "blue";
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



