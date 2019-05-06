package gato.input;

class Input {
  var controllers:Array<Controller> = [];

  public function new() {
    controllers.push(new Keyboard());
    controllers.push(new Mouse());
  }

  public function status():InputStatus {
    var inputStatus:InputStatus = {
      isDown:new Map(),
      x:0,
      y:0,
      movementX:0,
      movementY:0,
      delta:0,
    };

    for (controller in controllers) {
      controller.updateInputStatus(inputStatus);
    }

    return inputStatus;
  }
}
