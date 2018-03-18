package system;

class Mouse {
  public var x(default, null):Int = 0;
  public var y(default, null):Int = 0;
  public var leftClick(default, null):Bool = false;

  public function new() {
    var mouse:kha.input.Mouse = kha.input.Mouse.get();
    if (mouse != null) {
      mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
    }
  }

  function onMouseDown(button:Int, x:Int, y:Int) {
    this.x = x;
    this.y = y;
    if (button == 0) {
      this.leftClick = true;
    }
  }

  function onMouseUp(button:Int, x:Int, y:Int) {
    this.x = x;
    this.y = y;
    if (button == 0) {
      this.leftClick = false;
    }
  }

  function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int) {
    this.x = x;
    this.y = y;
  }

  function onMouseWheel(delta:Int) {
    // TODO : onMouseWheel
  }
}
