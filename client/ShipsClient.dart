#import('dart:html');
//#import('dart:io');
#import('dart:json');

class ShipsClient {

  ShipsClient() {
  }

  void run() {
    write("Battleships game");
    
    // listen for the postMessage from the main page
    window.on.message.add(dataReceived);


    //request("pal", [2, 2]);
    
    // create playboard
    TableElement table = document.query('#sea');
    for  (var i = 0; i < 10; i++) {
      TableRowElement row = table.insertRow(0);
      
      for (var j = 0; j < 10; j++) {
        TableCellElement cell = row.insertCell(0);
        
        cell.text = "";
        cell.bgColor = "lightgray";
        cell.height = "15";
        cell.width = "15";
        cell.id = "sea-" + i + "-" + j;
        
        cell.on.click.add((MouseEvent e) {
          request("pal", {"i":i, "j":j});
        });
      }
    }
    
    //sendRequest("http://localhost:8090/entry", {"baf" : 15},
    //            (Map response) => uiProcessResponse(response),
    //            () => uiProcessResponse({"sprava":"nefunguje siet"}));
  }

  dataReceived(MessageEvent e) {
    write(e.data);
    
    var data = JSON.parse(e.data);
    String id = "#sea-" + data["shot"]["i"] + "-" + data["shot"]["j"];
    TableCellElement cell = document.query(id);
    
    if (data["shot"]["hit"]) {
      cell.bgColor = "red";
    } else {
      cell.bgColor = "darkgray";
    }
  }

  /**
   * deliver json to method on server
   */
  request(method, data) {
    Element script = new Element.tag("script");
    
    script.src = "http://localhost:8090/" + method
        + "?data=" + JSON.stringify(data)
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



