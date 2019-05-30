import kha.input.Mouse as KhaMouse;

class Mouse {
  public var x(default, null):Int = 0;
  public var y(default, null):Int = 0;

  var mouse:Null<KhaMouse> = null;
  var isDown:Map<Int, Bool> = new Map();

  public function new() {
    mouse = KhaMouse.get();
    if (mouse != null) {
      mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
    }
  }

  public function isPressed(button:Int):Bool {
    return (isDown[button] == true);
  }

  //
  // Callbacks
  //

  function onMouseDown(button:Int, x:Int, y:Int):Void {
    this.x = x;
    this.y = y;
    isDown[button] = true;
  }

  function onMouseUp(button:Int, x:Int, y:Int):Void {
    isDown.remove(button);
  }

  function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void {
    this.x = x;
    this.y = y;
  }

  function onMouseWheel(delta:Int):Void {
  }
}
