package gato.input;

class Input {
  public var isDown:Map<VirtualKey, Bool>;
  public var x:Int;
  public var y:Int;
  public var movementX:Int;
  public var movementY:Int;
  public var delta:Int;

  var controllers:Array<Controller> = [];

  public function new() {
    reset();
    controllers.push(new Keyboard());
    controllers.push(new Mouse());
  }

  public function reset():Void {
    isDown = new Map();
    x = 0;
    y = 0;
    movementX = 0;
    movementY = 0;
    delta = 0;
  }

  public function update():Void {
    reset();
    for (controller in controllers) {
      controller.updateInput(this);
    }
  }
}
