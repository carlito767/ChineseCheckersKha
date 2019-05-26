import kha.input.Mouse as KhaMouse;

class Mouse {
  public var x(default,null):Int = 0;
  public var y(default,null):Int = 0;
  public var select:Bool = false;

  var mouse:Null<KhaMouse> = null;

  public function new() {
    mouse = KhaMouse.get();
    if (mouse != null) {
      mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
    }
  }

  //
  // Callbacks
  //

  function onMouseDown(button:Int, x:Int, y:Int):Void {
    this.x = x;
    this.y = y;
    if (button == 0) {
      select = true;
    }
  }

  function onMouseUp(button:Int, x:Int, y:Int):Void {
    if (button == 0) {
      select = false;
    }
  }

  function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void {
    this.x = x;
    this.y = y;
  }

  function onMouseWheel(delta:Int):Void {
  }
}
