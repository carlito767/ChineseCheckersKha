package gato.input;

import kha.input.Mouse as KhaMouse;

class Mouse implements Controller {
  public var buttons(default, null):Map<Int, Bool> = new Map();
  public var x(default, null):Int = 0;
  public var y(default, null):Int = 0;
  public var movementX(default, null):Int = 0;
  public var movementY(default, null):Int = 0;
  public var delta(default, null):Int = 0;

  var mouse:Null<KhaMouse> = null;

  public function new() {
    reset();
    mouse = KhaMouse.get();
    if (mouse != null) {
      mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
    }
  }

  public function reset():Void {
    buttons = new Map();
    x = 0;
    y = 0;
    movementX = 0;
    movementY = 0;
    delta = 0;
  }

  public function dispose():Void {
    if (mouse != null) {
      mouse.remove(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
      mouse = null;
      reset();
    }
  }

  //
  // Callbacks
  //

  function onMouseDown(button:Int, x:Int, y:Int):Void {
    buttons[button] = true;
    this.x = x;
    this.y = y;
  }

  function onMouseUp(button:Int, x:Int, y:Int):Void {
    buttons[button] = false;
    this.x = x;
    this.y = y;
  }

  function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void {
    this.x = x;
    this.y = y;
    this.movementX = movementX;
    this.movementY = movementY;
  }

  function onMouseWheel(delta:Int):Void {
    this.delta = delta;
  }
}
