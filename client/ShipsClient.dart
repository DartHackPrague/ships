#import('dart:html');
//#import('dart:io');
#import('dart:json');

class ShipsClient {

  ShipsClient() {
  }

  void run() {
    write("Battleships game");
    
    sendRequest("http://localhost:8090/entry", {"baf" : 15},
                (Map response) => uiProcessResponse(response),
                () => uiProcessResponse({"sprava":"nefunguje siet"}));
  }

  void write(String message) {
    // the HTML library defines a global "document" variable
    document.query('#status').innerHTML = message;
  }

  XMLHttpRequest sendRequest(String url, Map json, var onSuccess, var onError) {
    XMLHttpRequest request = new XMLHttpRequest();
    request.on.readyStateChange.add((Event event) {
      if (request.readyState != 4) return;
      if (request.status == 200) {
        onSuccess(JSON.parse(request.responseText));
      } else {
        onError();
      }
    });
    request.open("POST", url, true);
    request.setRequestHeader("Content-Type", "text/plain;charset=UTF-8");
    request.send(JSON.stringify(json));
   
    return request;
  }

  uiProcessResponse(Map response) {
    var str = JSON.stringify(response);
    write(str);
  }
}

void main() {
  new ShipsClient().run();
}



