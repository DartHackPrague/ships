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


    request("pal", [2, 2]);
    
    //sendRequest("http://localhost:8090/entry", {"baf" : 15},
    //            (Map response) => uiProcessResponse(response),
    //            () => uiProcessResponse({"sprava":"nefunguje siet"}));
  }

  dataReceived(MessageEvent e) {
    write(e.data);
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



